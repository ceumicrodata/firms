using Kezdi
using Targets
using AlgebraOfGraphics, CairoMakie

include("consts.jl")
include("functions.jl")

# input datasets
@target balance_data = create_balance_data()

# cleaning
@target balance = clean_balance(balance_data)

# aggregating by category
@target lakmusz_temp = categorize_size_only(balance)
@target lakmusz = aggregate(lakmusz_temp)


function main()
    @get lakmusz
    exporters = @with lakmusz  begin
        @keep @if year <= 2017
        @generate exporter_share = n_firms_export / n_firms
    end

    set_aog_theme!()

    fig1 = ts_plot(lakmusz, :n_firms)
    fig2 = ts_plot(lakmusz, :sales_per_worker)
    fig3 = ts_plot(lakmusz, :gdp_per_worker)
    fig4 = ts_plot(exporters, :export_share, :year, "{:.1f}")
    fig5 = ts_plot(exporters, :exporter_share, :year, "{:.1f}")
    fig6 = ts_plot(lakmusz, :n_new_firms)

    lakmusz |> CSV.write("output/lakmusz.csv", writeheader = true)
end

main()