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
- `setting::OrderedDict{String,Any}` A dictionary that stores the settings

By default, `setting` was defined as (as of 2025-12-06, changes pending)
```julia
OrderedDict{String,Any}(
        # Emerald version
        "EMERALD_VERSION"   => "b01",
        "CONFIG_TAG"        => "default",

        # general settings
        "FT"                => Float64,
        "NX"                => 1,
        "GM_VERSION"        => "gm2",
        "WD_VERSION"        => "wd1",

        # threading settings
        "GRID_THREADS"      => 40,
        "SIMU_THREADS"      => 480,
        "REMOVE_WHEN_DONE"  => true,

        # saving settings related to the global NetCDF output files
        "VARIABLES_TO_COMBINE" => String["GPP", "ET", "SIF740"],
);
```

Therefore, if you want to run the model using 200 cores in parallel, you may do this way:
```julia
using EmeraldPipelines
settings = EmeraldPipelines.emerald_land_config();
settings["SIMU_THREADS"] = 200;
EmeraldPipelines.run_emerald_land!(2019, settings);
```
