"""

    prepare_grid_jld!(year::Int, config::OrderedDict{String,Any})

Prepare the JLD2 file that contains the gridded data from GriddingMachine to run Emerald, given
- `year`: the year of the dataset
- `config`: the configuration dictionary containing parameters such as "GM_VERSION"

"""
function prepare_grid_jld! end;

prepare_grid_jld!(year::Int, config::OrderedDict{String,Any}) = (
    display_message!("Preparing grid JLD2 file for year $year...", "tinfo_pre");

    # if file exists, do nothing
    jld = jld2_dict_file(year, config["GM_VERSION"]);
    if isfile(jld)
        display_message!("File $(jld) already exists, skipping...", "tinfo_end");
        return nothing
    end;

    # save the file if the file does not exist
    display_message!("Reading datasets for year $(year)...", "tinfo_mid");
    dts = LandDatasets{Float64}(config["GM_VERSION"], year);

    display_message!("Saving grid JLD2 file...", "tinfo_mid");
    prepare_grid_jld!(config["GM_VERSION"], dts);
    display_message!("Grid JLD2 file prepared successfully.", "tinfo_end");

    return nothing
);

prepare_grid_jld!(gm_tag::String, dts::LandDatasets) = (
    # combine lat and lon
    dicts  = Dict{String,Any}[];
    for ilat in 1:180*dts.LABELS.nx, ilon in 1:360*dts.LABELS.nx
        if dts.mask_spac[ilon,ilat]
            push!(dicts, grid_dict(dts, ilat, ilon));
        end;
    end;

    # save the data to a new dictionary
    clima_land_dict = Dict{String,Any}(
        "GRID_INFO" => dicts,
        "GM_TAGS"   => String[dts.LABELS.tag_s_cc, dts.LABELS.tag_s_α, dts.LABELS.tag_s_n, dts.LABELS.tag_s_Θr, dts.LABELS.tag_s_Θs,
                              dts.LABELS.tag_p_ch, dts.LABELS.tag_p_chl, dts.LABELS.tag_p_ci, dts.LABELS.tag_p_lai, dts.LABELS.tag_p_sla, dts.LABELS.tag_p_vcm,
                              dts.LABELS.tag_t_ele, dts.LABELS.tag_t_lm, dts.LABELS.tag_t_pft],
    );
    save_jld2!(jld2_dict_file(dts, gm_tag), clima_land_dict);

    return nothing
);
