@get ceos
old_firms = @with ceos begin
    @keep @if year == 2023
    @keep @if birth_year < 2025 - 60
    @keep @if founder == 1
    @collapse n_ceos = rowcount(birth_year), by(frame_id_numeric)
    @keep frame_id_numeric 
end 
@get balance
employment = @with balance begin
    @keep @if year == 2022
    @keep frame_id_numeric emp
end
@with innerjoin(employment, old_firms, on = :frame_id_numeric) begin
    s = @summarize emp
end
s.sum

#=

Summarize emp:
  N = 78878
  sum_w = 78878.0
  mean = 3.746101574583534
  Var = 354.4022741259705
  sd = 18.82557500120436
  skewness = 59.202842007905886
  kurtosis = 6696.089532645081
  sum = 295485.0
  min = 0.0
  max = 2703.0
  p1 = 0.0
  p5 = 0.0
  p10 = 0.0
  p25 = 0.0
  p50 = 1.0
  p75 = 3.0
  p90 = 8.0
  p95 = 15.0
  p99 = 48.0

295485.0

=#