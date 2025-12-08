# Emerald Pipelines

Pipelines to run Emerald model (remastered CliMA Land)

## Installation
```
pkg > add https://github.com/silicormosia/emerald-pipelines.git
```

## Run Global Simulations
At the moment we write this tutorial, we have only uploaded the weather drivers for the year 2019 for testing purpose. For details about the available datasets, please checkout the Zenodo archive at [![](https://zenodo.org/badge/DOI/10.5281/zenodo.17732092.svg)](https://doi.org/10.5281/zenodo.17732092)
```julia
using EmeraldPipelines
EmeraldPipelines.run_emerald_land!(2019);
```

## Customized Run
The `EmeraldPipelines.run_emerald_land!` function takes two parameters:
- `year::Int` An integer for year
- `settings::OrderedDict{String,Any}` A dictionary that stores the settings

Therefore, if you want to run the model using 200 cores in parallel, you may do this way:
```julia
using Emerald;
using EmeraldPipelines;
settings = Emerald.Land.land_model_settings();
settings["SIMU_THREADS"] = 200;
EmeraldPipelines.run_emerald_land!(2019, settings);
```
