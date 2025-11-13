"""

    thread_simulation!(config::OrderedDict{String,Any}, gm_dict::Dict{String,Any})

Run the SPAC simulation for a specific grid cell in a separate thread, given
- `config`: the configuration dictionary containing parameters for the simulation
- `gm_dict`: a dictionary that contains the GriddingMachine information for the specific grid cell

"""
thread_simulation!(config::OrderedDict{String,Any}, gm_dict::Dict{String,Any}) = (
    # locate where to store the cache file
    cachefile = simulation_cache_file(config, gm_dict);

    # if the cache file exists, skip the simulation
    if isfile(cachefile)
        return nothing
    end;

    # otherwise, run the simulation
    try
        config = spac_config(gm_dict);
        spac = grid_spac(config, gm_dict);

        # customize the config and spac settings
        config.ALLOW_LEAF_REGROWTH = false;
        config.ALLOW_LEAF_SHEDDING = false;
        config.ALLOW_XYLEM_GROWTH = false;
        config.EFFECTIVE_LEAF_SPECTRA = false;
        config.ENABLE_DROUGHT_LEGACY = false;
        config.ENABLE_REF = true;
        config.ENABLE_SIF = true;

        for s in spac.soils
            s.state.θ = s.trait.vc.Θ_SAT;
        end;
        spac.plant.pool.c_pool = Inf;

        initialize_spac!(config, spac);

        df = grid_weather_driver("wd1", gm_dict);
        simulation!(config, spac, df; saving = cachefile);

        return nothing
    catch e
        @info "Simulation failed at LAT_INDEX=$(gm_dict["LAT_INDEX"]), LON_INDEX=$(gm_dict["LON_INDEX"])";

        return (gm_dict["LAT_INDEX"], gm_dict["LON_INDEX"])
    end;
);
