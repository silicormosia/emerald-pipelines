module EmeraldPipelines

using Dates: isleapyear
using Distributed: pmap, @everywhere
using GriddingMachine.Collector: download_dataset!
using GriddingMachine.Indexer: LandDatasets, WeatherDriverLabels, grid_dict, grid_weather
using NetcdfIO: append_nc!, create_nc!, detect_attribute, read_nc, save_nc!
using OrderedCollections: OrderedDict
using PkgUtility.DataIO: read_jld2, save_jld2!
using PkgUtility.DistributedTools: dynamic_workers!
using PkgUtility.PrettyDisplay: pretty_display!
using PkgUtility.MathTools: resample
using ProgressMeter: @showprogress

using Emerald.Land: land_model_settings, parameters_to_save, simulation!, site_config, site_driver_tuple, site_result_tuple, site_spac


# Land folders (create path if not exist)
LAND_FOLDER = joinpath(homedir(), "DATASERVER/model/Emerald");
LAND_CACHE  = joinpath(LAND_FOLDER, "cache");
LAND_DRIVER = joinpath(LAND_FOLDER, "drivers");
LAND_RESULT = joinpath(LAND_FOLDER, "simulations");
LAND_SETUP  = joinpath(LAND_FOLDER, "setups");
for p in (LAND_CACHE, LAND_DRIVER, LAND_RESULT, LAND_SETUP)
    isdir(p) || mkpath(p);
end;


# steps to run the pipelines
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


"""

    run_emerald_land!(year::Int, settings::Union{Dict,OrderedDict} = land_model_settings()) :: Nothing

Run the full Emerald Land simulation pipelines, given
- `year`: the year of simulation
- `settings`: the configuration dictionary for Emerald Land simulations
- `data_only`: if true, only prepare the data but skip the simulations and visualizations

"""
function run_emerald_land!(year::Int, settings::Union{Dict,OrderedDict} = land_model_settings(); data_only::Bool = false) :: Nothing
    # 1. prepare the grid JLD2 file to determine where to run simulations
    # 2. prepare the weather drivers for all grid cells within the JLD2 file
    #    prepare the data on the server with internet connection, but skip the simulations and visualizations
    # 3. run the global simulations in parallel
    # 4. combine all simulation results into a single NetCDF file
    # 5. resample the global simulation results into different temporal resolutions
    # 6. plot an example figure to verify the simulations
    # 7. clean up all cache files to save disk space

    # update_database!();
    prepare_grid_jld!(year, settings);
    prepare_weather_drivers!(year, settings);
    if data_only
        return nothing
    end;
    global_simulations!(year, settings);
    combine_cache_files!(year, settings);
    resample_simulations!(year, settings);
    visualize_simulation!(year, settings);
    clean_cache!(year, settings);

    return nothing
end;


end; # module EmeraldPipelines
