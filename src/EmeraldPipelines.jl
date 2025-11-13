module EmeraldPipelines

using Dates: month, today, year

using Emerald.EmeraldData.GlobalDatasets: LandDatasets, grid_dict
using Emerald.EmeraldData.WeatherDrivers: regrid_ERA5!
using Emerald.EmeraldIO.Folders: LAND_SETUP
using Emerald.EmeraldIO.Jld2: save_jld2!
using Emerald.EmeraldIO.Terminal: input_integer
using Emerald.EmeraldUtility.Log: @terror, @tinfo


# global constants
EARLIEST_ERA5_YEAR = 1980;


# steps to run the pipelines
include("weather-drivers/regrid.jl");
include("gridded-data/gmdicts.jl");


# function to run the global simulations
function run_global_simulations!(year::Int, nx::Int, gmv::Int)
    # regrid ERA5 data for the specific year
    regrid_ERA5!(year, nx);

    # prepare the grid JLD2 file
    prepare_grid_jld!("gm$(gmv)", year);
end;


end # module EmeraldPipelines
