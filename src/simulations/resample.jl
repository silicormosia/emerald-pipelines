"""

    resample_simulations!(year::Int, config::OrderedDict{String,Any}) :: Nothing

Resample the global simulation results for a specific year into different temporal resolutions, given
- `year`: the year of simulation
- `config`: the configuration dictionary for Emerald Land simulations

"""
function resample_simulations! end;

resample_simulations!(year::Int, config::OrderedDict{String,Any}) :: Nothing = (
    # first resample to daily data, and then to 8D, 1M, and 1Y
    pretty_display!("Resampling global simulation results...", "tinfo_pre");
    resample_simulations!(year, config, "1D");
    resample_simulations!(year, config, "8D");
    resample_simulations!(year, config, "1M");
    resample_simulations!(year, config, "1Y");
    pretty_display!("Finished resampling global simulation results.", "tinfo_end");

    return nothing
);

resample_simulations!(year::Int, config::OrderedDict{String,Any}, out_reso::String) :: Nothing = (
    pretty_display!("Resampling global simulation results for to $(out_reso)...", "tinfo_mid");
    file_in = out_reso == "1D" ? simulation_global_file(year, config, "1H") : simulation_global_file(year, config, "1D");
    file_out = simulation_global_file(year, config, out_reso);

    # if the 1-hourly file does not exist, throw an error
    if !isfile(file_in)
        return error("Input $(file_in) does not exist!")
    end;

    # if the output file already exists, skip resampling
    if isfile(file_out)
        pretty_display!("$(out_reso) resampled file for year $(year) already exists.", "tinfo_mid");

        return nothing
    end;

    # otherwise, resampling the 1-hourly data to daily data
    pretty_display!("Resampling $(length(config["VARIABLES_TO_SAVE"])) datasets for year $(year)...", "tinfo_mid");
    resampled_gpp = "GPP"    in config["VARIABLES_TO_SAVE"] ? resample(read_nc(file_in, "GPP"   ), out_reso, year) : nothing;
    resampled_et  = "ET"     in config["VARIABLES_TO_SAVE"] ? resample(read_nc(file_in, "ET"    ), out_reso, year) : nothing;
    resampled_sif = "SIF740" in config["VARIABLES_TO_SAVE"] ? resample(read_nc(file_in, "SIF740"), out_reso, year) : nothing;

    # save the resampled data into a new NetCDF file
    pretty_display!("Saving resampled data...", "tinfo_mid");
    dims = (out_reso == "1Y") ? ["lon", "lat"] : ["lon", "lat", "ind"];
    create_nc!(file_out, dims, [size(resampled_gpp)...]);
    append_nc!(file_out, "lon", read_nc(file_in, "lon"), ATTR_LON, ["lon"]);
    append_nc!(file_out, "lat", read_nc(file_in, "lat"), ATTR_LAT, ["lat"]);
    "GPP"    in config["VARIABLES_TO_SAVE"] ? append_nc!(file_out, "GPP"   , resampled_gpp, ATTR_GPP   , dims) : nothing;
    "ET"     in config["VARIABLES_TO_SAVE"] ? append_nc!(file_out, "ET"    , resampled_et , ATTR_ET    , dims) : nothing;
    "SIF740" in config["VARIABLES_TO_SAVE"] ? append_nc!(file_out, "SIF740", resampled_sif, ATTR_SIF740, dims) : nothing;

    return nothing
);
