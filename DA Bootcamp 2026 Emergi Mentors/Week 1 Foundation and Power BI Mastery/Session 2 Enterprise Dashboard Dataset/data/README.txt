This folder contains synthetic data generated for the enterprise Power BI playbook.

Subfolders:
- csv: Operational CSV exports (operations_sales.csv).
- excel: Finance planning workbook (finance_planning.xlsx).
- sql: CSV files ready for SQL Server import (dimensions and fact tables).
- sharepoint/marketing_uploads: Multiple marketing spend files simulating SharePoint uploads.

Each file intentionally contains missing values, inconsistent casing, duplicates, 
negative and zero values, seasonality and outliers to replicate real-world data challenges.
By default this script generates ~100,000 sales rows and marketing files with 5,000 rows each; these values are configurable via command-line arguments (see --help).
This script writes a native Excel workbook (.xlsx) for the finance planning output and will attempt to install XlsxWriter or openpyxl if needed (use --no-install-extras to disable auto-install).
