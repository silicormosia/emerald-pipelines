
function combine_cache_files!(year::Int, config::OrderedDict{String,Any}) :: Nothing
    # determine the global result file to combine all cache files into
    global_file = simulation_global_file(year, config, "1H");

    # if the global file already exists, do nothing
    if isfile(global_file)
        pretty_display!("Global result file $global_file already exists. Skipping...", "tinfo");

        return nothing;
    end;

    # determine the size of the simulated results
    nhid = if config["WD_VERSION"] in ["wd1"]
        24
    else
        error("Unsupported WD_VERSION: $(config["WD_VERSION"])");
    end;
    nlon = config["NX"] * 360;
    nlat = config["NX"] * 180;
    nind = (isleapyear(year) ? 366 : 365) * nhid;
    map_template = zeros(Float32, nlon, nlat, nind) .* NaN32;

    # dicts that contains all GriddingMachine data to help determine the locations to simulate
    pretty_display!("Reading in the grid JLD2 file and prepare the file path to read...", "tinfo_pre");
    jld2_to_read = jld2_dict_file(year, config["GM_VERSION"]);
    jld_dicts = read_jld2(jld2_to_read, "GRID_INFO");

    # determine the variable names to read and save
    pretty_display!("Preparing the empty arrays to store the combined results...", "tinfo_mid");
    vars_to_read = String[];
    for var in config["VARIABLES_TO_SAVE"]
        if var == "GPP"
            push!(vars_to_read, "GPP");
        elseif var == "ET"
            push!(vars_to_read, "ET_VEGE", "ET_SOIL");
        elseif var == "SIF740"
            push!(vars_to_read, "SIF740");
        else
            pretty_display!("Unsupported variable to save: $var", "terror");
        end;
    end;
    map_gpp    = "GPP"    in config["VARIABLES_TO_SAVE"] ? deepcopy(map_template) : nothing;
    map_et     = "ET"     in config["VARIABLES_TO_SAVE"] ? deepcopy(map_template) : nothing;
    map_sif740 = "SIF740" in config["VARIABLES_TO_SAVE"] ? deepcopy(map_template) : nothing;

    # combine all cache files into the global results
    pretty_display!("Combining all cache files into global result file $global_file...", "tinfo_mid");
    @showprogress for gm_dict in jld_dicts
        cachefile = simulation_cache_file(config, gm_dict);
        ilon = gm_dict["LON_INDEX"];
        ilat = gm_dict["LAT_INDEX"];
        if isfile(cachefile)
            df = read_nc(cachefile, vars_to_read);
            "GPP"    in config["VARIABLES_TO_SAVE"] ? (map_gpp[ilon,ilat,:] .= df.GPP)                  : nothing;
            "ET"     in config["VARIABLES_TO_SAVE"] ? (map_et[ilon,ilat,:] .= df.ET_VEGE .+ df.ET_SOIL) : nothing;
            "SIF740" in config["VARIABLES_TO_SAVE"] ? (map_sif740[ilon,ilat,:] .= df.SIF740)            : nothing;
        end;
    end;
    pretty_display!("All cache files combined into global results.", "tinfo_mid");

    # save the combined results into the global NetCDF file
    create_nc!(global_file, ["lon", "lat", "ind"], [nlon, nlat, nind]);
    lons = collect(Float32, 0.5/config["NX"]:1/config["NX"]:360) .- 180;
    lats = collect(Float32, 0.5/config["NX"]:1/config["NX"]:180) .- 90;
    append_nc!(global_file, "lon", lons, ATTR_LON, ["lon"]);
    append_nc!(global_file, "lat", lats, ATTR_LAT, ["lat"]);

    pretty_display!("Saving combined GPP into global NetCDF file...", "tinfo_mid");
    "GPP" in config["VARIABLES_TO_SAVE"] ? append_nc!(global_file, "GPP", map_gpp, ATTR_GPP, ["lon", "lat", "ind"]) : nothing;

    pretty_display!("Saving combined ET into global NetCDF file...", "tinfo_mid");
    "ET" in config["VARIABLES_TO_SAVE"] ? append_nc!(global_file, "ET", map_et, ATTR_ET, ["lon", "lat", "ind"]) : nothing;

    pretty_display!("Saving combined SIF740 into global NetCDF file...", "tinfo_mid");
    "SIF740" in config["VARIABLES_TO_SAVE"] ? append_nc!(global_file, "SIF740", map_sif740, ATTR_SIF740, ["lon", "lat", "ind"]) : nothing;

    pretty_display!("All combined results saved into global result file.", "tinfo_end");

    return nothing
end;
