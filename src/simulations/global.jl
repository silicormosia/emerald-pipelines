"""

    global_simulations!(year::Int, gmv::Int; nthreads::Int = 480)

Run the global SPAC simulations for all grid cells, given
- `year`: the year of simulation
- `gmv`: the GriddingMachine version number
- `nthreads`: number of workers to use (default: 480)

"""
function global_simulations!(year::Int, config::OrderedDict{String,Any})
    # dicts that contains all GriddingMachine data to help determine the locations to simulate
    jld2_to_read = jld2_dict_file(year, config["GM_VERSION"]);
    jld_dicts = read_jld2(jld2_to_read, "GRID_INFO");

    # prepare the workers to run in parallel
    @tinfo "Preparing $(config["SIMU_THREADS"]) workers for global simulations...";
    dynamic_workers!(config["SIMU_THREADS"]);
    @everywhere eval(:(using EmeraldPipelines));

    # run the model in parallel
    @tinfo "Running simulations in parallel...";
    results = @showprogress pmap(thread_simulation!, jld_dicts);

    # log the results
    if all(isnothing, results)
        @tinfo "All simulations completed successfully!";
    else
        @twarn "Some simulations failed at the following grid points:";
        for res in results
            if !isnothing(res)
                println("LAT_INDEX = $(lpad(res[1], 4, " ")), LON_INDEX = $(lpad(res[2], 4, " ")))");
            end;
        end;
    end;
end;
