# Python ETL Process

## Overview

The ETL (Extract, Transform, Load) process prepares the Olist e-commerce dataset for analysis using Python.

## Extract

- Loaded CSV files using Pandas.
- Imported customer, order, order_items product, seller, payment, review, and geolocation datasets.

## Transform

Performed the following data cleaning and preprocessing tasks:

- Checked for missing values
- Removed duplicate records
- Converted date columns to datetime format
- Corrected data types

## Load

- Exported cleaned datasets for SQL analysis.
- Imported the cleaned data into MySQL for querying.

## Tools Used

- Python
- pandas
- NumPy
