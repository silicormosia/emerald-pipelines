# Emerald Pipelines

Pipelines to run Emerald model (remastered CliMA Land)


## Download and Process ERA5 data (weather drivers for Emerald and CliMA Land)
1. Install cdsapi following `ERA5/0-setting.py`
2. Run `ERA5/1-download.py` to download ERA5 data (better to use default folder to work with Emerld)
3. Run `ERA5/2-regrid.jl` to reprocess ERA5 data (better to use default folder to work with Emerld)


## Download the MODIS MOD09A1 and MYD09A1 data to generate Emerlad LAI and CHL
1. Run `MODIS/1-download.py` to download MODIS data (better to use default folder to work with Emerld)
