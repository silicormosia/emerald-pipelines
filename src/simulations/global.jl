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

    # prepare the workers to run in parallel
    pretty_display!("Preparing $(config["SIMU_THREADS"]) workers for the global simulations...", "tinfo_mid");
    dynamic_workers!(config["SIMU_THREADS"]);
    @everywhere eval(:(using EmeraldPipelines));

    # run the model in parallel
    pretty_display!("Running simulations in parallel...", "tinfo_mid");
    @inline thread_func_simu(param) = thread_simulation!(config, param);
    results = @showprogress pmap(thread_func_simu, jld_dicts);

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
