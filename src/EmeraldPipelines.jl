module EmeraldPipelines

using Dates: isleapyear
using Distributed: pmap, @everywhere
using GriddingMachine.Indexer: LandDatasets, WeatherDriverLabels, grid_dict, grid_weather
using NetcdfIO: append_nc!, create_nc!, detect_attribute, read_nc
using OrderedCollections: OrderedDict
using PkgUtility.DataIO: read_jld2, save_jld2!
using PkgUtility.DistributedTools: dynamic_workers!
using PkgUtility.PrettyDisplay: pretty_display!
using PkgUtility.MathTools: resample
using ProgressMeter: @showprogress

using Emerald.Land: parameters_to_save, simulation!, site_config, site_driver_tuple, site_result_tuple, site_spac


# Land folders (create path if not exist)
LAND_FOLDER = joinpath(homedir(), "DATASERVER/model/Emerald");
LAND_CACHE  = joinpath(LAND_FOLDER, "cache");
LAND_DRIVER = joinpath(LAND_FOLDER, "drivers");
LAND_RESULT = joinpath(LAND_FOLDER, "simulations");
LAND_SETUP  = joinpath(LAND_FOLDER, "setups");
for p in (LAND_CACHE, LAND_DRIVER, LAND_RESULT, LAND_SETUP)
    isdir(p) || mkpath(p);
end;


# include the Emerald Land extension functions (not yet ported to Emerald.jl)


# steps to run the pipelines
include("setting/dict.jl");
include("setting/filenames.jl");

include("data/clean.jl");
include("data/gmdicts.jl");
include("data/wdcache.jl");

include("simulations/thread.jl");
include("simulations/failed.jl");
include("simulations/global.jl");
include("simulations/combine.jl");
include("simulations/resample.jl");

include("python/visualize-output.jl");


# function to run the global simulations
function run_emerald_land!(year::Int, setting::OrderedDict{String,Any} = emerald_land_config()) :: Nothing
    # 1. prepare the grid JLD2 file to determine where to run simulations
    println();
    prepare_grid_jld!(year, setting);

    # 2. prepare the weather drivers for all grid cells within the JLD2 file
    println();
    prepare_weather_drivers!(year, setting);

    # 3. run the global simulations in parallel
    println();
    global_simulations!(year, setting);

    # 4. combine all simulation results into a single NetCDF file
    println();
    combine_cache_files!(year, setting);

    # 5. resample the global simulation results into different temporal resolutions
    println();
    resample_simulations!(year, setting);

    # 6. plot an example figure to verify the simulations
    println();
    visualize_simulation!(year, setting);

    return nothing
end;


end; # module EmeraldPipelines
