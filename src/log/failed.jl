"""

    log_failures!(year, config::OrderedDict{String,Any}, results::Vector)

Log the failures of the global simulations for a specific year into a file, given
- `year`: the year of simulation
- `config`: the configuration dictionary for Emerald Land simulations
- `results`: a vector of results from the global simulations; if not nothing, the element is a tuple of (lat_index, lon_index) for failed simulations

"""
function log_failures!(year, config::OrderedDict{String,Any}, results::Vector) :: Nothing
    # if there is no failure, return nothing
    if all(isnothing, results)
        return nothing
    end;

    # log the results
    log_file = simulation_failure_log_file(year, config);
    open(log_file, "w") do io
        pretty_display!("Some simulations failed at the following grid points:", "twarn_pre");
        println(io, "Some simulations failed at the following grid points:");
        for res in results
            if !isnothing(res)
                pretty_display!("    LAT_INDEX = $(lpad(res[1], 4, " ")), LON_INDEX = $(lpad(res[2], 4, " ")))", "twarn_mid");
                println(io, "    LAT_INDEX = $(lpad(res[1], 4, " ")), LON_INDEX = $(lpad(res[2], 4, " "))");
            end;
        end;
        pretty_display!("Please rerun the simulations for these sites.", "twarn_end");
    end;

    return nothing
end;
