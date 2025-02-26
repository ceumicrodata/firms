clear all
import delimited "output/all.csv", case(preserve)

preserve
    replace category = "domestic" if !inlist(category, "state", "foreign")
    collapse (sum) emp n_firms, by(category year)
    label variable n_firms "Number of firms"
    encode category, gen(cat)
    xtset cat year
    xtline n_firms, overlay  ///
        title("Number of firms by owner", size(medium)) ytitle("Number of firms") ///
        xtitle("Year") 
    graph export "output/fig/fig1a.png", replace
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