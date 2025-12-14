"""

    thread_simulation!(settings::Union{Dict,OrderedDict}, gmd::Union{Dict,OrderedDict}) :: Union{Nothing,Tuple{Int,Int}}

Run the SPAC simulation for a specific grid cell in a separate thread, given
- `settings`: the configuration dictionary containing parameters for the simulation
- `gmd`: a dictionary that contains the GriddingMachine information for the specific grid cell

If the simulation is successful, return nothing; if failed, return a tuple of (lat_index, lon_index), which will be logged later.

"""
thread_simulation!(settings::Union{Dict,OrderedDict}, gmd::Union{Dict,OrderedDict}) :: Union{Nothing,Tuple{Int,Int}} = (
    # locate where to store the cache file
    cachefile = simulation_cache_file(settings, gmd);

    # if the cache file exists, skip the simulation
    if isfile(cachefile)
        return nothing
    end;

    # otherwise, run the simulation
    return try
        sd = parameters_to_save(settings["VARIABLES_TO_SAVE"]);
        config = site_config(settings);
        spac = site_spac(config, gmd);
        wd = Dict{String,Vector{settings["FT"]}}(read_jld2(jld2_driver_file(settings, gmd)));
        driver = site_driver_tuple(gmd, wd);
        results = site_result_tuple(spac, wd, sd);
        simulation!(config, spac, driver, results; saving = cachefile, saving_setting = sd, selection = settings["SIMULATION_PERIOD"], δt = settings["TIME_STEP"]);
        nothing
    catch e
        @info "Simulation failed at LAT_INDEX=$(gmd["LAT_INDEX"]), LON_INDEX=$(gmd["LON_INDEX"])";
        (gmd["LAT_INDEX"], gmd["LON_INDEX"])
    end;
);
