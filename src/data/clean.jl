"""

    clean_cache!()

Remove all files in the LAND_CACHE directory

"""
function clean_cache!() :: Nothing
    pretty_display!("Cleaning up all files in the LAND_CACHE directory...", "tinfo_pre");
    rm(LAND_CACHE; force=true, recursive=true);
    mkpath(LAND_CACHE);
    pretty_display!("Finished cleaning up the LAND_CACHE directory.", "tinfo_end");

    return nothing
end;
