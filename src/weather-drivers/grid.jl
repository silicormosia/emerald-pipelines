"""

    prepare_weather_drivers!(year::Int, config::OrderedDict{String,Any})

Prepare weather drivers for all grid cells, given
- `year`: the year of simulation
- `config`: configuration dictionary

"""
function prepare_weather_drivers!(year::Int, config::OrderedDict{String,Any})
    pretty_display!("Preparing weather drivers for year $year...", "tinfo_pre");

    # dicts that contains all GriddingMachine data to run weather driver preparation in parallel
    pretty_display!("Reading grid JLD2 file and prepare the params to run in parallel...", "tinfo_mid");
    jld2_to_read = jld2_dict_file(year, config["GM_VERSION"]);
    jld_dicts = read_jld2(jld2_to_read, "GRID_INFO");

    # prepare only the grids where the weather driver file does not exist
    era5_sl_struct = ERA5SingleLevelsDriver();
    params = [];
    for d in jld_dicts
        fpath = grid_file_path(d);
        if !isfile(fpath)
            push!(params, (era5_sl_struct, d));
        end;
    end;

    # run weather driver preparation in parallel or serial depending on the number of params
    if length(params) > config["GRID_THREADS"]
        pretty_display!("Preparing $(config["GRID_THREADS"]) workers...", "tinfo_mid");
        dynamic_workers!(config["GRID_THREADS"]);
        @everywhere eval(:(using EmeraldPipelines));

        pretty_display!("Preparing weather drivers for all grid cells in parallel...", "tinfo_mid");
        @inline thread_func_wd(param) = era5_weather_driver_file(param...);
        @showprogress pmap(thread_func_wd, params);
    else
        pretty_display!("Preparing weather drivers for all grid cells in serial...", "tinfo_mid");
        @showprogress for param in params
            era5_weather_driver_file(param...);
        end;
    end;

    pretty_display!("All weather drivers prepared!", "tinfo_end");

    return nothing
end;
