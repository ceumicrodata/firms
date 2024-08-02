JULIA := julia --project -p8
LIB := src/functions.jl

temp/balance.dta: src/clean/balance.jl input/merleg-LTS-2022/balance/balance_sheet_80_21.dta $(LIB)
	$(JULIA) $< > balance.log
bead:
	mkdir -p input/
	mkdir -p output/
	mkdir -p temp/
	bead input unload
	bead input load