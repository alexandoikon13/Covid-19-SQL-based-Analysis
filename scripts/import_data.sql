/* Create a database in PostgreSQL (assuming PostgreSQL is installed) */
CREATE DATABASE covid_analysis;

/* Ensure the encoding of the client matches the database server*/
SET client_encoding TO 'UTF8';

/* Create Schema for the tables based on a Template Table */
CREATE SCHEMA covid_data_schema;

/* Template Table to use for the Schema */
CREATE TABLE covid_data_schema.template_table (
    FIPS INT,
    Admin2 VARCHAR(50),
    Province_State VARCHAR(50),
    Country_Region VARCHAR(50),
    Last_Update DATE,
    Lat NUMERIC,
    Long_ NUMERIC,
    Confirmed INTEGER,
    Deaths INTEGER,
    Recovered INTEGER,
    Active INTEGER,
    Combined_Key VARCHAR(100),
    Incident_Rate NUMERIC,
    Case_Fatality_Ratio NUMERIC);

/* Create tables in the database */
CREATE TABLE covid_data_12 (LIKE covid_data_schema.template_table);
CREATE TABLE covid_data_13 (LIKE covid_data_schema.template_table);

/* Copy the data from the CSV files to the tables */
\COPY covid_data_12 from 'C:/Users/alexa/Dropbox/My PC (LAPTOP-TALO5C9C)/Desktop/Study Challenge/myportfolio/Projects_VSCode/Covid-19-SQL-based-Analysis/data/csse_covid_19_data/csse_covid_19_daily_reports/11-12-2022.csv' DELIMITER ',' CSV HEADER;
\COPY covid_data_13 from 'C:/Users/alexa/Dropbox/My PC (LAPTOP-TALO5C9C)/Desktop/Study Challenge/myportfolio/Projects_VSCode/Covid-19-SQL-based-Analysis/data/csse_covid_19_data/csse_covid_19_daily_reports/11-13-2022.csv' DELIMITER ',' CSV HEADER;

/* Function for Dropping the unnecessary columns */
CREATE OR REPLACE FUNCTION drop_unnecessary_columns(table_name TEXT) RETURNS void AS $$
BEGIN
    EXECUTE 'ALTER TABLE ' || table_name || '
             DROP COLUMN IF EXISTS FIPS,
             DROP COLUMN IF EXISTS Admin2,
             DROP COLUMN IF EXISTS Province_State,
             DROP COLUMN IF EXISTS Lat,
             DROP COLUMN IF EXISTS Long_,
             DROP COLUMN IF EXISTS Combined_Key;';
END;
$$ LANGUAGE plpgsql;

/* Apply the function */
SELECT drop_unnecessary_columns('covid_data_12');
SELECT drop_unnecessary_columns('covid_data_13');