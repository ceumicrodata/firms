const balance_input = "input/merleg-LTS-2023/balance/balance_sheet_80_22.dta"
const balance_output = "temp/balance.dta"
const figure_folder = "output/fig"
const ceo_input = "input/ceo-panel/ceo-panel.dta"

# source: https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/eurofxref-graph-huf.en.html
const exchange_rate = Dict(
    2010 => 275.48,
    2011 => 279.37,
    2012 => 289.25,
    2013 => 296.86,
    2014 => 308.66,
    2015 => 310.02,
    2016 => 311.46,
    2017 => 309.19,
    2018 => 318.89,
    2019 => 325.28,
    2020 => 351.17,
    2021 => 358.54,
    2022 => 391.20,
)