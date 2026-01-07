# **ELT proces – Workforce Data Analytics (Revelio Labs)**
Tento repozitár prezentuje implementáciu ELT procesu v prostredí Snowflake a je zameraný na analýzu dynamiky pracovnej sily (workforce dynamics) s dôrazom na prepúšťanie zamestnancov (layoffs) a sentiment zamestnancov voči manažmentu. Výsledkom riešenia je dimenzionálny dátový model typu Star Schema.

---
## **1. Úvod a popis zdrojových dát**
Ako zdroj dát bol použitý dataset Revelio Labs – Workforce Data Analytics (Demo), dostupný prostredníctvom Snowflake Marketplace. Dataset je vytvorený na základe stoviek miliónov verejne dostupných záznamov o zamestnanosti.
Na identifikáciu spoločností sa používa univerzálny identifikátor RCID, ktorý umožňuje jednoznačné prepojenie údajov naprieč všetkými tabuľkami datasetu.

### **1.1 Prečo bol zvolený tento dataset**
Dataset Revelio Labs bol zvolený z nasledujúcich dôvodov:
- obsahuje realistické HR dáta využívané v reálnych biznis analytických scenároch,
-	umožňuje analýzu prepúšťania, sentimentu a časových trendov,
-	je vhodný na návrh dimenzionálneho modelu (Star Schema) a implementáciu ELT procesu.

### **1.2 Biznis procesy podporované dátami**
Dáta podporujú nasledujúce biznis procesy:
-	strategické plánovanie pracovnej sily (Workforce Planning),
-	HR analytiku a monitoring prepúšťania,
-	analýzu vzťahu medzi sentimentom zamestnancov a manažérskymi rozhodnutiami,
-	ESG a fundamentálnu analýzu spoločností z pohľadu ľudského kapitálu.

### **1.3 Typy dát v datasete**
Dataset obsahuje tieto typy dát:
-	identifikačné údaje (RCID, identifikátory spoločností),
-	textové atribúty (názov spoločnosti, typ prepúšťania),
-	numerické metriky (počet prepustených zamestnancov),
-	časové údaje (dátum prepúšťania),
-	sentiment metriky (management sentiment, work-life balance, career advancement).

### **1.4 Zameranie analýzy**
Analýza v rámci projektu je zameraná na:
-	celkový počet prepustených zamestnancov,
-	analýzu prepúšťania v časovom kontexte,
-	porovnanie spoločností podľa rozsahu layoffs,
-	skúmanie vzťahu medzi prepúšťaním a sentimentom zamestnancov.

### **1.5 Popis zdrojových tabuliek**
`staging_company_mapping`
Referenčná tabuľka s informáciami o spoločnostiach.
Obsahuje identifikátor RCID, názov spoločnosti, rok založenia, burzový ticker a NAICS kód.
Slúži ako hlavný zdroj identifikácie spoločností.  

`staging_layoffs`
Tabuľka obsahujúca informácie o udalostiach prepúšťania.
Obsahuje RCID spoločnosti, dátum prepúšťania, typ prepúšťania a počet prepustených zamestnancov.
Predstavuje hlavný zdroj faktov pre analýzu layoffs.

`staging_sentiment`
Tabuľka s agregovanými ukazovateľmi sentimentu zamestnancov.
Obsahuje hodnotenia sentimentu manažmentu, rovnováhy medzi prácou a osobným životom a kariérneho rozvoja.
Používa sa na analýzu vzťahu medzi prepúšťaním a náladami zamestnancov.

Ostatné tabuľky datasetu
Dataset obsahuje aj tabuľky s demografickými údajmi, vzdelaním a zručnosťami zamestnancov.
V rámci tohto projektu nie sú použité a sú zobrazené iba v ERD pôvodnej dátovej štruktúry.

---
### **1.6 Dátová architektúra**

### **ERD diagram**
Surové dáta sú usporiadané v relačnom modeli, ktorý je znázornený na **entitno-relačnom diagrame (ERD)**:

<p align="center">
  <img src="https://github.com/dante8s/Workforce-Data-Analytics-/blob/main/img/first.png" alt="ERD Schema">
  <br>
   <em>Obrázok 1 Entitno-relačná schéma Workforce Data Analytics</em>
</p>

---
## **2. Dimenzionálny model**

**Dimenzie:**

- `company_dim`  
- `time_dim`  
- `layoffs_dim`  
- `sentiment_dim`  

Každá dimenzia je prepojená s faktovou tabuľkou pomocou cudzieho kľúča.

### Popis dimenzií

**company_dim**  
Dimenzia spoločností obsahuje základné identifikačné a opisné údaje o firmách.  

Atribúty:  
- company_id (PK)  
- COMPANY  
- YEAR_FOUNDED  
- TICKER  
- NAICS_CODE  

Vzťah k faktovej tabuľke:  
`company_id -> company_id (1:N)`  

Typ SCD: Typ 1 – zmeny atribútov sa prepisujú bez uchovávania histórie.

---

**time_dim**  
Časová dimenzia na úrovni mesiaca, odvodená z dátumu prepúšťania.  

Atribúty:  
- time_id (PK, formát YYYYMM)  
- date  
- year  
- month  

Vzťah k faktovej tabuľke:  
`time_id -> time_id (1:N)`  

Typ SCD: Typ 0 – časová dimenzia je nemenná.

---

**layoffs_dim**  
Dimenzia typu prepúšťania, ktorá kategorizuje udalosti layoffs.  

Atribúty:  
- layoff_id (PK)  
- LAYOFF_TYPE  

Vzťah k faktovej tabuľke:  
`layoff_id -> layoff_id (1:N)`  

Typ SCD: Typ 0 – hodnoty typu prepúšťania sa nemenia.

---

**sentiment_dim**  
Dimenzia sentimentu zamestnancov viazaná na spoločnosť.  

Atribúty:  
- sentiment_id (PK)  
- company_id (FK)  
- MANAGEMENT_SENTIMENT  
- WORK_LIFE_BALANCE_SENTIMENT  
- CAREER_ADVANCEMENT_SENTIMENT  

Vzťah k faktovej tabuľke:  
`sentiment_id -> sentiment_id (1:N)`  

Vzťah k company_dim:  
`company_id -> company_id (1:1)`  

Typ SCD: Typ 1 – sentiment hodnoty sú aktualizované bez historizácie.

---

**Faktová tabuľka:** `fact_workforce`

### Popis faktovej tabuľky

**fact_workforce**  
Faktová tabuľka obsahuje udalosti prepúšťania a numerické metriky súvisiace s workforce dynamikou.  

Primárny kľúč:  
- fact_id  

Cudzie kľúče:  
- company_id  
- time_id  
- layoff_id  
- sentiment_id  

Hlavné metriky:  
- NUM_EMPLOYEES – počet prepustených zamestnancov  
- sentiment_rank – poradie sentimentu manažmentu v rámci spoločnosti  
- previous_layoffs – počet prepustených zamestnancov pri predchádzajúcej udalosti

---

### Použité window functions

Vo faktovej tabuľke sú použité povinné analytické funkcie:  
- `ROW_NUMBER()` – generovanie primárneho kľúča fact_id  
- `RANK()` – výpočet poradia sentimentu manažmentu v rámci spoločnosti  
- `LAG()` – získanie hodnoty prepúšťania z predchádzajúcej udalosti

### **2.2 Štruktúra hviezdicového modelu**
Štruktúra hviezdicového modelu je znázornená na diagrame nižšie. Diagram ukazuje prepojenia medzi faktovou tabuľkou a dimenziami, čo zjednodušuje pochopenie a implementáciu modelu.

<p align="center">
  <img src="https://github.com/dante8s/Workforce-Data-Analytics-/blob/main/img/second.png" alt="Star Schema">
  <br>
  <em>Obrázok 2 Schéma hviezdy pre Workforce Data Analytics</em>
</p>

---
## **3. ELT proces v Snowflake**
### **3.1 Extract (Extrahovanie dát)**
**Použité databázy**  
Link na dataset: [Revelio Labs Workforce Data Analytics (Demo)](https://app.snowflake.com/marketplace/listing/GZT1Z2TPPWG4/revelio-labs-inc-workforce-data-analytics-demo?search=WORKFORCE_DATA_ANALYTICS__DEMO)

Na účely ďalšieho spracovania boli vytvorené staging tabuľky v databáze PELICAN_DB a schéme Zaverecny. Staging vrstva slúži kópia dát bez transformácií.
#### Príklad kódu:
````sql
CREATE OR REPLACE TABLE staging_company_mapping AS
SELECT * FROM WORKFORCE_DATA_ANALYTICS__DEMO.PUBLIC_SAMPLE.REVELIO_COMPANY_MAPPING;
````
Príkaz vytvára dočasnú tabuľku `staging_company_mapping` so všetkými údajmi z tabuľky `REVELIO_COMPANY_MAPPING` na ďalšie spracovanie v ELT procese.

#### Príklad kódu:
````sql
DESCRIBE TABLE staging_company_mapping;
````
Slúži na zobrazenie štruktúry tabuľky

---
### **3.2 Load (Načítanie dát)**
#### Príklad kódu:
````sql
CREATE OR REPLACE TABLE company_dim AS
SELECT
    RCID AS company_id,
    COMPANY,
    YEAR_FOUNDED,
    TICKER,
    NAICS_CODE
FROM staging_company_mapping;
````
Tento dotaz vytvára dimenziu `company_dim`:
- Dáta berieme zo staging tabuľky `staging_company_mapping`.
-	Vyberáme atribúty spoločnosti: `názov`, `rok založenia`, `ticker`, `priemyselný kód`.
-	`RCID` premeníme na `company_id` — unikátny kľúč pre spojenie s faktami.
- Tabuľka slúži ako dimension v Star Schema pre analytiku podľa spoločností.

---
### **3.3 Transfor (Transformácia dát)**
#### Príklad kódu:
````sql
CREATE OR REPLACE TABLE time_dim AS
SELECT DISTINCT
    TO_NUMBER(TO_CHAR(DATE_TRUNC('month', LAYOFF_DATE), 'YYYYMM')) AS time_id,
    DATE_TRUNC('month', LAYOFF_DATE) AS date,
    EXTRACT(YEAR FROM LAYOFF_DATE) AS year,
    EXTRACT(MONTH FROM LAYOFF_DATE) AS month
FROM staging_layoffs
WHERE LAYOFF_DATE IS NOT NULL;
````
Tento kód vytvára časovú dimenziu `time_dim` s mesačnou granularitou:
- `SELECT DISTINCT` - Zabezpečuje, že každý mesiac sa v tabuľke objaví iba jedenkrát.
- `DATE_TRUNC` - Skracuje dátum na začiatok mesiaca.
- `TO_CHAR` - funkcia ktorá konvertuje dátum alebo číslo na textový reťazec podľa zadaného formátu.
- `O_NUMBER` - funkcia ktorá konvertuje textový reťazec alebo výraz na číselný typ.
- `EXTRACT(YEAR FROM ...)` – funkcia, ktorá vyberá rok z dátumu.

#### Príklad kódu:
````sql
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
````
Tento dotaz vytvára faktovú tabuľku fact_workforce pre Star Schema, kde sa spájajú dimenzie a metriky prepustení zamestnancov:
- `ROW_NUMBER() OVER (ORDER BY l.LAYOFF_DATE) AS fact_id` - Priraďuje unikátny identifikátor každému faktu.
- `RANK() ... AS sentiment_rank` - zoradenie spoločností podľa manažérskeho sentimentu.
- `LAG(...) AS previous_layoffs` - počet prepustení v predchádzajúcom zázname pre rovnakú spoločnosť.
  
#### Príklad kódu:
````sql
SELECT * FROM Zaverecny.fact_workforce LIMIT 50;
````
Tento dotaz zobrazí prvých 50 riadkov faktovej tabuľky fact_workforce.
Slúži na kontrolu dát po vytvorení tabuľky.

#### Príklad kódu:
````sql
DROP TABLE IF EXISTS staging_layoffs;
````
Príkaz na zmazanie tabuľky z databázy.

---

## **4 Vizualizácia dát**
V tejto časti je predstavených 5 analytických dotazov a grafov, ktoré umožňujú vizualizovať dôležité metriky prepustení a sentimentu v spoločnostiach.
### **Graf 1: Zobrazuje spoločností podľa počtu prepustených zamestnancov**
Táto vizualizácia zobrazuje spoločnosti podľa celkového počtu prepustených zamestnancov.
Pomáha určiť, v ktorých spoločnostiach bolo prepúšťanie najmasovejšie.
````sql
USE WAREHOUSE PELICAN_WH;
SELECT
    c.COMPANY,
    SUM(f.NUM_EMPLOYEES) AS total_layoffs
FROM Zaverecny.fact_workforce f
JOIN Zaverecny.company_dim c
    ON f.company_id = c.company_id
GROUP BY c.COMPANY
ORDER BY total_layoffs DESC;
````

### **Graf 2: Znázorňuje, ako sa počet prepúšťaní menil každý rok**
Táto vizualizácia zobrazuje celkový počet prepustených zamestnancov za jednotlivé roky.
Umožňuje identifikovať trendy v prepúšťaní v čase a zistiť, či počet prepustení rástol alebo klesal počas konkrétnych rokov.
````sql
USE WAREHOUSE PELICAN_WH;
SELECT
    t.year,
    SUM(f.NUM_EMPLOYEES) AS total_layoffs
FROM Zaverecny.fact_workforce f
JOIN Zaverecny.time_dim t
    ON f.time_id = t.time_id
GROUP BY t.year
ORDER BY t.year;
````

### **Graf 3: Zobrazujúci hodnotenie spoločnosti**
Táto vizualizácia zobrazuje, ako sa spoločnosti líšia podľa hodnotenia sentimentu manažmentu.
Umožňuje identifikovať spoločnosti s nízkym, priemerným alebo vysokým sentimentom,
čo môže byť užitočné pre HR alebo analýzu pracovnej spokojnosti.
````sql
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
````

### **Graf 4: Znázorňuje štruktúru prepúšťaní podľa typu**
Táto vizualizácia zobrazuje, koľko zamestnancov bolo prepustených podľa typu prepustenia.
Umožňuje identifikovať, ktoré typy prepustení sú najčastejšie a porovnať ich medzi sebou.
````sql
USE WAREHOUSE PELICAN_WH;
SELECT
    ld.LAYOFF_TYPE,
    SUM(f.NUM_EMPLOYEES) AS total_layoffs
FROM Zaverecny.fact_workforce f
JOIN Zaverecny.layoffs_dim ld
    ON f.layoff_id = ld.layoff_id
GROUP BY ld.LAYOFF_TYPE
ORDER BY total_layoffs DESC;
````

### **Graf 5: Vzťah medzi počtom prepúšťaní a náladou manažmentu**
Táto vizualizácia zobrazuje celkový počet prepustených zamestnancov a priemerný sentiment manažmentu pre každú spoločnosť.
Umožňuje identifikovať spoločnosti, kde boli prepustenia najmasovejšie a zároveň analyzovať, aký bol sentiment manažmentu.
````sql
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
````
---
**Autor:** Dmytro Nesterenko





  
