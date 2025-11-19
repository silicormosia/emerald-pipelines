"""

    global_simulations!(year::Int, gmv::Int; nthreads::Int = 480)

Run the global SPAC simulations for all grid cells, given
- `year`: the year of simulation
- `gmv`: the GriddingMachine version number
- `nthreads`: number of workers to use (default: 480)

"""
function global_simulations!(year::Int, config::OrderedDict{String,Any}) :: Nothing
    pretty_display!("Running global simulations for year $year...", "tinfo_pre");

    # dicts that contains all GriddingMachine data to help determine the locations to simulate
    pretty_display!("Reading in the JLD2 file to prepare the grids to run in parallel...", "tinfo_mid");
    jld2_to_read = jld2_dict_file(year, config["GM_VERSION"]);
    jld_dicts = read_jld2(jld2_to_read, "GRID_INFO");

    # run the simulations only for the sites where output files do not exist, skip if all files exist
    new_dicts = [];
    for d in jld_dicts
        fpath = simulation_cache_file(config, d);
        if !isfile(fpath)
            push!(new_dicts, d);
        end;
    end;

    if length(new_dicts) == 0
        pretty_display!("All simulations for year $year have already been done...", "tinfo_end");
        return nothing
    end;

    # prepare the workers to run in parallel
    pretty_display!("Preparing workers for the global simulations...", "tinfo_mid");
    dynamic_workers!(min(length(new_dicts), config["SIMU_THREADS"]));
    @everywhere eval(:(using EmeraldPipelines));

    # run the model in parallel
    pretty_display!("Running simulations in parallel...", "tinfo_mid");
    @inline thread_func_simu(param) = thread_simulation!(config, param);
    results = @showprogress pmap(thread_func_simu, new_dicts);

    # log the results
    pretty_display!("Logging any failed simulations...", "tinfo_mid");
    log_failures!(year, config, results);

    # remove the workers after simulations
    if config["REMOVE_WHEN_DONE"]
        pretty_display!("Removing all workers after simulations...", "tinfo_mid");
        dynamic_workers!(0);
    end;

    # finish up the simulation
    pretty_display!("Finished running global simulations for year $year.", "tinfo_end");

    return nothing
end;
