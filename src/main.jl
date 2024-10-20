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
@target exim_temp = categorize_exim(balance)
@target lakmusz = aggregate(lakmusz_temp)
@target exim = aggregate(exim_temp)

function main()
    @get balance
    @with balance @tabulate year size_category @if exim == "medium"

    @get lakmusz
    exporters = @with lakmusz  begin
        @replace n_firms_export = missing @if year > 2017
        @replace export_share = missing @if year > 2017
        @generate exporter_share = n_firms_export / n_firms
    end

    @get exim
    exporters_exim = @with exim  begin
        @replace n_firms_export = missing @if year > 2017
        @replace export_share = missing @if year > 2017
        @generate exporter_share = n_firms_export / n_firms
    end

    set_aog_theme!()

    ts_plot(lakmusz, :n_firms)
    ts_plot(lakmusz, :sales_per_worker)
    ts_plot(lakmusz, :gdp_per_worker)
    ts_plot(exporters, :export_share, :year, "{:.1f}")
    ts_plot(exporters, :exporter_share, :year, "{:.1f}")
    ts_plot(exporters, :n_firms_export, :year, "{:.0f}")
    ts_plot(lakmusz, :n_new_firms)

    (@with exporters @keep @if category == "medium") |> CSV.write("output/lakmusz.csv", writeheader = true)
    (@with exporters_exim @keep @if category == "medium") |> CSV.write("output/exim.csv", writeheader = true)
end

main()