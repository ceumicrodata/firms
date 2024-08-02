left(text::AbstractString, n::Int) = n > 0 ? text[1:min(n, end)] : text[1:end-min(-n, end)]
right(text::AbstractString, n::Int) = n > 0 ? text[end-min(n, end)+1:end] : text[min(-n, end)+1:end]

function size_category(size::Number)
    size < 10 && return "micro"
    size < 50 && return "small"
    size < 250 && return "medium"
    return "large"
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
        @collapse sales = sum(sales) emp = sum(emp) Export = sum(Export) gdp = sum(gdp), by(size_category, ownership, year) 
    end
end

mvreplace(x, y) = ismissing(x) ? y : x

# only load data if not yet loaded
macro get(x)
    quote
        if isdefined($(__module__), $(QuoteNode(x)))
            $(esc(x))
        else
            $(esc(x)) = $(esc(Symbol("create_", x)))()
        end
    end
end

function create_balance_data()
    println("Loading balance data")
    balance_input |> Kezdi.readstat |> DataFrame
end

function create_balance_clean()
    println("Cleaning balance data")
    df = @get balance_data
    # this is necessary because `export` is a reserved word in Julia
    df.Export = df.export
    
    @with df begin
        @generate frame_id_numeric = parse_id(frame_id, originalid)
        @generate id_type = id_type(frame_id, originalid)
    
        @keep frame_id_numeric id_type year sales emp tanass Export egyebbev aktivalt ranyag wbill persexp kecs ereduzem pretax jetok immat teaor08_2d foundyear gdp tax ppi21 teaor08_1d county final_netgep so3_with_mo3 do3 fo3
    
        @replace emp = 0 @if ismissing(emp)
        @generate size_category = size_category(emp)
    
        @generate ownership = "foreign" @if fo3 == 1
        @replace ownership = "state" @if so3_with_mo3 == 1
        @replace ownership = "domestic" @if ismissing(ownership)
    end
end

function create_agg()
    println("Aggregating balance data")
    balance = @get balance_clean
    aggregate(balance)
end