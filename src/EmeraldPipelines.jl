module EmeraldPipelines

using Dates: isleapyear, month, today, year
using Distributed: pmap, @everywhere
using OrderedCollections: OrderedDict
using ProgressMeter: @showprogress

using EmeraldUtilities.DistributedTools: dynamic_workers!
using EmeraldUtilities.PrettyDisplay: pretty_display!
using EmeraldUtilities.MathTools: resample_data
using NetcdfIO: append_nc!, create_nc!, read_nc

using Emerald.EmeraldData.GlobalDatasets: LandDatasets, grid_dict
using Emerald.EmeraldData.WeatherDrivers: ERA5SingleLevelsDriver, era5_weather_driver_file, grid_file_path, grid_weather_driver, regrid_ERA5!
using Emerald.EmeraldFrontier: grid_spac, simulation!, spac_config
using Emerald.EmeraldIO.Folders: LAND_CACHE, LAND_RESULT, LAND_SETUP
using Emerald.EmeraldIO.Jld2: read_jld2, save_jld2!
using Emerald.EmeraldLand.SPAC: initialize_spac!


# global constants
EARLIEST_ERA5_YEAR = 1980;


# steps to run the pipelines
include("config/attributes.jl");
include("config/dict.jl");
include("config/filenames.jl");

include("gridded-data/gmdicts.jl");

include("weather-drivers/regrid.jl");
include("weather-drivers/grid.jl");

include("log/failed.jl");

include("simulations/thread.jl");
include("simulations/global.jl");
include("simulations/combine.jl");
include("simulations/resample.jl");


# function to run the global simulations
function run_emerald_land!(year::Int, config::OrderedDict{String,Any} = emerald_land_config()) :: Nothing
    # 1. prepare the grid JLD2 file to determine where to run simulations
    println();
    prepare_grid_jld!(year, config);

    # 2. regrid ERA5 data for the specific year
    println();
    regrid_ERA5!(year, config["NX"]);

    # 3. prepare the weather drivers for all grid cells within the JLD2 file
    println();
    prepare_weather_drivers!(year, config);

    # 4. run the global simulations in parallel
    println();
    global_simulations!(year, config);

    # 5. combine all simulation results into a single NetCDF file
    println();
    combine_cache_files!(year, config);

    # 6. resample the global simulation results into different temporal resolutions
    println();
    resample_simulations!(year, config);

    return nothing
end;


end; # module EmeraldPipelines
