using Kezdi
using Targets
using AlgebraOfGraphics, CairoMakie

include("consts.jl")
include("functions.jl")

@target balance_data = create_balance_data()
@target balance = clean_balance(balance_data)
@target agg = aggregate(balance)
@target aggregate_survival = aggregate_survival(balance)

function main()
    @get agg
    all = @with agg begin
        @generate category = size_category
        @replace category = "foreign" @if ownership == "foreign"
        @replace category = "state" @if ownership == "state"
        @collapse mean_growth = sum(mean_growth) firm_start = sum(firm_start) gdp = sum(gdp) emp = sum(emp) sales = sum(sales) Export = sum(Export) n_firms = sum(n_firms) n_firms_export = sum(n_firms_export) hlemp = sum(hlemp) n_firms_age = sum(n_firms_age), by(category, year)
        @generate gdp_per_worker = gdp / emp 
        @generate export_share = Export / sales
        @egen max_n = max(cond(n_firms_age == 0, n_firms, 0))
        @generate survival = 100 * n_firms / max_n
        @sort category year
    end
    bysize = @with agg begin
        @generate category = size_category
        @replace category = "foreign" @if ownership == "foreign"
        @replace category = "small" @if size_category == "micro"
        @drop @if ownership == "state"
        @collapse gdp = sum(gdp) emp = sum(emp) sales = sum(sales) Export = sum(Export), by(category, year)
        @generate gdp_per_worker = gdp / emp 
        @generate sales_per_worker = sales / emp 
        @generate export_share = Export / sales
        @sort category year
    end
    @get aggregate_survival
    allsurv = @with aggregate_survival begin
        @generate category = size_category
        @egen max_n = max(cond(firmage2 == 1, n_firms, 0)), by(category)
        @generate survival = 100 * n_firms / max_n
    end

    set_aog_theme!()

    function ts_plot(df::AbstractDataFrame, y::Symbol)
        axis = (width = 1000, height = 600)
        plot = data(df) * mapping(:year, y, color = :category) * visual(Lines)
        fig = draw(plot; axis = axis)
        save("$(figure_folder)/$(y).png", fig, px_per_unit = 1)
    end

    fig1 = ts_plot(all, :n_firms)
    fig2 = ts_plot(bysize, :sales_per_worker)
    fig3 = ts_plot(bysize, :gdp_per_worker)
    fig4 = ts_plot(bysize, :export_share)
    fig5 = ts_plot(all, :n_firms_export)
    fig6 = ts_plot(all, :firm_start)
    fig7 = ts_plot(allsurv, :survival)
    fig8 = ts_plot(all, :mean_growth)
end

main()