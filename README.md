# firms

To run the code, first launch Julia *from within the folder*:

```bash
julia --project
```

Then, instantiate the environment:
```julia
] 
(firms) pkg> instantiate
```

Finally, run the code:
```julia
include("src/main.jl")
```

Path names are in `src/consts.jl`. Some of the logic is in `src/functions.jl`. 

The `@get` macro provides minimal caching, so if you edit `main.jl` to create different plots, you can rerun `include("src/main.jl")` without waiting for the data to be reloaded. If you touch the data cleaning code, too, you will need to quit Julia and start over.

```julia
@get data
```
will either load the variable `data` if it exists, or run the function `create_data()` to create it. See `create_balance_data()`, `create_balance_clean()` and `create_agg()` in `src/functions.jl` for the data cleaning steps.