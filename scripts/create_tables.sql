CREATE TABLE covid_data (
    FIPS INT NULL,
    Admin2 VARCHAR(50) NULL,
    Province_State VARCHAR(50) NOT NULL,
    Country_Region VARCHAR(50) NOT NULL,
    Last_Update DATE,
    Lat NUMERIC,
    Long_ NUMERIC,
    Confirmed INTEGER,
    Deaths INTEGER,
    Active INTEGER,
    Combined_Key VARCHAR(50),
    Incident_Rate NUMERIC,
    Case_Fatality_Ratio NUMERIC,
    PRIMARY KEY (Province_State, Country_Region)
);
