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

### **1.1 Dátová architektúra**

### **ERD diagram**

