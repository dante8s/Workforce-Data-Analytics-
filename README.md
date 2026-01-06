# **ELT proces – Workforce Data Analytics (Revelio Labs)**
Tento repozitár prezentuje implementáciu ELT procesu v prostredí Snowflake a je zameraný na analýzu dynamiky pracovnej sily (workforce dynamics) s dôrazom na prepúšťanie zamestnancov (layoffs) a sentiment zamestnancov voči manažmentu. Výsledkom riešenia je dimenzionálny dátový model typu Star Schema.

---
## **1. Úvod a popis zdrojových dát**
Ako zdroj dát bol použitý dataset Revelio Labs – Workforce Data Analytics (Demo), dostupný prostredníctvom Snowflake Marketplace. Dataset je vytvorený na základe stoviek miliónov verejne dostupných záznamov o zamestnanosti.
Na identifikáciu spoločností sa používa univerzálny identifikátor RCID, ktorý umožňuje jednoznačné prepojenie údajov naprieč všetkými tabuľkami datasetu.

### **1.1 Prečo bol zvolený tento dataset**
Dataset Revelio Labs bol zvolený z nasledujúcich dôvodov:
•	obsahuje realistické HR dáta využívané v reálnych biznis analytických scenároch,
•	umožňuje analýzu prepúšťania, sentimentu a časových trendov,
•	je vhodný na návrh dimenzionálneho modelu (Star Schema) a implementáciu ELT procesu.

### **1.2 Biznis procesy podporované dátami**
Dáta podporujú nasledujúce biznis procesy:
•	strategické plánovanie pracovnej sily (Workforce Planning),
•	HR analytiku a monitoring prepúšťania,
•	analýzu vzťahu medzi sentimentom zamestnancov a manažérskymi rozhodnutiami,
•	ESG a fundamentálnu analýzu spoločností z pohľadu ľudského kapitálu.

### **1.3 Typy dát v datasete**
Dataset obsahuje tieto typy dát:
•	identifikačné údaje (RCID, identifikátory spoločností),
•	textové atribúty (názov spoločnosti, typ prepúšťania),
•	numerické metriky (počet prepustených zamestnancov),
•	časové údaje (dátum prepúšťania),
•	sentiment metriky (management sentiment, work-life balance, career advancement).

### **1.4 Zameranie analýzy**
Analýza v rámci projektu je zameraná na:
•	celkový počet prepustených zamestnancov,
•	analýzu prepúšťania v časovom kontexte,
•	porovnanie spoločností podľa rozsahu layoffs,
•	skúmanie vzťahu medzi prepúšťaním a sentimentom zamestnancov.

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

### **1.2 Štruktúra hviezdicového modelu**
Štruktúra hviezdicového modelu je znázornená na diagrame nižšie. Diagram ukazuje prepojenia medzi faktovou tabuľkou a dimenziami, čo zjednodušuje pochopenie a implementáciu modelu.

<p align="center">
  <img src="https://github.com/dante8s/Workforce-Data-Analytics-/blob/main/img/second.png" alt="Star Schema">
  <br>
  <em>Obrázok 2 Schéma hviezdy pre Workforce Data Analytics</em>
</p>


---






