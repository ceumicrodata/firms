using Kezdi
using Targets
using AlgebraOfGraphics, CairoMakie

include("consts.jl")
include("functions.jl")

@target balance_data = create_balance_data()
@target balance = clean_balance(balance_data)
@target agg = aggregate(balance)
@target survival = panel(balance)

@target ceo_data = create_ceo_data()
#@target ceo = clean_ceo(ceo_data)

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
    @get ceo_data
    @get balance
    joined = outerjoin(balance, ceo_data, on = [:frame_id_numeric, :year])
    byceo = @with joined begin
        @drop @if ismissing(birth_year)
        @generate category = size_category
        @replace category = "foreign" @if ownership == "foreign"
        @replace category = "small" @if size_category == "micro"
        @drop @if ownership == "state"
        @collapse mean_birth_year = mean(birth_year), by(category, year)
        @drop @if ismissing(category)
        @sort category year
    end
    byagepyr13 = @with joined begin
        @drop @if ismissing(birth_year)
        @generate sex = male
        @replace sex = "Male" @if sex==1
        @replace sex = "Female" @if sex==0
        @keep @if year==2013
        @egen ceo_age2013 = 2013-birth_year
        @drop @if ceo_age2013 <10 || ceo_age2013>90
        @collapse n_ceo_age2013 = rowcount(ceo_age2013), by(ceo_age2013, sex)
    end
    byagepyr21 = @with joined begin
        @drop @if ismissing(birth_year)
        @generate sex = male
        @replace sex = "Male" @if sex==1
        @replace sex = "Female" @if sex==0
        @egen ceo_age2021 = 2021-birth_year
        @keep @if year==2021
        @drop @if ceo_age2021 <10 || ceo_age2021>90
        @collapse n_ceo_age2021 = rowcount(ceo_age2021), by(ceo_age2021, sex)
    end
    byageretire = @with joined begin
        @drop @if ismissing(birth_year)
        @generate category = size_category
        @replace category = "foreign" @if ownership == "foreign"
        @replace category = "small" @if size_category == "micro"
        @egen ceo_age = 2021-birth_year
        @egen ceo_age60 = ceo_age>=60
        @collapse num_total = rowcount(ceo_age) num_age_60 = sum(ceo_age60), by(category, year)
        @drop @if ismissing(category)
        @generate age_60_ratio = num_age_60 / num_total
        @sort category year
    end

    set_aog_theme!()

    function ts_plot(df::AbstractDataFrame, y::Symbol, t::Symbol = :year)
        axis = (width = 1000, height = 600)
        plot = data(df) * mapping(t, y, color = :category) * visual(Lines)
        fig = draw(plot; axis = axis)
        save("$(figure_folder)/$(y).png", fig, px_per_unit = 1)
    end

    function ts_plot2(df::AbstractDataFrame, y::Symbol)
        axis = (width = 1000, height = 600)
        plot = data(df) * mapping(y, color = :sex) * visual(BarPlot)
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
    fig9 = ts_plot(byceo, :mean_birth_year)
    fig10 = ts_plot2(byagepyr13, :n_ceo_age2013)
    fig102 = ts_plot2(byagepyr21, :n_ceo_age2021)
    fig11 = ts_plot(byageretire, :age_60_ratio)
end

main()