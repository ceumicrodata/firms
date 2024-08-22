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

function locf(x::Array{Float64})
    dx = zeros(x)
    for i in 2:length(x)-1
        if x[i+1] > 0 && x[i] == 0.0
            dx[i+1] = x[i+1]
        end
            if dx[i] == 0 
                dx[i] = dx[i-1]
            end
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
        @egen max_emp_5 = max(cond(firmage <= 5, emp, 0)), by(frame_id_numeric)
        @generate growth = emp / max_emp_5
        @egen first_balance = min(year), by(frame_id_numeric)
        @egen firmage2 = year - first_balance
        @replace firmage2 = firmage2 + 1
        @egen firm_start = firmage2 @if firmage==1
        @egen lemp = log(emp)
        @egen flemp = log(emp) @if first_balance == year
        #na_locf = locf(flemp)
        @egen hlemp = lemp - flemp
        @collapse mean_growth = mean(growth) firm_start = sum(firm_start) sales = sum(sales) emp = sum(emp) Export = sum(Export) gdp = sum(gdp) n_firms = rowcount(distinct(frame_id_numeric)) n_firms_export = rowcount(distinct(Export)) max_emp_5 = sum(max_emp_5) hlemp = mean(hlemp) n_firms_age = rowcount(distinct(firmage2)), by(size_category, ownership, year) 
    end
end

function aggregate_survival(df::AbstractDataFrame)
    @with df begin
        @egen first_balance = min(year), by(frame_id_numeric)
        @egen firmage2 = year - first_balance
        @replace firmage2 = firmage2 + 1
        @collapse n_firms = rowcount(distinct(frame_id_numeric)), by(firmage2, size_category, ownership, year)
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

        @keep frame_id_numeric id_type year sales emp tanass Export egyebbev aktivalt ranyag wbill persexp kecs ereduzem pretax jetok immat teaor08_2d foundyear firmage gdp tax ppi21 teaor08_1d county final_netgep so3_with_mo3 do3 fo3
    
        @replace emp = 0 @if ismissing(emp)
        @generate size_category = size_category(emp)
    
        @generate ownership = "foreign" @if fo3 == 1
        @replace ownership = "state" @if so3_with_mo3 == 1
        @replace ownership = "domestic" @if ismissing(ownership)
    end
end
