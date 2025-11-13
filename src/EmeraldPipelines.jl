module EmeraldPipelines

using Dates: month, today, year
using Distributed: pmap, @everywhere
using OrderedCollections: OrderedDict
using ProgressMeter: @showprogress

using Emerald.EmeraldData.GlobalDatasets: LandDatasets, grid_dict
using Emerald.EmeraldData.WeatherDrivers: ERA5SingleLevelsDriver, era5_weather_driver_file, grid_weather_driver, regrid_ERA5!
using Emerald.EmeraldFrontier: grid_spac, simulation!, spac_config
using Emerald.EmeraldIO.Folders: LAND_CACHE, LAND_SETUP
using Emerald.EmeraldIO.Jld2: read_jld2, save_jld2!
using Emerald.EmeraldLand.SPAC: initialize_spac!
using Emerald.EmeraldUtility.Log: @terror, @tinfo, @twarn
using Emerald.EmeraldUtility.Threading: dynamic_workers!


# global constants
EARLIEST_ERA5_YEAR = 1980;


# steps to run the pipelines
include("config/dict.jl");
include("weather-drivers/regrid.jl");
include("gridded-data/gmdicts.jl");
include("weather-drivers/grid.jl");
include("simulations/thread.jl");
include("simulations/global.jl");


# function to run the global simulations
function run_emerald_land!(year::Int, config::OrderedDict{String,Any} = emerald_land_config()) :: Nothing
    # 1. regrid ERA5 data for the specific year
    println();
    @tinfo "Regridding ERA5 data for year $year...";
    regrid_ERA5!(year, config["NX"]);

    # 2. prepare the grid JLD2 file to determine where to run simulations
    println();
    @tinfo "Preparing grid JLD2 file for year $year...";
    prepare_grid_jld!(year, config);

    # 3. prepare the weather drivers for all grid cells within the JLD2 file
    println();
    @tinfo "Preparing weather drivers for year $year...";
    prepare_weather_drivers!(year, config);

    # run the global simulations in parallel
    println();
    @tinfo "Running global simulations for year $year...";
    global_simulations!(year, config);
end;


end # module EmeraldPipelines
