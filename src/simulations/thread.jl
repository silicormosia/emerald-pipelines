"""

    thread_simulation!(setting::OrderedDict{String,Any}, gmd::Dict{String,Any})

Run the SPAC simulation for a specific grid cell in a separate thread, given
- `setting`: the configuration dictionary containing parameters for the simulation
- `gmd`: a dictionary that contains the GriddingMachine information for the specific grid cell

"""
thread_simulation!(setting::OrderedDict{String,Any}, gmd::Dict{String,Any}) = (
    # locate where to store the cache file
    cachefile = simulation_cache_file(setting, gmd);

    # if the cache file exists, skip the simulation
    if isfile(cachefile)
        return nothing
    end;

    # otherwise, run the simulation
    try
        saving_dict = parameters_to_save(all = true);
        config = site_config(gmd);
        spac = site_spac(config, gmd);
        driver = read_jld2(jld2_driver_file(setting, gmd));
        results = site_result_tuple(spac, driver, saving_dict);
        simulation!(config, spac, driver, results; saving = cachefile, saving_dict = saving_dict);

        return nothing
    catch e
        @info "Simulation failed at LAT_INDEX=$(gmd["LAT_INDEX"]), LON_INDEX=$(gmd["LON_INDEX"])";

        return (gmd["LAT_INDEX"], gmd["LON_INDEX"])
    end;
);
