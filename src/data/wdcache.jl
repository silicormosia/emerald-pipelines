"""

    prepare_weather_drivers!(year::Int, settings::OrderedDict{String,Any})

Prepare weather drivers for all grid cells, given
- `year`: the year of simulation
- `settings`: configuration dictionary

"""
function prepare_weather_drivers!(year::Int, settings::OrderedDict{String,Any})
    pretty_display!("Preparing weather drivers for year $year...", "tinfo_pre");

    # predownload the necessary weather data if not exist
    wdl = WeatherDriverLabels(settings["WD_VERSION"], year);
    for fn in fieldnames(typeof(wdl))
        occursin("tag_", String(fn)) ? download_dataset!(getfield(wdl, fn)) : nothing;
    end;

    # dicts that contains all GriddingMachine data to run weather driver preparation in parallel
    pretty_display!("Reading grid JLD2 file and prepare the params to run Emerald...", "tinfo_mid");
    jld2_to_read = jld2_dict_file(year, settings["GM_VERSION"]);
    jld_dicts = read_jld2(jld2_to_read, "GRID_INFO");

    # prepare only the grids where the weather driver file does not exist
    params = [];
    for gmd in jld_dicts
        fpath = jld2_driver_file(settings, gmd);
        if !isfile(fpath)
            push!(params, (wdl, gmd["LATITUDE"], gmd["LONGITUDE"], gmd["FT"], fpath));
        end;
    end;

    # run weather driver preparation in parallel or serial depending on the number of params
    if length(params) > settings["GRID_THREADS"]
        pretty_display!("Preparing $(settings["GRID_THREADS"]) workers...", "tinfo_mid");
        dynamic_workers!(settings["GRID_THREADS"]);
        @everywhere eval(:(using EmeraldPipelines));

        pretty_display!("Preparing weather drivers for all grid cells in parallel...", "tinfo_mid");
        @inline thread_func_wd(param) = save_jld2!(param[5], grid_weather(param[1], param[2], param[3]; FT = param[4]));
        @showprogress pmap(thread_func_wd, params);
    else length(params) > 0
        pretty_display!("Preparing weather drivers for all grid cells in serial...", "tinfo_mid");
        @showprogress for param in params
            save_jld2!(param[5], grid_weather(param[1], param[2], param[3]; FT = param[4]));
        end;
    end;

    pretty_display!("All weather drivers prepared!", "tinfo_end");

    return nothing
end;
