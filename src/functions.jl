left(text::AbstractString, n::Int) = n > 0 ? text[1:min(n, end)] : text[1:end-min(-n, end)]
right(text::AbstractString, n::Int) = n > 0 ? text[end-min(n, end)+1:end] : text[min(-n, end)+1:end]

function size_category(size::Number)
    size < 10 && return "micro"
    size < 50 && return "small"
    size < 250 && return "medium"
    return "large"
end

function age_bin(age::Number)
    age < 6 && return 1
    age < 11 && return 2
    age < 16 && return 3
    age < 21 && return 4
    age < 26 && return 5
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

function aggregate(df::AbstractDataFrame)
    @with df begin
        @replace sales = sales / ppi21
        @replace gdp = gdp / ppi21
        @replace Export = Export / ppi21
        @replace Export = 0 @if ismissing(Export)
        @egen first_balance = minimum(year), by(frame_id_numeric)
        @collapse sales = sum(sales) emp = sum(emp) Export = sum(Export) gdp = sum(gdp) n_firms = rowcount(distinct(frame_id_numeric)) n_firms_export = sum(Export > 0) n_new_firms = sum(year == first_balance), by(size_category, ownership, year) 
    end
end

function panel(df::AbstractDataFrame)
    @with df begin
        @generate category = size_category
        @replace category = "foreign" @if ownership == "foreign"
        @replace category = "small" @if size_category == "micro"
        @drop @if ownership == "state"
        @replace sales = sales / ppi21
        @replace gdp = gdp / ppi21
        @replace Export = Export / ppi21
        @replace Export = 0 @if ismissing(Export)
        @egen max_emp_5 = maximum(cond(firmage <= 5, emp, 0)), by(frame_id_numeric)
        @generate growth = emp / max_emp_5
        @egen first_balance = minimum(year), by(frame_id_numeric)
        @generate age_in_balance = year - first_balance + 1
        @collapse mean_growth = mean(growth) n_firms = rowcount(distinct(frame_id_numeric)), by(category, age_in_balance) 
        @egen max_n = maximum(cond(age_in_balance == 1, n_firms, 0)), by(category)
        @generate survival = 100 * n_firms / max_n
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

        @keep frame_id_numeric originalid id_type year sales emp tanass Export egyebbev aktivalt ranyag wbill persexp kecs ereduzem pretax jetok immat teaor08_2d foundyear firmage gdp tax ppi21 teaor08_1d county final_netgep so3_with_mo3 do3 fo3
    
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
