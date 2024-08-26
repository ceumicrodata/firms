using Kezdi
using Targets
using AlgebraOfGraphics, CairoMakie

include("consts.jl")
include("functions.jl")

@target balance_data = create_balance_data()
@target balance = clean_balance(balance_data)
@target agg = aggregate(balance)
@target survival = panel(balance)

function main()
    @get agg
    all = @with agg begin
        @generate category = size_category
        @replace category = "foreign" @if ownership == "foreign"
        @replace category = "state" @if ownership == "state"
        @collapse n_new_firms = sum(n_new_firms) gdp = sum(gdp) emp = sum(emp) sales = sum(sales) Export = sum(Export) n_firms = sum(n_firms) n_firms_export = sum(n_firms_export), by(category, year)
        @generate gdp_per_worker = gdp / emp 
        @generate export_share = Export / sales
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
    @get survival
    byage = @with survival begin
        @sort category age_in_balance
    end

    set_aog_theme!()

    function ts_plot(df::AbstractDataFrame, y::Symbol, t::Symbol = :year)
        axis = (width = 1000, height = 600)
        plot = data(df) * mapping(t, y, color = :category) * visual(Lines)
        fig = draw(plot; axis = axis)
        save("$(figure_folder)/$(y).png", fig, px_per_unit = 1)
    end

    fig1 = ts_plot(all, :n_firms)
    fig2 = ts_plot(bysize, :sales_per_worker)
    fig3 = ts_plot(bysize, :gdp_per_worker)
    fig4 = ts_plot(bysize, :export_share)
    fig5 = ts_plot(all, :n_firms_export)
    fig6 = ts_plot(all, :n_new_firms)
    fig7 = ts_plot(byage, :survival, :age_in_balance)
    fig8 = ts_plot(byage, :mean_growth, :age_in_balance)
end

main()