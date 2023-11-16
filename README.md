# COVID-19 PostgreSQL-based Data Analysis Project Documentation
## Project Overview
This project aims to analyze COVID-19 data to gain insights into the pandemic's impact on different regions around the world. The primary objective is to evaluate trends in confirmed cases, deaths, recoveries, active cases, incident rates, and case fatality ratios. The data, sourced from Johns Hopkins University's Center for Systems Science and Engineering (JHU CSSE), provides a comprehensive view of the pandemic's progression. The end goal is to use this processed and analyzed data for visualization in Power BI, providing interactive and easy-to-understand representations of the pandemic's key metrics and trends.

## Data Source
The data for this project is sourced from the JHU CSSE COVID-19 Data Repository, available on GitHub: COVID-19 Data Repository by the Center for Systems Science and Engineering (CSSE) at Johns Hopkins University[https://github.com/CSSEGISandData/COVID-19].

## Database Setup ('import_data.sql')
### Database Creation
- A PostgreSQL database named 'covid_analysis' is created to store and manage the COVID-19 data.

### Client Encoding
- The client encoding is set to UTF8 to ensure compatibility with the data encoding.

### Schema Creation
- A schema named 'covid_data_schema' is created.
- A template table within this schema is defined to standardize the structure of COVID-19 data tables.

### Table Creation
- Two tables, 'covid_data_12' and 'covid_data_13', are created based on the template table structure. These tables are intended to store daily COVID-19 data reports. The former table refers to the daily reports of 12-11-2022, and 13-11-2022 for the latter (DD-MM-YYYY).

### Data Import
- Data from CSV files for specific dates (11-12-2022 and 11-13-2022) is imported into the respective tables.

## Data Preprocessing ('table_preprocess.sql')
### Functions for Data Preprocessing
Several functions are created to preprocess the data:
- 'drop_unnecessary_columns': Drops columns that are not required for analysis.
- 'handle_missing_data': Handles missing data by setting NULL values in 'deaths', 'recovered', and 'active' columns to 0.
- 'convert_data_types': Converts the data types of 'incident_rate' and 'case_fatality_ratio' to DECIMAL for accurate calculations.
- 'add_update_columns': Adds new columns for recalculated incident rate and case fatality ratio, and updates them based on the existing data.
- 'rename_column': Renames columns for consistency and clarity.

### Table Merging
- A new table 'covid_data' is created by merging 'covid_data_12' and 'covid_data_13' using the UNION ALL operation. This table serves as a comprehensive dataset for further analysis.

### Applying Preprocessing Functions
- The preprocessing functions are applied to the 'covid_data' table to prepare the data for analysis.

## Data Analysis
### Record Count
- A query is executed to count the total number of records in each of the tables: 'covid_data_12', 'covid_data_13', and 'covid_data'.

### Key Metrics by Country
- The total confirmed cases and deaths by country are calculated and listed.

### Global Totals
- Global totals for confirmed cases, deaths, and recoveries are computed.

### Trends Over Time
- Trends in daily confirmed cases are analyzed by date and country.

### Incident Rate and Case Fatality Ratio
- A view ('covid_data_view') is created to focus on recalculated incident rates and case fatality ratios.
- The top incident rates are identified using a window function for a refined analysis.

#############################################################################################################################
#### TODO:
## Data Visualization in Power BI
The processed and analyzed data will be exported and used in Power BI for visualization. The visualizations will include:
- Interactive maps showing global spread and impact.
- Trend lines and bar charts depicting the progression of cases and recoveries over time.
- Comparative analyses of different regions based on incident rates and case fatality ratios.
- Dashboards to display key metrics and insights, enabling easy understanding and tracking of the pandemic's trends.

## Usage in Power BI
- Import the processed data from PostgreSQL into Power BI.
- Create visualizations and dashboards using Power BI's extensive tools and features.
- Share the Power BI reports and dashboards with relevant stakeholders for informed decision-making and public awareness.

## Conclusion
This project, through its comprehensive data analysis and subsequent visualization in Power BI, aims to provide valuable insights into the COVID-19 pandemic, aiding in understanding its impact and guiding response efforts.


# MIT License
