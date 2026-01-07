USE DATABASE PELICAN_DB;
CREATE SCHEMA Zaverecny;

CREATE OR REPLACE TABLE staging_company_mapping AS
SELECT * FROM WORKFORCE_DATA_ANALYTICS__DEMO.PUBLIC_SAMPLE.REVELIO_COMPANY_MAPPING;

CREATE OR REPLACE TABLE staging_layoffs AS
SELECT * FROM WORKFORCE_DATA_ANALYTICS__DEMO.PUBLIC_SAMPLE.REVELIO_LAYOFFS;

CREATE OR REPLACE TABLE staging_sentiment AS
SELECT * FROM WORKFORCE_DATA_ANALYTICS__DEMO.PUBLIC_SAMPLE.REVELIO_SENTIMENT_SCORES;

DESCRIBE TABLE staging_company_mapping;
DESCRIBE TABLE staging_layoffs;
DESCRIBE TABLE staging_sentiment;


CREATE OR REPLACE TABLE company_dim AS
SELECT
    RCID AS company_id,
    COMPANY,
    YEAR_FOUNDED,
    TICKER,
    NAICS_CODE
FROM staging_company_mapping;

CREATE OR REPLACE TABLE time_dim AS
SELECT DISTINCT
    TO_NUMBER(TO_CHAR(DATE_TRUNC('month', LAYOFF_DATE), 'YYYYMM')) AS time_id,
    DATE_TRUNC('month', LAYOFF_DATE) AS date,
    EXTRACT(YEAR FROM LAYOFF_DATE) AS year,
    EXTRACT(MONTH FROM LAYOFF_DATE) AS month
FROM staging_layoffs
WHERE LAYOFF_DATE IS NOT NULL;



CREATE OR REPLACE TABLE layoffs_dim AS
SELECT
    ROW_NUMBER() OVER (ORDER BY LAYOFF_TYPE) AS layoff_id,
    LAYOFF_TYPE
FROM (
    SELECT DISTINCT LAYOFF_TYPE
    FROM staging_layoffs
);


CREATE OR REPLACE TABLE sentiment_dim AS
SELECT
    ROW_NUMBER() OVER (ORDER BY RCID) AS sentiment_id,
    RCID AS company_id,
    MANAGEMENT_SENTIMENT,
    WORK_LIFE_BALANCE_SENTIMENT,
    CAREER_ADVANCEMENT_SENTIMENT
FROM staging_sentiment;


CREATE OR REPLACE TABLE fact_workforce AS
SELECT
    ROW_NUMBER() OVER (ORDER BY l.LAYOFF_DATE) AS fact_id,
    c.company_id,
    t.time_id,
    ld.layoff_id,
    sd.sentiment_id,
    l.NUM_EMPLOYEES,
    RANK() OVER (
        PARTITION BY c.company_id
        ORDER BY COALESCE(sd.MANAGEMENT_SENTIMENT,0) DESC
    ) AS sentiment_rank,
    LAG(l.NUM_EMPLOYEES) OVER (
        PARTITION BY c.company_id
        ORDER BY l.LAYOFF_DATE
    ) AS previous_layoffs
FROM staging_layoffs l
LEFT JOIN company_dim c
    ON l.RCID = c.company_id
LEFT JOIN time_dim t
    ON TO_NUMBER(TO_CHAR(DATE_TRUNC('month', l.LAYOFF_DATE), 'YYYYMM')) = t.time_id
LEFT JOIN layoffs_dim ld
    ON l.LAYOFF_TYPE = ld.LAYOFF_TYPE
LEFT JOIN sentiment_dim sd
    ON c.company_id = sd.company_id;


SELECT * FROM staging_layoffs LIMIT 5;
SELECT * FROM staging_sentiment LIMIT 5;
SELECT * FROM staging_company_mapping LIMIT 5;
SELECT * FROM company_dim LIMIT 5;
SELECT * FROM time_dim LIMIT 5;
SELECT * FROM layoffs_dim LIMIT 5;
SELECT * FROM sentiment_dim LIMIT 5;
SELECT * FROM fact_workforce LIMIT 50;

 
DROP TABLE IF EXISTS staging_layoffs;
DROP TABLE IF EXISTS staging_sentiment;
DROP TABLE IF EXISTS staging_company_mapping;



