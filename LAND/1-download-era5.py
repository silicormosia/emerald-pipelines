#
# this script is meant to download the data from the CDS portal
#

import cdsapi
import datetime
import os


# 1. define the data to download
ERA5_SL_HOURLY_SELECTION =[
            "10m_u_component_of_wind",
            "10m_v_component_of_wind",
            "2m_dewpoint_temperature",
            "2m_temperature",
            "mean_surface_direct_short_wave_radiation_flux",
            "mean_surface_direct_short_wave_radiation_flux_clear_sky",
            "mean_surface_downward_long_wave_radiation_flux",
            "mean_surface_downward_long_wave_radiation_flux_clear_sky",
            "mean_surface_downward_short_wave_radiation_flux",
            "mean_surface_downward_short_wave_radiation_flux_clear_sky",
            "mean_surface_downward_uv_radiation_flux",
            "skin_temperature",
            "soil_temperature_level_1",
            "soil_temperature_level_2",
            "soil_temperature_level_3",
            "soil_temperature_level_4",
            "surface_pressure",
            "total_cloud_cover",
            "total_precipitation",
            "volumetric_soil_water_layer_1",
            "volumetric_soil_water_layer_2",
            "volumetric_soil_water_layer_3",
            "volumetric_soil_water_layer_4"]
ERA5_SL_HOURLY_LAYERS = [
            "u10", "v10", "d2m", "t2m",
            "msdrswrf", "msdrswrfcs", "msdwlwrf", "msdwlwrfcs", "msdwswrf", "msdwswrfcs", "msdwuvrf",
            "skt", "stl1", "stl2", "stl3", "stl4", "sp", "tcc", "tp", "swvl1", "swvl2", "swvl3", "swvl4"]
ERA5_SL_HOURLY_TIMES = [
            "00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00", "07:00", "08:00", "09:00", "10:00", "11:00",
            "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00"]
ERA5_SL_MONTHLY_SELECTION =[
            "2m_temperature",
            "high_vegetation_cover",
            "leaf_area_index_high_vegetation",
            "leaf_area_index_low_vegetation",
            "low_vegetation_cover",
            "mean_convective_precipitation_rate",
            "mean_large_scale_precipitation_rate",
            "skin_temperature",
            "type_of_high_vegetation",
            "type_of_low_vegetation"]
CLIENT = cdsapi.Client()


# 2. define the function to download the hourly data
def fetch_era5_sl_hourly_data(year, datasets=ERA5_SL_HOURLY_SELECTION, folder="/home/wyujie/DATASERVER/reanalysis/ERA5/SingleLevels/Hourly/original"):
    print("Downloading single levels hourly data for year", year, "per item...")
    # download data per item
    for ds in datasets:
        file_name = folder + "/" + ds + "_SL_" + str(year) + ".nc"
        if not os.path.isfile(file_name):
            print("Downloading data to file", file_name)
            CLIENT.retrieve(
                "reanalysis-era5-single-levels",
                {
                    "product_type": "reanalysis",
                    "format": "netcdf",
                    "variable": ds,
                    "year": str(year),
                    "month": [str(i) for i in range(1, 13)],
                    "day": [str(i) for i in range(1, 32)],
                    "time": ERA5_SL_HOURLY_TIMES,
                },
                file_name
            )
        else:
            print("File", file_name, "already exists, skip downloading")


# 3. define the function to download the monthly data
def fetch_era5_sl_monthly_data(year, datasets=ERA5_SL_MONTHLY_SELECTION, folder="/home/wyujie/DATASERVER/reanalysis/ERA5/SingleLevels/Monthly/original"):
    print("Downloading single levels monthly data for year", year, "per item...")
    # download data per item
    for ds in datasets:
        file_name = folder + "/" + ds + "_SL_" + str(year) + ".nc"
        if not os.path.isfile(file_name):
            print("Downloading data to file", file_name)
            CLIENT.retrieve(
                "reanalysis-era5-single-levels-monthly-means",
                {
                    "product_type": "monthly_averaged_reanalysis",
                    "format": "netcdf",
                    "variable": ds,
                    "year": str(year),
                    "month": [str(i) for i in range(1, 13)],
                    "time": "00:00",
                },
                file_name
            )
        else:
            print("File", file_name, "already exists, skip downloading")


# 3. ask whether the user wants to download all the data or just the data for a specific year
print("\nDo you want to download all the data from 1950 to last year (Y/y for yes; otherwise you will be asked to input a specific year): ")
input_choice = input()
download_all = input_choice == "Y" or input_choice == "y" or input_choice == "yes" or input_choice == "YES" or input_choice == "Yes"


# 4. download all the data required by CliMA Land PRO (ERA5 data has a 2-3 months delay)
if download_all:
    today = datetime.date.today()
    year = today.year
    if today.month <= 3:
        year -= 1
    for y in range(1950,year):
        fetch_era5_sl_monthly_data(y)
    for y in range(1980,year):
        fetch_era5_sl_hourly_data(y)


# 5. ask the user to input the year (integer)
while ~download_all:
    try:
        # ask the user to input the year
        input_year_str = input("\nPlease input the year you want to download the data for (integer): ")
        input_year = int(input_year_str)
        # check if the input is valid
        today = datetime.date.today()
        current_year = today.year
        if input_year < 1950 or input_year >= current_year:
            print("Please input a year between 1950 and", current_year-1)
        elif input_year == current_year-1 and today.month <= 3:
            print("The data for the current year is not available yet (assuming 3 months delay)")
            break
        else:
            print("Downloading data for year", input_year)
            fetch_era5_sl_monthly_data(input_year)
            fetch_era5_sl_hourly_data(input_year)
            break
    except ValueError:
        print("Please input an integer")
        continue
