"""

    resample_simulations!(year::Int, config::OrderedDict{String,Any}) :: Nothing

Resample the global simulation results for a specific year into different temporal resolutions, given
- `year`: the year of simulation
- `config`: the configuration dictionary for Emerald Land simulations

"""
function resample_simulations! end;

resample_simulations!(year::Int, config::OrderedDict{String,Any}) :: Nothing = (
    # first resample to daily data, and then to 8D, 1M, and 1Y
    resample_simulations!(year, config, "1D");
    resample_simulations!(year, config, "8D");
    resample_simulations!(year, config, "1M");
    resample_simulations!(year, config, "1Y");

    return nothing
);

resample_simulations!(year::Int, config::OrderedDict{String,Any}, out_reso::String) :: Nothing = (
    file_in = out_reso == "1D" ? simulation_global_file(year, config) : simulation_global_file(year, config, "1D");
    file_out = simulation_global_file(year, config, out_reso);

    # if the 1-hourly file does not exist, throw an error
    if !isfile(file_in)
        @terror "Input global result file for year $(year) does not exist at $(file_in)...";

        return nothing
    end;

    # if the output file already exists, skip resampling
    if isfile(file_out)
        @tinfo "$(out_reso) resampled file for year $(year) already exists at $(file_out)...";

        return nothing
    end;

    # otherwise, resampling the 1-hourly data to daily data
    @tinfo "Resampling $(length(config["VARIABLES_TO_SAVE"])) datasets for year $(year)...";
    resampled_gpp = "GPP"    in config["VARIABLES_TO_SAVE"] ? resampled_map(year, file_in, "GPP"   , "1D") : nothing;
    resampled_et  = "ET"     in config["VARIABLES_TO_SAVE"] ? resampled_map(year, file_in, "ET"    , "1D") : nothing;
    resampled_sif = "SIF740" in config["VARIABLES_TO_SAVE"] ? resampled_map(year, file_in, "SIF740", "1D") : nothing;

    # save the resampled data into a new NetCDF file
    @tinfo "Saving resampled daily data into $file_out...";
    create_nc!(file_out, ["lon", "lat", "ind"], [size(resampled_gpp, 1), size(resampled_gpp, 2), size(resampled_gpp, 3)]);
    append_nc!(file_out, "lon", read_nc(file_in, "lon"), ATTR_LON);
    append_nc!(file_out, "lat", read_nc(file_in, "lat"), ATTR_LAT);
    "GPP"    in config["VARIABLES_TO_SAVE"] ? append_nc!(file_out, "GPP"   , resampled_gpp, ATTR_GPP   ) : nothing;
    "ET"     in config["VARIABLES_TO_SAVE"] ? append_nc!(file_out, "ET"    , resampled_et , ATTR_ET    ) : nothing;
    "SIF740" in config["VARIABLES_TO_SAVE"] ? append_nc!(file_out, "SIF740", resampled_sif, ATTR_SIF740) : nothing;

    return nothing
);


"""

    resampled_map(year::Int, file_in::String, var::String, out_reso::String) :: Nothing

Resample a specific variable from the input NetCDF file into a different temporal resolution, given
- `year`: the year of simulation
- `file_in`: the input NetCDF file that contains the variable to resample
- `var`: the variable name to resample
- `out_reso`: the output temporal resolution (one of "1D", "8D", "1M", "1Y")

"""
function resampled_map(year::Int, file_in::String, var::String, out_reso::String) :: Nothing
    # read the data
    map_in = read_nc(file_in, var);

    # create the output map
    nlon = size(map_in, 1);
    nlat = size(map_in, 2);
    nind = if out_reso == "1D"
        isleapyear(year) ? 366 : 365
    elseif out_reso == "8D"
        46
    elseif out_reso == "1M"
        12
    elseif out_reso == "1Y"
        1
    else
        error("Unsupported output resolution: $out_reso");
    end;
    map_out = nind > 1 ? (zeros(Float32, nlon, nlat, nind) .* NaN32) : (zeros(Float32, nlon, nlat) .* NaN32);

    # perform resampling for each variable to save
    @tinfo "Resampling $var to $out_reso...";
    @showprogress for ilon in 1:nlon, ilat in 1:nlat
        map_out[ilon,ilat,:] .= resample_data(map_in[ilon,ilat,:], year; out_reso = out_reso);
    end;

    return map_out
end;
