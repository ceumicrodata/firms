using Kezdi
using AlgebraOfGraphics, CairoMakie

include("functions.jl")
include("consts.jl")

agg = @get agg
bysize = @with agg begin
    @generate gdp_per_worker = gdp / emp 
    @keep @if year >= 1991
end

set_aog_theme!()
axis = (width = 1000, height = 600)
plot = data(bysize) * mapping(:year, :gdp_per_worker, color = :size_category)
draw(plot; axis = axis)
