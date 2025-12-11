"""

    clean_cache!()

Remove all files in the LAND_CACHE directory

"""
function clean_cache!() :: Nothing
    pretty_display!("Cleaning up all files in the LAND_CACHE directory...", "tinfo_pre");
    @showprogress for file in readdir(LAND_CACHE)
        fpath = joinpath(LAND_CACHE, file);
        isfile(fpath) && rm(fpath; force=true);
    end;
    pretty_display!("Finished cleaning up the LAND_CACHE directory.", "tinfo_end");

    return nothing
end;
