#
# This script is meant to prepare the weather driver cache files to run ClimaLand-0.1
#
using ProgressMeter: @showprogress

using Emerald.EmeraldData.WeatherDrivers: ERA5SingleLevelsDriver, era5_weather_driver_file
using Emerald.EmeraldIO.Folders: LAND_SETUP
using Emerald.EmeraldIO.Jld2: read_jld2
using Emerald.EmeraldIO.Terminal: input_integer
using Emerald.EmeraldUtility.Log: @tinfo


# 1. function to locate the default JLD2 file (simplified from ClimaLand-0.1)
function jld2_dict_file end;

jld2_dict_file(gm_tag::String, year::Int) = "$(LAND_SETUP)/emerald_grid_info_$(gm_tag)_$(year).jld2";


# 2. load the JLD2 file to read all the grids
input_year = input_integer("Please input the year to prepare the grid JLD2 file (best from 2001 to 2020)> ");
input_gm_n = input_integer("Please input the gm version (1, 2, or 3; default setting is 2)> ");
gm_tag = "gm$(input_gm_n)";
jld2_to_read = jld2_dict_file(gm_tag, input_year);
jld2_dict = read_jld2(jld2_to_read, "GRID_INFO");


# 3. prepare the weather driver cache files for wd1
era5_sl_struct = ERA5SingleLevelsDriver();
@showprogress for gmd in jld2_dict
    era5_weather_driver_file(era5_sl_struct, gmd);
end;
