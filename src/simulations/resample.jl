"""

    resample_simulations!(year::Int, settings::Union{Dict,OrderedDict}) :: Nothing

Resample the global simulation results for a specific year into different temporal resolutions, given
- `year`: the year of simulation
- `settings`: the configuration dictionary for Emerald Land simulations

"""
function resample_simulations! end;

resample_simulations!(year::Int, settings::Union{Dict,OrderedDict}) :: Nothing = (
    println();

    # if the selection is not :, do not resample anything
    if !(typeof(settings["SIMULATION_PERIOD"]) <: Colon)
        pretty_display!("Custom simulation period detected, skipping resampling step...", "tinfo");

        return nothing
    end;

    # first resample to daily data, and then to 8D, 1M, and 1Y
    pretty_display!("Resampling global simulation results...", "tinfo_pre");
    resample_simulations!(year, settings, "1D");
    resample_simulations!(year, settings, "8D");
    resample_simulations!(year, settings, "1M");
    resample_simulations!(year, settings, "1Y");
    pretty_display!("Finished resampling global simulation results.", "tinfo_end");

    return nothing
);

resample_simulations!(year::Int, settings::Union{Dict,OrderedDict}, out_reso::String) :: Nothing = (
    pretty_display!("Resampling global simulation results for to $(out_reso)...", "tinfo_mid");
    file_in = out_reso == "1D" ? simulation_global_file(year, settings, "1H") : simulation_global_file(year, settings, "1D");
    file_out = simulation_global_file(year, settings, out_reso);

    # if the 1-hourly file does not exist, throw an error
    if !isfile(file_in)
        return error("Input $(file_in) does not exist!")
    end;

    # if the output file already exists, skip resampling
    if isfile(file_out)
        pretty_display!("$(out_reso) resampled file for year $(year) already exists, skipping the resampling step...", "tinfo_mid");

        return nothing
    end;

    # otherwise, resampling the data and save it
    dims = out_reso == "1Y" ? ["lon", "lat"] : ["lon", "lat", "ind"];
    pretty_display!("Resampling $(length(settings["VARIABLES_TO_SAVE"])) datasets for year $(year)...", "tinfo_mid");
    for varname in settings["VARIABLES_TO_SAVE"]
        pretty_display!("Resampling the $(varname) data...", "tinfo_mid");
        resampled_data = resample(read_nc(file_in, varname), out_reso, year);
        pretty_display!("Saving resampled data...", "tinfo_mid");
        if isfile(file_out)
            append_nc!(file_out, varname, resampled_data, detect_attribute(varname), dims);
        else
            save_nc!(file_out, varname, resampled_data, detect_attribute(varname));
        end;
    end;

    return nothing
);
