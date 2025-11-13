#
# This script is meant to prepare the JLD2 files that stores the GriddingMachine data per grid
#
using Emerald.EmeraldData.GlobalDatasets: LandDatasets, grid_dict
using Emerald.EmeraldIO.Folders: LAND_SETUP
using Emerald.EmeraldIO.Jld2: save_jld2!
using Emerald.EmeraldIO.Terminal: input_integer
using Emerald.EmeraldUtility.Log: @terror, @tinfo


# 1. function to locate the default JLD2 file
function jld2_dict_file end;

jld2_dict_file(gm_tag::String, dts::LandDatasets) = jld2_dict_file(gm_tag, dts.LABELS.year);

jld2_dict_file(gm_tag::String, year::Int) = "$(LAND_SETUP)/emerald_grid_info_$(gm_tag)_$(year).jld2";


# 2. function to prepare the JLD2 file
function prepare_grid_jld! end;

prepare_grid_jld!(gm_tag::String, year::Int) = (
    # if file exists, do nothing
    jld = jld2_dict_file(gm_tag, year);
    if isfile(jld)
        @tinfo "File $(jld) already exists, skipping...";
        return nothing
    end;

    # save the file if the file does not exist
    @tinfo "Reading datasets for year $(year)...";
    dts = LandDatasets{Float64}(gm_tag, year);

    prepare_grid_jld!(gm_tag, dts);

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
    save_jld2!(jld2_dict_file(gm_tag, dts), clima_land_dict);

    return nothing
);


# 3. function to prepare the JLD2 file for the specific year
input_year = input_integer("Please input the year to prepare the grid JLD2 file (best from 2001 to 2020)> ");
input_gm_n = input_integer("Please input the gm version (1, 2, or 3; default setting is 2)> ");
gm_tag = "gm$(input_gm_n)";
prepare_grid_jld!(gm_tag, input_year);
