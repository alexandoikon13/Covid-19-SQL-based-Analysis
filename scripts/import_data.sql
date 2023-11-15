CREATE DATABASE covid_analysis;

CREATE TABLE covid_data (
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
    Case_Fatality_Ratio NUMERIC
);

\copy covid_data from 'C:/Users/alexa/Dropbox/My PC (LAPTOP-TALO5C9C)/Desktop/Study Challenge/myportfolio/Projects_VSCode/Covid-19-SQL-based-Analysis/data/csse_covid_19_data/csse_covid_19_daily_reports/11-12-2022.csv' DELIMITER ',' CSV HEADER;

ALTER TABLE covid_data
DROP COLUMN FIPS,
DROP COLUMN Admin2,
DROP COLUMN Province_State,
DROP COLUMN Lat,
DROP COLUMN Long_,
DROP COLUMN Combined_Key
;