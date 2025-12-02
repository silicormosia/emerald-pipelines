# This script is meant to convert the old-version reprocessed ERA5 land data to new version that is compatible with GriddingMachine sharing procedure
using NetcdfIO: read_nc, save_nc!
using PkgUtility.PhysicalChemistry: saturation_vapor_pressure
using PkgUtility.PrettyDisplay: pretty_display!


# 1. define the old and new version folder paths
OLD_VER_FOLDER = joinpath(homedir(), "DATASERVER/model/ERA5/SingleLevels/Hourly/reprocessed");
NEW_VER_FOLDER = joinpath(homedir(), "DATASERVER/model/ERA5/SingleLevels/Hourly/GriddingMachine");
@assert isdir(OLD_VER_FOLDER) "Old version folder does not exist: $OLD_VER_FOLDER";
@assert isdir(NEW_VER_FOLDER) "New version folder does not exist: $NEW_VER_FOLDER";


# 2. function to generate the path to the old version file and new version file
#    e.g., 10m_v_component_of_wind_SL_2018_1X.nc
#          WIND_ERA5_1X_1H_2019_V1.nc
old_version_file_path(varlabel::String, year::Int) = "$(OLD_VER_FOLDER)/$(varlabel)_SL_$(year)_1X.nc";
new_version_file_path(tag::String, year::Int) = "$(NEW_VER_FOLDER)/$(tag)_1X_1H_$(year)_V1.nc";


# 3. process the data one by one variable
ERA5_SL_HOURLY_SELECTION = [
    "10m_u_component_of_wind",
    "10m_v_component_of_wind",
    "2m_dewpoint_temperature",
    "2m_temperature",
    "mean_surface_direct_short_wave_radiation_flux",
    "mean_surface_downward_long_wave_radiation_flux",
    "mean_surface_downward_short_wave_radiation_flux",
    "mean_surface_downward_uv_radiation_flux",
    "surface_pressure",
    "total_precipitation"
];
ERA5_SL_HOURLY_LAYERS = [
    "u10", "v10", "d2m", "t2m",
    "msdrswrf", "msdwlwrf", "msdwswrf", "msdwuvrf",
    "sp", "tp"
];


# 4. loop through the years and process the data
for yyyy in 2023:-1:1980
    # surface pressure
    old_fn = old_version_file_path("surface_pressure", yyyy);
    new_fn = new_version_file_path("PATM_ERA5", yyyy);
    if !isfile(new_fn) && isfile(old_fn)
        pretty_display!("Loading surface pressure data for year $(yyyy)...", "tinfo_pre");
        wd_p_atm = read_nc(Float32, old_version_file_path("surface_pressure", yyyy), "sp");

        pretty_display!("Saving surface pressure data to new file...", "tinfo_end");
        save_nc!(new_fn, "data", wd_p_atm, Dict{String,Any}("about" => "Surface pressure", "units" => "Pa"));
    elseif isfile(new_fn)
        @info "Surface pressure data for year $(yyyy) already exists, skipping...";
    elseif !isfile(old_fn)
        @warn "Surface pressure data for year $(yyyy) does not exist in old version, skipping...";
    end;

    # precipitation
    old_fn = old_version_file_path("total_precipitation", yyyy);
    new_fn = new_version_file_path("PPT_ERA5", yyyy);
    if !isfile(new_fn) && isfile(old_fn)
        pretty_display!("Loading precipitation data for year $(yyyy)...", "tinfo_pre");
        wd_precip = read_nc(Float32, old_version_file_path("total_precipitation", yyyy), "tp");

        pretty_display!("Saving precipitation data to new file...", "tinfo_end");
        save_nc!(new_fn, "data", wd_precip, Dict{String,Any}("about" => "Total precipitation within 1 hour", "units" => "mm"));
    elseif isfile(new_fn)
        @info "Precipitation data for year $(yyyy) already exists, skipping...";
    elseif !isfile(old_fn)
        @warn "Precipitation data for year $(yyyy) does not exist in old version, skipping...";
    end;

    # air temperature
    old_fn_t2m = old_version_file_path("2m_temperature", yyyy);
    old_fn_d2m = old_version_file_path("2m_dewpoint_temperature", yyyy);
    new_fn_t2m = new_version_file_path("TAIR_ERA5", yyyy);
    new_fn_vpd = new_version_file_path("VPD_ERA5", yyyy);
    if !isfile(new_fn_t2m) && !isfile(new_fn_vpd) && isfile(old_fn_t2m) && isfile(old_fn_d2m)
        pretty_display!("Loading air temperature data for year $(yyyy)...", "tinfo_pre");
        wd_t_air = read_nc(Float32, old_version_file_path("2m_temperature", yyyy), "t2m");

        pretty_display!("Loading dew point temperature data for year $(yyyy)...", "tinfo_mid");
        wd_t_dew = read_nc(Float32, old_version_file_path("2m_dewpoint_temperature", yyyy), "d2m");

        pretty_display!("Computing vapor pressure deficit for year $(yyyy)...", "tinfo_mid");
        wd_vpd = max.(Float32(1), saturation_vapor_pressure.(wd_t_air) .- saturation_vapor_pressure.(wd_t_dew));

        pretty_display!("Saving air temperature data to new file...", "tinfo_mid");
        save_nc!(new_fn_t2m, "data", wd_t_air, Dict{String,Any}("about" => "Air temperature", "units" => "K"));

        pretty_display!("Saving vapor pressure deficit data to new file...", "tinfo_end");
        save_nc!(new_fn_vpd, "data", wd_vpd, Dict{String,Any}("about" => "Vapor pressure deficit", "units" => "Pa"));
    elseif isfile(new_fn_t2m) && isfile(new_fn_vpd)
        @info "Air temperature data for year $(yyyy) already exists, skipping...";
        @info "Vapor pressure deficit data for year $(yyyy) already exists, skipping...";
    elseif !isfile(old_fn_t2m) || !isfile(old_fn_d2m)
        @warn "Air temperature or dew point temperature data for year $(yyyy) does not exist in old version, skipping...";
    end;

    # wind speed
    old_fn_u10 = old_version_file_path("10m_u_component_of_wind", yyyy);
    old_fn_v10 = old_version_file_path("10m_v_component_of_wind", yyyy);
    new_fn = new_version_file_path("WIND_ERA5", yyyy);
    if !isfile(new_fn) && isfile(old_fn_u10) && isfile(old_fn_v10)
        pretty_display!("Loading wind data (u) for year $(yyyy)...", "tinfo_pre");
        wd_windu = read_nc(Float32, old_version_file_path("10m_u_component_of_wind", yyyy), "u10");

        pretty_display!("Loading wind data (v) for year $(yyyy)...", "tinfo_mid");
        wd_windv = read_nc(Float32, old_version_file_path("10m_v_component_of_wind", yyyy), "v10");

        pretty_display!("Computing wind speed for year $(yyyy)...", "tinfo_mid");
        wd_wind  = sqrt.(wd_windu .^ 2 .+ wd_windv .^ 2);

        pretty_display!("Saving wind speed data to new file...", "tinfo_end");
        save_nc!(new_fn, "data", wd_wind, Dict{String,Any}("about" => "Wind speed", "units" => "m s⁻¹"));
    elseif isfile(new_fn)
        @info "Wind speed data for year $(yyyy) already exists, skipping...";
    elseif !isfile(old_fn_u10) || !isfile(old_fn_v10)
        @warn "Wind data for year $(yyyy) does not exist in old version, skipping...";
    end;

    # long wave radiation
    old_fn = old_version_file_path("mean_surface_downward_long_wave_radiation_flux", yyyy);
    new_fn = new_version_file_path("RAD_LW_ERA5", yyyy);
    if !isfile(new_fn) && isfile(old_fn)
        pretty_display!("Loading long wave radiation data for year $(yyyy)...", "tinfo_pre");
        wd_l_all = read_nc(Float32, old_version_file_path("mean_surface_downward_long_wave_radiation_flux", yyyy), "msdwlwrf");

        pretty_display!("Saving long wave radiation data to new file...", "tinfo_end");
        save_nc!(new_fn, "data", wd_l_all, Dict{String,Any}("about" => "Downward longwave radiation", "units" => "W m⁻²"));
    elseif isfile(new_fn)
        @info "Long wave radiation data for year $(yyyy) already exists, skipping...";
    elseif !isfile(old_fn)
        @warn "Long wave radiation data for year $(yyyy) does not exist in old version, skipping...";
    end;

    # short wave radiation
    old_fn_all = old_version_file_path("mean_surface_downward_short_wave_radiation_flux", yyyy);
    old_fn_dir = old_version_file_path("mean_surface_direct_short_wave_radiation_flux", yyyy);
    new_fn_dif = new_version_file_path("RAD_SW_DIF_ERA5", yyyy);
    new_fn_dir = new_version_file_path("RAD_SW_DIR_ERA5", yyyy);
    if !isfile(new_fn_dif) && !isfile(new_fn_dir) && isfile(old_fn_all) && isfile(old_fn_dir)
        pretty_display!("Loading short wave radiation data for year $(yyyy)...", "tinfo_pre");
        wd_s_all = read_nc(Float32, old_version_file_path("mean_surface_downward_short_wave_radiation_flux", yyyy), "msdwswrf");

        pretty_display!("Loading direct short wave radiation data for year $(yyyy)...", "tinfo_mid");
        wd_s_dir = read_nc(Float32, old_version_file_path("mean_surface_direct_short_wave_radiation_flux", yyyy), "msdrswrf");

        pretty_display!("Computing diffuse short wave radiation for year $(yyyy)...", "tinfo_mid");
        wd_s_dif = wd_s_all .- wd_s_dir;

        pretty_display!("Saving diffuse short wave radiation data to new file...", "tinfo_mid");
        save_nc!(new_fn_dif, "data", wd_s_dif, Dict{String,Any}("about" => "Diffuse downward shortwave radiation", "units" => "W m⁻²"));

        pretty_display!("Saving direct short wave radiation data to new file...", "tinfo_end");
        save_nc!(new_fn_dir, "data", wd_s_dir, Dict{String,Any}("about" => "Direct downward shortwave radiation", "units" => "W m⁻²"));
    elseif isfile(new_fn_dif) && isfile(new_fn_dir)
        @info "Diffuse short wave radiation data for year $(yyyy) already exists, skipping...";
        @info "Direct short wave radiation data for year $(yyyy) already exists, skipping...";
    elseif !isfile(old_fn_all) || !isfile(old_fn_dir)
        @warn "Short wave radiation data for year $(yyyy) does not exist in old version, skipping...";
    end;
end;
