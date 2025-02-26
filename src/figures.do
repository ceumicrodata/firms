clear all
import delimited "output/all.csv", case(preserve)

preserve
    replace category = "domestic" if !inlist(category, "state", "foreign")
    collapse (sum) emp n_firms, by(category year)
    generate avg_employment = emp / n_firms
    label variable n_firms "Number of firms"
    label variable avg_employment "Average firm size"
    encode category, gen(cat)
    xtset cat year
    list
    xtline n_firms, overlay  ///
        title("Number of firms by owner", size(medium)) ytitle("Number of firms") ///
        xtitle("Year") 
    graph export "output/fig/fig1a.png", replace
    xtline avg_employment, overlay  ///
        title("Average firm size by owner", size(medium)) ytitle("Employment") ///
        xtitle("Year") yscale(log) ytick(1 10 50 250 1000) ylab(1 10 50 250 1000)
    graph export "output/fig/fig2.png", replace
restore
preserve
    drop if inlist(category, "micro domestic", "small domestic")
    replace category = "domestic" if !inlist(category, "state", "foreign")
    collapse (sum) emp n_firms, by(category year)
    label variable n_firms "Number of firms"
    encode category, gen(cat)
    xtset cat year
    xtline n_firms, overlay  ///
        title("Number of firms by owner (without small firms)", size(medium)) ytitle("Number of firms") ///
        xtitle("Year") 
    graph export "output/fig/fig1b.png", replace
restore
preserve
    replace category = "small domestic" if category == "micro domestic"
    drop if category == "state"
    collapse (sum) emp n_firms sales Export gdp inputs, by(category year)
    generate TFP = gdp / inputs / 10
    generate sales_per_worker = sales / emp / 1000
    generate gdp_per_worker = gdp / emp / 1000
    generate export_share = Export / sales * 100
    label variable sales_per_worker "Sales per worker"
    label variable gdp_per_worker "Value added per worker"
    label variable export_share "Export share"
    generate cat = 4 if category == "small domestic"
    replace cat = 3 if category == "medium domestic"
    replace cat = 2 if category == "large domestic"
    replace cat = 1 if category == "foreign"
    label define cat 1 "Foreign" 2 "Large" 3 "Medium" 4 "Small"
    label values cat cat
    xtset cat year
    xtline sales_per_worker, overlay  ///
        title("Sales per worker by owner", size(medium)) ytitle("Sales per worker, m Ft") ///
        xtitle("Year") 
    graph export "output/fig/fig3a.png", replace
    xtline gdp_per_worker, overlay  ///
        title("Labor productivity by owner", size(medium)) ytitle("Value added per worker, m Ft") ///
        xtitle("Year") 
    graph export "output/fig/fig3b.png", replace
    xtline export_share, overlay  ///
        title("Export share by owner", size(medium)) ytitle("Export share, %") ///
        xtitle("Year")
    graph export "output/fig/fig3c.png", replace
    xtline TFP, overlay  ///
        title("TFP by owner", size(medium)) ytitle("TFP (index)") ///
        xtitle("Year")
    graph export "output/fig/fig3d.png", replace
restore

clear all
import delimited "output/survival.csv", case(preserve)

preserve
    rename age_in_balance age
    replace mean_growth = mean_growth * 100
    generate cat = 4 if category == "small domestic"
    replace cat = 3 if category == "medium domestic"
    replace cat = 2 if category == "large domestic"
    replace cat = 1 if category == "foreign"
    label define cat 1 "Foreign" 2 "Large" 3 "Medium" 4 "Small"
    label values cat cat
    xtset cat age
    xtline survival, overlay  ///
        title("Survival by size", size(medium)) ytitle("Percent of firms surviving") ///
        xtitle("Age, year") 
    graph export "output/fig/fig4a.png", replace
    keep if inrange(age, 5, 30)
    xtline mean_growth, overlay  ///
        title("Firm growth by size", size(medium)) ytitle("Employment index (age 5 = 100)") ///
        xtitle("Age, year")
    graph export "output/fig/fig4b.png", replace
restore