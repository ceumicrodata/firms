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
        @collapse sales = sum(sales) emp = sum(emp) Export = sum(Export) gdp = sum(gdp), by(size_category, year) 
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

function create_balance()
    println("Loading balance data")
    balance_output |> Kezdi.readstat |> DataFrame
end

function create_agg()
    println("Aggregating balance data")
    _balance = @get balance
    aggregate(_balance)
end