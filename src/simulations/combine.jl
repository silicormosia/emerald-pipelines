"""

    combine_cache_files!(year::Int, setting::OrderedDict{String,Any}) :: Nothing

Combine all individual cache files from grid cell simulations into a single global NetCDF file, given
- `year`: the year of simulation
- `setting`: the configuration dictionary containing parameters for the simulation

"""
function combine_cache_files!(year::Int, setting::OrderedDict{String,Any}) :: Nothing
    # determine the global result file to combine all cache files into
    global_file = simulation_global_file(year, setting, "1H");

    # if the global file already exists, do nothing
    if isfile(global_file)
        pretty_display!("Global result file $global_file already exists. Skipping...", "tinfo");

        return nothing;
    end;

    # determine the size of the simulated results
    nhid = if setting["WD_VERSION"] in ["wd1"]
        24
    else
        error("Unsupported WD_VERSION: $(setting["WD_VERSION"])");
    end;
    nlon = setting["NX"] * 360;
    nlat = setting["NX"] * 180;
    nind = (isleapyear(year) ? 366 : 365) * nhid;
    nsel = length(collect(1:nind)[setting["SIMULATION_PERIOD"]]);
    map_template = zeros(Float32, nlon, nlat, nsel) .* NaN32;

    # dicts that contains all GriddingMachine data to help determine the locations to simulate
    pretty_display!("Reading in the grid JLD2 file and prepare the file path to read...", "tinfo_pre");
    jld2_to_read = jld2_dict_file(year, setting["GM_VERSION"]);
    jld_dicts = read_jld2(jld2_to_read, "GRID_INFO");

    # determine the variable names to read and save
    pretty_display!("Preparing the empty arrays to store the combined results...", "tinfo_mid");
    vars_to_read = String[];
    for var in setting["VARIABLES_TO_COMBINE"]
        if var == "ET"
            push!(vars_to_read, "ET_VEGE", "ET_SOIL");
        else
            push!(vars_to_read, var);
        end;
    end;

    # create the empty maps to store the combined results
    map_dict = Dict{String,Any}();
    for k in setting["VARIABLES_TO_COMBINE"]
        map_dict[k] = deepcopy(map_template);
    end;

    # combine all cache files into the global results
    pretty_display!("Combining all cache files into global result file...", "tinfo_mid");
    @showprogress for gmd in jld_dicts
        cachefile = simulation_cache_file(setting, gmd);
        ilon = gmd["LON_INDEX"];
        ilat = gmd["LAT_INDEX"];
        if isfile(cachefile)
            df = read_nc(cachefile, vars_to_read);
            for k in setting["VARIABLES_TO_COMBINE"]
                if k == "ET"
                    df[!,"ET"] = df.ET_VEGE .+ df.ET_SOIL;
                end;
                map_dict[k][ilon,ilat,:] .= df[:,k];
            end;
        end;
    end;
    pretty_display!("All cache files combined into global results.", "tinfo_mid");

    # save the combined results into the global NetCDF file
    create_nc!(global_file, ["lon", "lat", "ind"], [nlon, nlat, nsel]);
    lons = collect(Float32, 0.5/setting["NX"]:1/setting["NX"]:360) .- 180;
    lats = collect(Float32, 0.5/setting["NX"]:1/setting["NX"]:180) .- 90;
    append_nc!(global_file, "lon", lons, detect_attribute("lon"), ["lon"]);
    append_nc!(global_file, "lat", lats, detect_attribute("lat"), ["lat"]);
    for k in setting["VARIABLES_TO_COMBINE"]
        pretty_display!("Saving combined $(k) into global NetCDF file...", "tinfo_mid");
        append_nc!(global_file, k, map_dict[k], detect_attribute(k), ["lon", "lat", "ind"]);
    end;
    pretty_display!("All combined results saved into global result file.", "tinfo_end");

    return nothing
end;
