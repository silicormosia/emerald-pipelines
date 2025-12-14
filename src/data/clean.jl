"""

    clean_cache!()

Remove all files in the LAND_CACHE directory

"""
function clean_cache! end;

clean_cache!() :: Nothing = (
    pretty_display!("Cleaning up all files in the LAND_CACHE directory...", "tinfo_pre");
    @showprogress for file in readdir(LAND_CACHE)
        fpath = joinpath(LAND_CACHE, file);
        isfile(fpath) && rm(fpath; force=true);
    end;
    pretty_display!("Finished cleaning up the LAND_CACHE directory.", "tinfo_end");

    return nothing
);

clean_cache!(year::Int, settings::OrderedDict{String,Any}) :: Nothing = (
    pretty_display!("Cleaning up cache files for year $(year)...", "tinfo_pre");

    # dicts that contains all GriddingMachine data to help determine the locations to simulate
    pretty_display!("Reading in the grid JLD2 file and prepare the file path to read...", "tinfo_mid");
    jld2_to_read = jld2_dict_file(year, settings["GM_VERSION"]);
    jld_dicts = read_jld2(jld2_to_read, "GRID_INFO");

    # combine all cache files into the global results
    @showprogress for gmd in jld_dicts
        cachefile = simulation_cache_file(settings, gmd);
        isfile(cachefile) && rm(cachefile; force=true);
    end;
    pretty_display!("All cache files removed.", "tinfo_end");

    return nothing
);
