/* Function for Handling Missing Data */
CREATE OR REPLACE FUNCTION handle_missing_data(table_name text) RETURNS void AS $$
BEGIN
    EXECUTE 'UPDATE ' || table_name || ' SET deaths = 0 WHERE deaths IS NULL;';
    EXECUTE 'UPDATE ' || table_name || ' SET recovered = 0 WHERE recovered IS NULL;';
    EXECUTE 'UPDATE ' || table_name || ' SET active = 0 WHERE active IS NULL;';
END;
$$ LANGUAGE plpgsql;

/*Function for Converting Data Types.
Ensure that the data types of each column are appropriate for the type of data.
For example, if 'incident_rate' and 'case_fatality_ratio' are stored as text,
but should be numeric for calculations*/
CREATE OR REPLACE FUNCTION convert_data_types(table_name text) RETURNS void AS $$
BEGIN
    EXECUTE 'ALTER TABLE ' || table_name || ' 
             ALTER COLUMN incident_rate TYPE DECIMAL USING incident_rate::DECIMAL,
             ALTER COLUMN case_fatality_ratio TYPE DECIMAL USING case_fatality_ratio::DECIMAL;';
END;
$$ LANGUAGE plpgsql;

/* Function for Adding & Updating new columns for recalculations */
CREATE OR REPLACE FUNCTION add_update_columns(table_name text) RETURNS void AS $$
BEGIN
    EXECUTE 'ALTER TABLE ' || table_name || ' ADD COLUMN IF NOT EXISTS population INTEGER;';
    /* Calculate the population */
    EXECUTE 'UPDATE ' || table_name || ' SET population = COALESCE(deaths, 0) + COALESCE(confirmed, 0) + COALESCE(active, 0) + COALESCE(recovered, 0);';

    EXECUTE 'ALTER TABLE ' || table_name || ' ADD COLUMN IF NOT EXISTS recalculated_incident_rate DECIMAL;';
    /* Recalculate the Incident Rate per 1,000,000 people */
    EXECUTE 'UPDATE ' || table_name || ' SET recalculated_incident_rate = (confirmed::DECIMAL / population) * 1000000 WHERE population IS NOT NULL AND population > 0;';

    EXECUTE 'ALTER TABLE ' || table_name || ' ADD COLUMN IF NOT EXISTS recalculated_cfr DECIMAL;';
    /* Recalculate the Case Fatality Ratio */
    EXECUTE 'WITH cfr_aggregation AS (
                 SELECT country_region, SUM(deaths) AS total_deaths, SUM(confirmed) AS total_confirmed
                 FROM ' || table_name || ' 
                 GROUP BY country_region
             )
             UPDATE ' || table_name || ' 
             SET recalculated_cfr = (total_deaths / NULLIF(total_confirmed, 0)) * 100
             FROM cfr_aggregation
             WHERE ' || table_name || '.country_region = cfr_aggregation.country_region;';
END;
$$ LANGUAGE plpgsql;

/* Function for Renaming columns */
CREATE OR REPLACE FUNCTION rename_column(table_name text, old_column_name text, new_column_name text) RETURNS void AS $$
BEGIN
    EXECUTE 'ALTER TABLE ' || table_name || ' RENAME COLUMN ' || old_column_name || ' TO ' || new_column_name || ';';
END;
$$ LANGUAGE plpgsql;

/* Join the two tables on Country_region */
CREATE TABLE covid_data AS
SELECT
    country_region,
    Last_Update,
    Confirmed,
    Deaths,
    Recovered,
    Active,
    Incident_Rate,
    Case_Fatality_Ratio
FROM 
    covid_data_12
UNION ALL
SELECT
    country_region,
    Last_Update,
    Confirmed,
    Deaths,
    Recovered,
    Active,
    Incident_Rate,
    Case_Fatality_Ratio
FROM 
    covid_data_13;

/* Apply the functions on the merged table */
SELECT handle_missing_data('covid_data');
SELECT convert_data_types('covid_data');
SELECT add_update_columns('covid_data');
SELECT rename_column('covid_data', 'last_update', 'date_reported');

/* Get the total number of records per table */
SELECT 'covid_data_12' AS covid_data_12, COUNT(*) AS total_records FROM covid_data_12
UNION ALL
SELECT 'covid_data_13', COUNT(*) FROM covid_data_13
UNION ALL
SELECT 'covid_data', COUNT(*) FROM covid_data;

/*Total Counts by Country*/
SELECT country_region, SUM(confirmed) AS total_confirmed, SUM(deaths) AS total_deaths
FROM covid_data
GROUP BY country_region
ORDER BY total_confirmed DESC
LIMIT 10;

/*Global Totals*/
SELECT 
    SUM(confirmed) AS global_confirmed, 
    SUM(deaths) AS global_deaths, 
    SUM(recovered) AS global_recovered
FROM covid_data;

/*Trends Over Time*/
ALTER TABLE covid_data
RENAME COLUMN last_update TO date_reported;
SELECT 
    date_reported, 
    country_region, 
    SUM(confirmed) AS daily_confirmed
FROM covid_data
GROUP BY date_reported, country_region
ORDER BY SUM(confirmed) DESC
LIMIT 10;

/*Create a View Table to recalculate the Incident Rate and Case Fatality Ratio*/
CREATE VIEW covid_data_view AS
SELECT
    country_region,
    date_reported,
    recalculated_incident_rate,
    recalculated_cfr
FROM 
    covid_data;

/*Highest Incident Rates on View Table, using a Window function*/
SELECT country_region, date_reported, recalculated_incident_rate
FROM (
    SELECT 
        country_region, 
        date_reported, 
        recalculated_incident_rate,
        ROW_NUMBER() OVER (PARTITION BY country_region ORDER BY recalculated_incident_rate DESC, date_reported) as rn
    FROM covid_data_view
    WHERE recalculated_incident_rate BETWEEN 2500 AND 950500
) subquery
WHERE rn = 1 --we filter to get only the first row for each country, which corresponds to the highest incident rate for that country.
ORDER BY recalculated_incident_rate DESC, date_reported
LIMIT 10;

