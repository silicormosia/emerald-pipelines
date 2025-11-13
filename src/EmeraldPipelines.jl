module EmeraldPipelines

using Dates: month, today, year
using Distributed: pmap, @everywhere
using ProgressMeter: @showprogress

using Emerald.EmeraldData.GlobalDatasets: LandDatasets, grid_dict
using Emerald.EmeraldData.WeatherDrivers: ERA5SingleLevelsDriver, era5_weather_driver_file, regrid_ERA5!
using Emerald.EmeraldIO.Folders: LAND_SETUP
using Emerald.EmeraldIO.Jld2: read_jld2, save_jld2!
using Emerald.EmeraldUtility.Log: @terror, @tinfo, @twarn
using Emerald.EmeraldUtility.Threading: dynamic_workers!


# global constants
EARLIEST_ERA5_YEAR = 1980;


# steps to run the pipelines
include("weather-drivers/regrid.jl");
include("gridded-data/gmdicts.jl");
include("weather-drivers/grid.jl");


# function to run the global simulations
function run_global_simulations!(year::Int, nx::Int, gmv::Int)
    # regrid ERA5 data for the specific year
    regrid_ERA5!(year, nx);

    # prepare the grid JLD2 file
    prepare_grid_jld!("gm$(gmv)", year);
end;


end # module EmeraldPipelines
