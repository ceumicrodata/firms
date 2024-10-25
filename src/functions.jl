left(text::AbstractString, n::Int) = n > 0 ? text[1:min(n, end)] : text[1:end-min(-n, end)]
right(text::AbstractString, n::Int) = n > 0 ? text[end-min(n, end)+1:end] : text[min(-n, end)+1:end]

function size_category(size::Number)
    size < 10 && return "micro"
    size < 50 && return "small"
    size < 250 && return "medium"
    return "large"
end

function age_bin(age::Number)
    age < 7 && return 1
    age < 12 && return 2
    age < 17 && return 3
    age < 22 && return 4
    age < 27 && return 5
    return 6
end

function locf(x::Vector{Float64})
    dx = similar(x)
    last_nonzero = 0.0
    for i in eachindex(x)
        if !iszero(x[i])
            last_nonzero = x[i]
        end
        dx[i] = last_nonzero
    end
    return dx
end
    
function parse_id(frame_id::AbstractString, originalid::Number)
    left(frame_id, 1) == "f" && return parse(Int64, right(frame_id, -2))
    originalid > 0 && return originalid
    return -originalid
end

function id_type(frame_id::AbstractString, originalid::Number)
    left(frame_id, 2) == "ft" && return "ft"
    left(frame_id, 2) == "fc" && return "fc"
    originalid > 0 && return "originalid"
    return "negative"
end

function categorize_all(df::AbstractDataFrame)
    @with df begin
        @generate category = size_category * " domestic"
        @replace category = "foreign" @if ownership == "foreign"
        @replace category = "state" @if ownership == "state"
    end
end

function categorize_size(df::AbstractDataFrame)
    @with df begin
        @replace size_category = "small" @if size_category == "micro"
        @generate category = size_category * " domestic"
        @replace category = "foreign" @if ownership == "foreign"
        @drop @if ownership == "state"
    end
end

function categorize_size_only(df::AbstractDataFrame)
    @with df begin
        @rename size_category category
        # Lakmusz defines exporter as 10% of sales
        @replace Export = 0 @if Export < 0.1 * sales
    end
end

function aggregate(df::AbstractDataFrame)
    @with df begin
        @replace sales = sales / ppi22
        @replace gdp = gdp / ppi22
        @replace Export = Export / ppi22
        @replace Export = 0 @if ismissing(Export)
        @egen first_balance = minimum(year), by(frame_id_numeric)
        @collapse sales = sum(sales) emp = sum(emp) Export = sum(Export) gdp = sum(gdp) n_firms = rowcount(distinct(frame_id_numeric)) n_firms_export = sum(Export > 0) n_new_firms = sum(year == first_balance), by(category, year) 
        @generate gdp_per_worker = gdp / emp 
        @generate sales_per_worker = sales / emp 
        @generate export_share = Export / sales
        @sort category year
    end
end

function panel(df::AbstractDataFrame)
    @with categorize_size(df) begin
        @replace sales = sales / ppi22
        @replace gdp = gdp / ppi22
        @replace Export = Export / ppi22
        @replace Export = 0 @if ismissing(Export)
        @egen max_emp_5 = maximum(cond(firmage <= 5, emp, 0)), by(frame_id_numeric)
        @generate growth = emp / max_emp_5
        @egen first_balance = minimum(year), by(frame_id_numeric)
        @generate age_in_balance = year - first_balance + 1
        @collapse mean_growth = mean(growth) n_firms = rowcount(distinct(frame_id_numeric)), by(category, age_in_balance) 
        @egen max_n = maximum(cond(age_in_balance == 1, n_firms, 0)), by(category)
        @generate survival = 100 * n_firms / max_n
        @sort category age_in_balance
    end
end

mvreplace(x, y) = ismissing(x) ? y : x

function create_balance_data()
    balance_input |> Kezdi.readstat |> DataFrame
end

function clean_balance(df::AbstractDataFrame)
    # this is necessary because `export` is a reserved word in Julia
    df.Export = df.export
    
    @with df begin
        @generate frame_id_numeric = parse_id(frame_id, originalid)
        @generate id_type = id_type(frame_id, originalid)
        @drop @if teaor08_1d == "K" || teaor03_1d == "J"
        @replace fo3=1 @if frame_id_numeric==13113267

        @keep frame_id_numeric originalid id_type year sales emp tanass Export egyebbev aktivalt ranyag wbill persexp kecs ereduzem pretax jetok immat teaor08_2d foundyear firmage gdp tax ppi22 teaor08_1d county final_netgep so3_with_mo3 do3 fo3
    
        @replace emp = 0 @if ismissing(emp)
        @generate size_category = size_category(emp)
    
        @generate ownership = "foreign" @if fo3 == 1
        @replace ownership = "state" @if so3_with_mo3 == 1
        @replace ownership = "domestic" @if ismissing(ownership)
    end
end

function isstrategic(frame_id::Number)
    frame_id in strategic_partnership
end

function create_ceo_data()
    ceo_input |> Kezdi.readstat |> DataFrame
end

function ceo_demographics(df::AbstractDataFrame)
    @with df begin
        @drop @if year < 2010
        @drop @if ismissing(birth_year)
        @generate gender = "Male" @if male == 1
        @replace gender = "Female" @if male == 0
        @generate age = year - birth_year
        @generate older60 = age > 60
        @drop @if age < 18 || age > 90
    end
end

function ts_plot(df::AbstractDataFrame, y::Symbol, t::Symbol = :year, ytickformatvar::String = :"{:.0f}", xticksvar::StepRange = :1980:2:2022) 
    axis = (width = 1000, height = 600, 
    ytickformat = ytickformatvar, 
    xtickwidth = 1, 
    #xminorticks = IntervalsBetween(3), 
    xminorticksvisible = true, 
    xminorgridvisible = true,
    xgridvisible = true,
    xtickformat = "{:.0f}", 
    xticks = xticksvar)
    plot = data(df) * mapping(t, y, color = :category) * visual(Lines,
    linewidth = 4)
    fig = draw(plot; axis = axis)
    save("$(figure_folder)/$(y).png", fig, px_per_unit = 1)
end

function histogram(df::AbstractDataFrame, y::Symbol, weight::Symbol = :n_ceos)
    axis = (width = 1000, height = 600,
    ytickformat = "{:.0f}", 
    xtickwidth = 1, 
    #xminorticks = IntervalsBetween(3), 
    #xminorticksvisible = true, 
    #xminorgridvisible = true,
    xtickformat = "{:.0f}", 
    xticks = 0:5:100)
    plot = data(df) * mapping(y, weight, color = :gender, dodge = :gender) * visual(
        BarPlot, 
        alpha = 0.1)
    fig = draw(plot; axis = axis)
    save("$(figure_folder)/$(y).png", fig, px_per_unit = 1)
end

function ts_plot_dy(df::AbstractDataFrame, y::Symbol, t::Symbol = :year, ytickformatvar::String = :"{:.0f}", xticksvar::StepRange = :1980:2:2022) 
    axis = (width = 1000, height = 600, 
    ytickformat = ytickformatvar, 
    xtickwidth = 1, 
    xminorticksvisible = true, 
    xminorgridvisible = true,
    xgridvisible = true,
    xtickformat = "{:.0f}",
    xticks = xticksvar)
    layer_1 = data(df) * mapping(t, y, color = :category, layout = :category_2) * visual(Lines, linewidth = 4)
    fig = draw(layer_1; axis = axis, facet = (; linkxaxes = :none, linkyaxes = :none))
    save("$(figure_folder)/$(y).png", fig, px_per_unit = 1)
end