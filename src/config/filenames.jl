"""

    jld2_dict_file(dts::LandDatasets, gm_tag::String)
    jld2_dict_file(year::Int, gm_tag::String)

Return the location of the JLD2 file that contains the gridded data from GriddingMachine to run Emerald, given
- `dts`: the LandDatasets object containing the dataset information
- `gm_tag`: the GriddingMachine version tag (e.g., "gm1", "gm2", "gm3")
- `year`: the year of the dataset

"""
function jld2_dict_file end;

jld2_dict_file(dts::LandDatasets, gm_tag::String) = jld2_dict_file(dts.LABELS.year, gm_tag);

jld2_dict_file(year::Int, gm_tag::String) = "$(LAND_SETUP)/emerald_grid_info_$(gm_tag)_$(year).jld2";


"""

    simulation_cache_file(config::OrderedDict{String,Any}, gm_dict::Dict{String,Any}) ::String

Return the location of the cache file for a specific grid cell, given
- `config`: the configuration dictionary for Emerald Land simulations
- `gm_dict`: a dictionary that contains the GriddingMachine information for the specific grid cell

"""
function simulation_cache_file(config::OrderedDict{String,Any}, gm_dict::Dict{String,Any}) ::String
    return "$(LAND_CACHE)/" *
           "emerald_land_$(config["EMERALD_VERSION"])_" *
           "$(config["GM_VERSION"])_$(config["WD_VERSION"])_$(gm_dict["YEAR"])_" *
           "$(config["CONFIG_TAG"])_" *
           "$(gm_dict["LAT_INDEX"])_$(gm_dict["LON_INDEX"])_$(config["NX"])X.nc";
end;


"""

    simulation_global_file(year::Int, config::OrderedDict{String,Any}, mt::String) :: String

Return the location of the global simulation output file for a specific year, given
- `year`: the year of simulation
- `config`: the configuration dictionary for Emerald Land simulations
- `mt`: the resampling frequency (e.g., "1H", "1D", "8D", "1M", "1Y")

"""
function simulation_global_file(year::Int, config::OrderedDict{String,Any}, mt::String) :: String
    @assert mt in ["1H", "1D", "8D", "1M", "1Y"] "Resample frequency must be one of 1H, 1D, 8D, 1M, or 1Y...";

    return "$(LAND_RESULT)/" *
           "emerald_land_$(config["EMERALD_VERSION"])_" *
           "$(config["GM_VERSION"])_$(config["WD_VERSION"])_$(year)_" *
           "$(config["CONFIG_TAG"])_" *
           "$(config["NX"])X_$(mt).nc";
end;


"""

    simulation_failure_log_file(year::Int, config::OrderedDict{String,Any}) :: String

Return the location of the log file that records the failures during Emerald Land simulations, given
- `year`: the year of simulation
- `config`: the configuration dictionary for Emerald Land simulations

"""
function simulation_failure_log_file(year::Int, config::OrderedDict{String,Any}) :: String
    return "$(LAND_RESULT)/" *
           "emerald_land_$(config["EMERALD_VERSION"])_" *
           "$(config["GM_VERSION"])_$(config["WD_VERSION"])_$(year)_" *
           "$(config["CONFIG_TAG"])_" *
           "$(config["NX"])X_failed.log";
end;
