* Create a dataset with the enterprise categories and counts
clear
set obs 4

* Generate variables for enterprise categories and counts
gen category = ""
gen count = .
gen count_formatted = ""

* Fill in the data
replace category = "Large enterprises (250+)" in 1
replace count = 1000 in 1
replace count_formatted = "1,000" in 1

replace category = "Medium enterprises (50-249)" in 2
replace count = 5200 in 2
replace count_formatted = "5,200" in 2

replace category = "Small enterprises (10-49)" in 3
replace count = 33000 in 3
replace count_formatted = "33,000" in 3

replace category = "Micro enterprises (0-9)" in 4
replace count = 460000 in 4
replace count_formatted = "460,000" in 4

* Create a log scale version of count for better visualization
gen logcount = log10(count)

* Sort by size (ascending)
sort count

* Create a horizontal bar chart
graph hbar (asis) count, over(category, sort(count) descending) ///
  title("Hungarian Enterprises by Size Category (January 2025)") ///
  subtitle("Number of incorporated businesses") ///
  note("Source: KSH") ///
  blabel(bar, format(%9.0fc) position(outside) size(medium)) ///
  ylabel(, format(%9.0fc)) ///
  bar(1) ///
  yscale(range(0 500000)) ///
  ytitle("Number of enterprises")

* For a log scale visualization (optional - uncomment if needed)
/*
graph hbar (asis) logcount, over(category, sort(count) descending) ///
  title("Hungarian Enterprises by Size Category (January 2025)") ///
  subtitle("Number of incorporated businesses (log scale)") ///
  note("Source: Hungarian business registry") ///
  blabel(bar, format(%9.2f) position(inside) color(white) size(medium)) ///
  ylabel(0(1)6, valuelabel) ///
  ymlabel(0 "1" 1 "10" 2 "100" 3 "1,000" 4 "10,000" 5 "100,000" 6 "1,000,000") ///
  scheme(s2color) ///
  bar(1, color("59 76 192")) ///
  ytitle("Number of enterprises (log scale)")
*/

* Export the graph
graph export "output/fig/fig0.png", replace width(1040)