#
# This script is meant to prepare the weather driver cache files to run Emerald simulations per grid
#
using Distributed: pmap, @everywhere
using ProgressMeter: @showprogress

using Emerald.EmeraldData.WeatherDrivers: ERA5SingleLevelsDriver
using Emerald.EmeraldIO.Folders: LAND_SETUP
using Emerald.EmeraldIO.Jld2: read_jld2
using Emerald.EmeraldIO.Terminal: input_integer
using Emerald.EmeraldUtility.Log: @tinfo
using Emerald.EmeraldUtility.Threading: dynamic_workers!


# 1. function to locate the default JLD2 file
function jld2_dict_file end;

jld2_dict_file(gm_tag::String, year::Int) = "$(LAND_SETUP)/emerald_grid_info_$(gm_tag)_$(year).jld2";


# 2. load the JLD2 file to read all the grids
input_year = input_integer("Please input the year to prepare the grid JLD2 file (best from 2001 to 2020)> ");
input_gm_n = input_integer("Please input the gm version (1, 2, or 3; default setting is 2)> ");
gm_tag = "gm$(input_gm_n)";
jld2_to_read = jld2_dict_file(gm_tag, input_year);
jld2_dict = read_jld2(jld2_to_read, "GRID_INFO");


# 3. prepare the parameters and run in parallel
era5_sl_struct = ERA5SingleLevelsDriver();
params = [];
for gmd in jld2_dict
    push!(params, (era5_sl_struct, gmd));
end;


# 4. run in parallel
dynamic_workers!(40);
@everywhere using Emerald.EmeraldData.WeatherDrivers: era5_weather_driver_file
@everywhere thread_func(param) = era5_weather_driver_file(param[1], param[2]);
@showprogress pmap(thread_func, params);
@tinfo "All weather drivers prepared!";
