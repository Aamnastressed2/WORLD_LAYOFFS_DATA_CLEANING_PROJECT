-- =====================================================
-- 📊 DATA CLEANING PROJECT: LAYOFFS DATASET
-- =====================================================

-- STEP 1: CREATE STAGING TABLE SO THAT WE CAN DO CHANGES IN THAT INSTEAD OF ACTUAL DATA
CREATE TABLE layoff_staging LIKE layoffs;

INSERT INTO layoff_staging
SELECT * FROM layoffs;

SELECT * FROM layoff_staging;

-- =====================================================
-- STEP 2: REMOVE DUPLICATES
-- =====================================================

-- Identify duplicates using ROW_NUMBER
SELECT *,
ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off,
                 percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoff_staging;

-- Store duplicates in CTE
WITH duplicate_cte AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off,
                     percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS row_num
    FROM layoff_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Create another table so that you can remove duplicates using row_num
CREATE TABLE layoff_staging2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off INT DEFAULT NULL,
  percentage_laid_off TEXT,
  `date` TEXT,
  stage TEXT,
  country TEXT,
  funds_raised_millions INT DEFAULT NULL,
  row_num INT
);

-- Insert data with row numbers
INSERT INTO layoff_staging2
SELECT *,
ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off,
                 percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoff_staging;

-- Delete duplicate rows
DELETE
FROM layoff_staging2
WHERE row_num > 1;

-- Verify duplicates removed
SELECT *
FROM layoff_staging2
WHERE row_num > 1;

-- =====================================================
-- STEP 3: STANDARDIZE DATA
-- =====================================================

-- check manually what coloumn needs cleaning yourself and then start cleaning one by one using the distinct command

SELECT DISTINCT industry
FROM layoff_staging2;

-- Trim company names
UPDATE layoff_staging2
SET industry = TRIM(industry);

-- Standardize industry values (Crypto variations)
UPDATE layoff_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Clean country column (remove trailing dots)
UPDATE layoff_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'UNITED STATES%';

-- Clean location column (remove trailing dots)
UPDATE layoff_staging2
SET location = TRIM(TRAILING '.' FROM location);

-- Fix encoding issues in location names
UPDATE layoff_staging2
SET location = REPLACE(location, 'DÃ¼sseldorf', 'Düsseldorf');

UPDATE layoff_staging2
SET location = REPLACE(location, 'FlorianÃ³polis', 'Florianópolis');

UPDATE layoff_staging2
SET location = REPLACE(location, 'MalmÃ¶', 'Malmö');

-- =====================================================
-- STEP 4: FORMAT DATE COLUMN
-- =====================================================

-- Convert text to DATE format
UPDATE layoff_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Change column type to DATE
ALTER TABLE layoff_staging2
MODIFY COLUMN `date` DATE;

-- =====================================================
-- STEP 5: HANDLE NULL & BLANK VALUES
-- =====================================================

SELECT * 
FROM layoff_staging2
 WHERE industry IS NULL 
 OR industry = ' ';
 
-- Convert blank industry values to NULL
UPDATE layoff_staging2
SET industry = NULL
WHERE TRIM(industry) = '';

-- for checking purposes
SELECT * 
FROM layoff_staging2 
WHERE company = 'Airbnb';

-- Fill missing industry values using self join
UPDATE layoff_staging2 t1
JOIN layoff_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Remove rows with no useful layoff data
DELETE
FROM layoff_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- =====================================================
-- STEP 6: FINAL CLEANUP
-- =====================================================

-- Remove helper column
ALTER TABLE layoff_staging2
DROP COLUMN row_num;

-- Final cleaned dataset
SELECT *
FROM layoff_staging2;