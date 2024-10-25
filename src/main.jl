using Kezdi
using Targets
using AlgebraOfGraphics, CairoMakie

include("consts.jl")
include("functions.jl")

# input datasets
@target balance_data = create_balance_data()
@target ceo_data = create_ceo_data()

# cleaning
@target balance = clean_balance(balance_data)
@target ceos = ceo_demographics(ceo_data)

# aggregating by category
@target all_categories = categorize_all(balance)
@target size_categories = categorize_size(balance)
@target lakmusz_temp = categorize_size_only(balance)

@target all = aggregate(all_categories)
@target bysize = aggregate(size_categories)
@target lakmusz = aggregate(lakmusz_temp)

@target survival = panel(balance)


function main()
    @get all
    @get bysize
    @get survival
    @get ceos
    @get balance
    @get size_categories
    @get lakmusz
    joined = innerjoin(size_categories, ceos, on = [:frame_id_numeric, :year])
    byceo = @with joined begin
        @collapse mean_age = mean(age) older60 = mean(older60), by(category, year)
        @drop @if ismissing(category)
        @sort category year
    end
    byagepyr13 = @with ceos begin
        @keep @if year == 2013
        @collapse n_ceos = rowcount(age), by(age, gender)
        @rename age age2013
    end
    byagepyr23 = @with ceos begin
        @keep @if year == 2023
        @collapse n_ceos = rowcount(age), by(age, gender)
        @rename age age2023
    end
    exporters = @with all begin
        @keep @if year <= 2017
        @generate exporter_share = n_firms_export / n_firms
    end
    bycat = @with all begin 
        @generate category_1 = category
        @replace category_1 = "" @if (category_1 == "micro domestic")
        @generate category_2 = ""
        @replace category_2 = category @if (category == "micro domestic")
        @collapse n_firms_cat = sum(n_firms) n_new_firms_cat = sum(n_new_firms), by(year, category, category_1, category_2)
        @sort year category category_1 category_2 
    end

    set_aog_theme!()

    fig1 = ts_plot_dy(bycat, :n_firms_cat)
    fig2 = ts_plot(bysize, :sales_per_worker)
    fig3 = ts_plot(bysize, :gdp_per_worker)
    fig4 = ts_plot((@with bysize @keep @if year <= 2017), :export_share, :year, "{:.1f}")
    fig5 = ts_plot(exporters, :exporter_share, :year, "{:.1f}")
    fig6 = ts_plot_dy(bycat, :n_new_firms_cat)
    fig7 = ts_plot(survival, :survival, :age_in_balance, "{:.0f}", 0:5:40)
    fig8 = ts_plot(survival, :mean_growth, :age_in_balance, "{:.0f}", 0:5:40)
    fig9 = ts_plot((@with byceo @keep @if year >= 2013), :mean_age)
    fig10 = histogram(byagepyr13, :age2013, :n_ceos)
    fig102 = histogram(byagepyr23, :age2023, :n_ceos)
    fig11 = ts_plot((@with byceo @keep @if year >= 2013), :older60, :year, :"{:.1f}")

    lakmusz |> CSV.write("output/lakmusz.csv", writeheader = true)
end

main()