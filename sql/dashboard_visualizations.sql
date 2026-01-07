-- Graf 1: Zobrazuje spoločností podľa počtu prepustených zamestnancov

USE WAREHOUSE PELICAN_WH;
SELECT
    c.COMPANY,
    SUM(f.NUM_EMPLOYEES) AS total_layoffs
FROM Zaverecny.fact_workforce f
JOIN Zaverecny.company_dim c
    ON f.company_id = c.company_id
GROUP BY c.COMPANY
ORDER BY total_layoffs DESC;

-- Graf 2: Znázorňuje, ako sa počet prepúšťaní menil každý rok

USE WAREHOUSE PELICAN_WH;
SELECT
    t.year,
    SUM(f.NUM_EMPLOYEES) AS total_layoffs
FROM Zaverecny.fact_workforce f
JOIN Zaverecny.time_dim t
    ON f.time_id = t.time_id
GROUP BY t.year
ORDER BY t.year;

-- Graf 3: Zobrazujúci hodnotenie spoločnosti

USE WAREHOUSE PELICAN_WH;
SELECT
    c.COMPANY AS company_name,
    CASE 
        WHEN sd.MANAGEMENT_SENTIMENT <= -0.08 THEN 'nízky'
        WHEN sd.MANAGEMENT_SENTIMENT <= -0.04 THEN 'priemerný'
        ELSE 'vysoký'
    END AS sentiment_group,
    COUNT(*) AS num_records
FROM Zaverecny.fact_workforce f
JOIN Zaverecny.company_dim c
    ON f.company_id = c.company_id
JOIN Zaverecny.sentiment_dim sd
    ON f.sentiment_id = sd.sentiment_id
GROUP BY company_name, sentiment_group
ORDER BY company_name, sentiment_group;

-- Graf 4: Znázorňuje štruktúru prepúšťaní podľa typu

USE WAREHOUSE PELICAN_WH;
SELECT
    ld.LAYOFF_TYPE,
    SUM(f.NUM_EMPLOYEES) AS total_layoffs
FROM Zaverecny.fact_workforce f
JOIN Zaverecny.layoffs_dim ld
    ON f.layoff_id = ld.layoff_id
GROUP BY ld.LAYOFF_TYPE
ORDER BY total_layoffs DESC;

-- Graf 5: Vzťah medzi počtom prepúšťaní a náladou manažmentu

USE WAREHOUSE PELICAN_WH;
SELECT
    c.COMPANY AS company_name,
    SUM(f.NUM_EMPLOYEES) AS total_layoffs,
    AVG(sd.MANAGEMENT_SENTIMENT) AS avg_management
FROM Zaverecny.fact_workforce f
JOIN Zaverecny.company_dim c
    ON f.company_id = c.company_id
JOIN Zaverecny.sentiment_dim sd
    ON f.sentiment_id = sd.sentiment_id
GROUP BY c.COMPANY
ORDER BY total_layoffs DESC;