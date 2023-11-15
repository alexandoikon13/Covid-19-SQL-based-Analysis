/*Handling Missing Data*/
UPDATE covid_data SET deaths = 0 WHERE deaths IS NULL;
UPDATE covid_data SET recovered = 0 WHERE recovered IS NULL;
UPDATE covid_data SET active = 0 WHERE active IS NULL;

/*Converting Data Types. Ensure that the data types of each column are appropriate for the type of data. For example, if 'incident_rate' and 'case_fatality_ratio' are stored as text but should be numeric for calculations*/
ALTER TABLE covid_data
ALTER COLUMN incident_rate TYPE DECIMAL USING incident_rate::DECIMAL,
ALTER COLUMN case_fatality_ratio TYPE DECIMAL USING case_fatality_ratio::DECIMAL;

/*Total Counts by Country*/
SELECT country_region, SUM(confirmed) AS total_confirmed, SUM(deaths) AS total_deaths
FROM covid_data
GROUP BY country_region
ORDER BY total_confirmed DESC;

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
ORDER BY SUM(confirmed) DESC;

/*Calculate the population & Update the table*/
ALTER TABLE covid_data ADD COLUMN population INTEGER;
UPDATE covid_data
SET population = COALESCE(deaths, 0) + COALESCE(confirmed, 0) + COALESCE(active, 0) + COALESCE(recovered, 0);

/*Recalculate the Incident Rate per 1,000,000 people & Update the table*/
ALTER TABLE covid_data ADD COLUMN recalculated_incident_rate DECIMAL;
UPDATE covid_data
SET recalculated_incident_rate = (confirmed::DECIMAL / population) * 1000000
WHERE population IS NOT NULL AND population > 0;

/*Recalculate the Case Fatality Ratio & Update the table*/
ALTER TABLE covid_data ADD COLUMN recalculated_cfr DECIMAL;
WITH cfr_aggregation AS (
    SELECT 
        country_region, 
        SUM(deaths) AS total_deaths, 
        SUM(confirmed) AS total_confirmed
    FROM covid_data
    GROUP BY country_region
)
UPDATE covid_data
SET recalculated_cfr = (total_deaths / NULLIF(total_confirmed, 0)) * 100
FROM cfr_aggregation
WHERE covid_data.country_region = cfr_aggregation.country_region;

/*Create a View Table to recalculate the Incident Rate and Case Fatality Ratio*/
CREATE VIEW covid_data_view AS
SELECT
    country_region,
    date_reported,
    recalculated_incident_rate,
    recalculated_cfr
FROM 
    covid_data;

/*Highest Incident Rates on View Table*/
SELECT country_region, recalculated_incident_rate
FROM covid_data_view
ORDER BY recalculated_incident_rate
LIMIT 10;

