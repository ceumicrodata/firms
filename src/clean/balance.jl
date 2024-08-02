using Kezdi

include("../functions.jl")
include("../consts.jl")

df = @use balance_input, clear
# this is necessary because `export` is a reserved word in Julia
df.Export = df.export

filtered = @with df begin
    @generate frame_id_numeric = parse_id(frame_id, originalid)
    @generate id_type = id_type(frame_id, originalid)

    @keep frame_id_numeric id_type year sales emp tanass Export egyebbev aktivalt ranyag wbill persexp kecs ereduzem pretax jetok immat teaor08_2d foundyear gdp tax ppi21 teaor08_1d county final_netgep so3_with_mo3 do3 fo3

    @replace emp = 0 @if ismissing(emp)
    @generate size_category = size_category(emp)
end

@with filtered begin
    @tabulate year size_category
end

Kezdi.writestat(balance_output, filtered)
