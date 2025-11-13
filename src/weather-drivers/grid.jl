"""

    prepare_weather_drivers!(year::Int, config::OrderedDict{String,Any})

Prepare weather drivers for all grid cells, given
- `year`: the year of simulation
- `config`: configuration dictionary

"""
function prepare_weather_drivers!(year::Int, config::OrderedDict{String,Any})
    # dicts that contains all GriddingMachine data to help determine the locations to simulate
    jld2_to_read = jld2_dict_file(year, config["GM_VERSION"]);
    jld_dicts = read_jld2(jld2_to_read, "GRID_INFO");

    # prepare the parameters to run in parallel
    era5_sl_struct = ERA5SingleLevelsDriver();
    params = [];
    for d in jld_dicts
        push!(params, (era5_sl_struct, d));
    end;

    # run in parallel
    dynamic_workers!(config["GRID_THREADS"]);
    @everywhere eval(:(using EmeraldPipelines));
    @inline thread_func(param) = era5_weather_driver_file(param...);
    @showprogress pmap(thread_func, params);
    @tinfo "All weather drivers prepared!";

    return nothing
end;
