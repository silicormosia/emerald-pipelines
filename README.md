# Emerald Pipelines

Pipelines to run Emerald model (remastered CliMA Land). For video tutorials, please visit:

## Installation
To install the stable release, do:
```
pkg > add https://github.com/silicormosia/emerald-pipelines.git
```

To install the developing release (e.g., wyujie branch), do
```
pkg > add https://github.com/silicormosia/emerald-pipelines.git#wyujie
```


## Run Global Simulations (testing mode)
At the moment we write this tutorial, we have only uploaded the weather drivers for the year 2019 for testing purpose.
For details about the available datasets, please checkout the Zenodo archive at [![](https://zenodo.org/badge/DOI/10.5281/zenodo.17732092.svg)](https://doi.org/10.5281/zenodo.17732092)

To run the model, do:
```
using EmeraldPipelines;
EmeraldPipelines.run_emerald_land!(2019);
```
The code above will run the Emerald model at the global scale for 24 hours (day 181).

## Run Global Simulations (user defining mode)
The `EmeraldPipelines.run_emerald_land!` function takes two parameters:
- `year` An integer for year
- `settings` A dictionary that stores the settings (default at testing mode)

Therefore, if you want to run the model using 200 cores in parallel for the entire year, you may do this way:
```
using Emerald;
using EmeraldPipelines;

settings = Emerald.Land.land_model_settings();
settings["SIMU_THREADS"] = 200;
settings["SIMULATION_PERIOD"] = :;

EmeraldPipelines.run_emerald_land!(2019, settings);
```

For more details, of course, read the code (Emerald and EmeraldPipeline)...
