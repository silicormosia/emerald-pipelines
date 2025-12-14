"""

    jld2_dict_file(dts::LandDatasets, gm_tag::String) :: String
    jld2_dict_file(year::Int, gm_tag::String) :: String

Return the location of the JLD2 file that contains the gridded data from GriddingMachine to run Emerald, given
- `dts`: the LandDatasets object containing the dataset information
- `gm_tag`: the GriddingMachine version tag (e.g., "gm1", "gm2", "gm3")
- `year`: the year of the dataset

"""
function jld2_dict_file end;

jld2_dict_file(dts::LandDatasets, gm_tag::String) :: String = jld2_dict_file(dts.LABELS.year, gm_tag);

jld2_dict_file(year::Int, gm_tag::String) :: String = "$(LAND_SETUP)/emerald_grid_info_$(gm_tag)_$(year).jld2";


"""

    jld2_driver_file(settings::Union{Dict,OrderedDict}, gmd::Union{Dict,OrderedDict}) ::String

Return the location of the JLD2 file that contains the weather driver data for a specific grid cell, given
- `settings`: the configuration dictionary for Emerald Land simulations
- `gmd`: a dictionary that contains the GriddingMachine information for the specific grid cell

"""
function jld2_driver_file(settings::Union{Dict,OrderedDict}, gmd::Union{Dict,OrderedDict}) ::String
    return "$(LAND_DRIVER)/$(gmd["YEAR"])/" *
           "emerald_driver_$(settings["WD_VERSION"])_$(gmd["YEAR"])_" *
           "$(gmd["LAT_INDEX"])_$(gmd["LON_INDEX"])_$(settings["NX"])X.jld2"
end;


"""

    simulation_cache_file(settings::Union{Dict,OrderedDict}, gmd::Union{Dict,OrderedDict}) ::String

Return the location of the cache file for a specific grid cell, given
- `settings`: the configuration dictionary for Emerald Land simulations
- `gmd`: a dictionary that contains the GriddingMachine information for the specific grid cell

"""
function simulation_cache_file(settings::Union{Dict,OrderedDict}, gmd::Union{Dict,OrderedDict}) ::String
    return "$(LAND_CACHE)/" *
           "emerald_land_$(settings["EMERALD_VERSION"])_" *
           "$(settings["GM_VERSION"])_$(settings["WD_VERSION"])_$(gmd["YEAR"])_" *
           "$(settings["CONFIG_TAG"])_" *
           "$(gmd["LAT_INDEX"])_$(gmd["LON_INDEX"])_$(settings["NX"])X.nc"
end;


"""

    simulation_global_file(year::Int, settings::Union{Dict,OrderedDict}, mt::String) :: String

Return the location of the global simulation output file for a specific year, given
- `year`: the year of simulation
- `settings`: the configuration dictionary for Emerald Land simulations
- `mt`: the resampling frequency (e.g., "1H", "1D", "8D", "1M", "1Y")

"""
function simulation_global_file(year::Int, settings::Union{Dict,OrderedDict}, mt::String) :: String
    @assert mt in ["1H", "1D", "8D", "1M", "1Y"] "Resample frequency must be one of 1H, 1D, 8D, 1M, or 1Y...";

    return "$(LAND_RESULT)/" *
           "emerald_land_$(settings["EMERALD_VERSION"])_" *
           "$(settings["GM_VERSION"])_$(settings["WD_VERSION"])_$(year)_" *
           "$(settings["CONFIG_TAG"])_" *
           "$(settings["NX"])X_$(mt).nc"
end;


"""

    simulation_failure_log_file(year::Int, settings::Union{Dict,OrderedDict}) :: String

Return the location of the log file that records the failures during Emerald Land simulations, given
- `year`: the year of simulation
- `settings`: the configuration dictionary for Emerald Land simulations

"""
function simulation_failure_log_file(year::Int, settings::Union{Dict,OrderedDict}) :: String
    return "$(LAND_RESULT)/" *
           "emerald_land_$(settings["EMERALD_VERSION"])_" *
           "$(settings["GM_VERSION"])_$(settings["WD_VERSION"])_$(year)_" *
           "$(settings["CONFIG_TAG"])_" *
           "$(settings["NX"])X_failed.log"
end;
