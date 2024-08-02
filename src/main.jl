using Kezdi
using AlgebraOfGraphics, CairoMakie

include("consts.jl")
include("functions.jl")

agg = @get agg
bysize = @with agg begin
    @generate category = size_category
    @replace category = "foreign" @if ownership == "foreign"
    @replace category = "small" @if size_category == "micro"
    @drop @if ownership == "state"
    @collapse gdp = sum(gdp) emp = sum(emp), by(category, year)
    @generate gdp_per_worker = gdp / emp 
    @sort category year
end

set_aog_theme!()
axis = (width = 1000, height = 600)
plot = data(bysize) * mapping(:year, :gdp_per_worker, color = :category) * visual(Lines)
fig = draw(plot; axis = axis)
save("output/gdp_per_worker.png", fig, px_per_unit = 1)