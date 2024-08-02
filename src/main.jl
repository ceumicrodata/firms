using Kezdi
using AlgebraOfGraphics, CairoMakie

include("consts.jl")
include("functions.jl")

agg = @get agg
all = @with agg begin
    @generate category = size_category
    @replace category = "foreign" @if ownership == "foreign"
    @replace category = "state" @if ownership == "state"
    @collapse gdp = sum(gdp) emp = sum(emp) sales = sum(sales) Export = sum(Export) n_firms = sum(n_firms), by(category, year)
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
    @generate export_share = Export / sales
    @sort category year
end

set_aog_theme!()

function ts_plot(df::AbstractDataFrame, y::Symbol)
    axis = (width = 1000, height = 600)
    plot = data(df) * mapping(:year, y, color = :category) * visual(Lines)
    fig = draw(plot; axis = axis)
    save("$(figure_folder)/$(y).png", fig, px_per_unit = 1)
end

ts_plot(all, :n_firms)
ts_plot(bysize, :gdp_per_worker)
ts_plot(bysize, :export_share)