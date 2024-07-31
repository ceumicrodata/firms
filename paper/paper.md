---
authors:
title:
---

# Adatok
## Sokaság kiválasztása
- 1988-2022
- pénzügyi közvetítők kivételével
- kategóriák:
    - külföldi = fo3
    - állami = so3_with_mo3
    - hazai = do3
    - hazain belül méret
        - mikro 0-9
        - kis 10-49
        - közép 50-249
        - nagy 250+
- replace missing with 0

## Mérleg és eredménykimutatás
- kettős könyvvitelű vállalkozások

## Cégjegyzék
- társas vállalkozások
- gazdasági formák szerinti megoszlás

# Aggregált trendek
csak mérleg-LTS alapján

0. Mintánkban szereplő összes foglalkoztatott
    - vs aggregált folglakoztatásu from KSH
1. Gazdasági társaságok száma évente, kategóriák szerint
    - 6 kategória
    - esetleg log skálán, hogy mindegyik látsszon?
    - esetleg összevetve KSH számokkal
2. Egy főre jutó árbevétel, kategóriák szerint
    - @collapse sum_sales = sum(sales) sum_emp = sum(emp), by(year kateg); @generate sales_per_emp = sum_sales / sum_emp
    - mindkét változó tisztítva
    - sales PPI-vel deflálva
    - ha kell, kisebb csoportok eldobhatók
        - so3 elhagyható, ha nem jelentős
        - mikro és kis összevonható
        - de minimum maradjon: kis, közép, nagy és fo3
3. Egy főre jutó hozzáadott érték, kategóriák szerint
    - gdp1, gdp2
4. Exportarány az árbevételben, kategóriák szerint
    - 2017-ig van meg!
        - vonalat megállíthatjuk az adott évben + lábjegyzet
5. Exportáló vállalatok aránya, kategóriák szerint
    - 2017-ig van meg!
        - vonalat megállíthatjuk az adott évben + lábjegyzet

Magyarázat: részben kompozíciós hatások. Kisvállalatok belépnek, külföldiek felvásárolják a jó vállalatokat.

# Vállalati demográfia
mérleg-LTS és cégjegyzék-LTS metszete alapján

paneladat, longitudinálisan kötve, lehetőleg frame_id alapján
foundyear := első megjelenés a mérlegben, replace firmage

kezdeti méretkategória: A vállalat első 5 életévében elért maximális létszám alapján.

```julia
@egen max_emp_5 = max(cond(firm_age <= 5, emp, 0)), by(frame_id)
```

6. Újonnan bejegyzett társas vállalkozások száma
    - fo3 vs do3?
    - foundyear szerint plottolható, ha nem kell mérlegadat
7. Túlélési esélyek a vállalat életkora szerint
    - fo3 vs do3
    - kezdeti méretkategória
    - esetleg megbontva belépési kohorsz (foundyear) szerint
```julia
@collapse n_firms = rowcount(distinct(frame_id)), by(firmage, categ)
@egen max_n = max(cond(firmage == 0, n_firms, 0)), by(categ)
@generate survival = 100 * n_firms / max_n
```
8. Létszám növekedése az életkor függvényében
    - az első 5 év max létszámához képest
    - kategóriánként
```julia
@generate growth = emp / max_emp_5
@collapse mean_growth = mean(growth), by(firmage, categ)
```

- Valami kohorsz??

# Menedzser demográfia
csak 2013 vagy később, hogy legyen CEO születési idő

9. Átlagos életkor, kategóriák szerint
10. CEO korfa, nemenként, 2013-ban és 2022-ben
11. 60 évnél idősebb CEO-k aránya, kategóriák szerint

