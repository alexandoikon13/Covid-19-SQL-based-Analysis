COPY covid_data(FIPS, Admin2, Province_State, Country_Region, Last_Update, Lat, Long_, Confirmed, Deaths, Recovered, Active, Combined_Key, Incident_Rate, Case_Fatality_Ratio)
FROM './data/11-12-2022.csv'
DELIMITER ','
CSV HEADER;