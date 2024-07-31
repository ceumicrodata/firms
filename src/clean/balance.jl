using Kezdi
using Arrow

left(text::AbstractString, n::Int) = n > 0 ? text[1:min(n, end)] : text[1:end-min(-n, end)]
right(text::AbstractString, n::Int) = n > 0 ? text[end-min(n, end)+1:end] : text[min(-n, end)+1:end]

df = @use "input/merleg-LTS-2022/balance/balance_sheet_80_21.dta", clear
# this is necessary because `export` is a reserved word in Julia
df.Export = df.export

filtered = @with df begin
    @generate frame_id_numeric = parse(Int64, right(frame_id, -2)) @if left(frame_id, 1) == "f"
    @replace frame_id_numeric = originalid @if ismissing(frame_id_numeric) && originalid > 0
    @replace frame_id_numeric = -originalid @if ismissing(frame_id_numeric) && originalid < 0

    @generate id_type = 1 @if left(frame_id, 2) == "ft"
    @replace id_type = 2 @if left(frame_id, 2) == "fc"
    @replace id_type = 3 @if ismissing(id_type) && originalid > 0
    @replace id_type = 4 @if ismissing(id_type) && originalid < 0

    @keep frame_id_numeric id_type year sales emp tanass Export egyebbev aktivalt ranyag wbill persexp kecs ereduzem pretax jetok immat teaor08_2d foundyear gdp tax ppi21 teaor08_1d county final_netgep so3_with_mo3 do3 fo3
end

# TODO: save as .dta
Arrow.write("temp/balance.arrow", filtered)
