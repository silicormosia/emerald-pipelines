#
# This script is meant to regrid the ERA5 data to the same grid as the global simulation (1X for now)
# This script uses only 1 worker to regrid the data
#
using Dates: month, today, year
using Emerald.EmeraldData.WeatherDrivers: regrid_ERA5!


# 1. regrid all the hourly data required by CliMA Land PRO and Emerald (ERA5 data has a 2-3 months delay)
dt_today = today();
dt_year = year(dt_today);
dt_month = month(dt_today);
if dt_month < 5
    dt_year -= 2
else
    dt_year -= 1
end;
for year in 1980:dt_year
    regrid_ERA5!(year, 1);
end;
