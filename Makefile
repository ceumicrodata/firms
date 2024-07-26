JULIA := julia --project -p8

temp/balance.arrow: src/clean/balance.jl input/merleg-LTS-2022/balance/balance_sheet_80_21.dta
	$(JULIA) $<
bead:
	mkdir -p input/
	mkdir -p output/
	mkdir -p temp/
	bead input unload
	bead input load