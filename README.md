# 📊 Layoffs Data Cleaning Project (SQL)

## 📌 Overview
This project focuses on cleaning and preparing a real-world layoffs dataset using SQL. The goal was to transform raw, inconsistent data into a structured and analysis-ready format.

---

## 🛠️ Skills Used
- Window Functions (ROW_NUMBER)
- CTEs
- Joins (Self Join)
- Data Cleaning Techniques
- String Functions (TRIM, REPLACE)
- Date Conversion
- Handling NULL values

---

## 🔧 Data Cleaning Steps

### 1. Removed Duplicates
- Used ROW_NUMBER() to identify duplicate rows
- Deleted duplicate records while keeping unique entries

### 2. Standardized Data
- Trimmed whitespace from company names
- Standardized industry values (e.g., "Crypto%" → "Crypto")
- Cleaned country and location formatting
- Fixed encoding issues in location names

### 3. Fixed Date Format
- Converted date from TEXT to DATE format using STR_TO_DATE()

### 4. Handled Missing Values
- Converted blank values to NULL
- Filled missing industry values using self-join
- Removed rows with no meaningful layoff data

### 5. Final Cleanup
- Dropped helper columns
- Produced a clean dataset ready for analysis

---

- Built reusable SQL cleaning workflow

---

## 💼 Project Value
This project demonstrates practical SQL skills used in real data analyst roles, especially in data preprocessing and cleaning pipelines.
