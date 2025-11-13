#
# This script is meant to regrid the ERA5 data to the same grid as the global simulation (1X for now)
# This script uses 23 workers to regrid the data in parallel
#
using Dates: month, today, year
using Emerald.EmeraldData.WeatherDrivers: ERA5SingleLevelsDriver, regrid_ERA5!

# 0. set up the parallel computing
using Distributed: pmap, @everywhere
using Emerald.EmeraldUtility.Threading: dynamic_workers!
dynamic_workers!(23);
@everywhere using Emerald.EmeraldData.WeatherDrivers: regrid_ERA5!


# 1. regrid all the hourly data required by CliMA Land PRO and Emerald (ERA5 data has a 2-3 months delay)
dt_today = today();
dt_year = year(dt_today);
dt_month = month(dt_today);
if dt_month < 5
    dt_year -= 2
else
    dt_year -= 1
end;

era5_wd = ERA5SingleLevelsDriver();
era5_labs = [getfield(era5_wd, fn)[2] for fn in fieldnames(ERA5SingleLevelsDriver)];
era5_vars = [getfield(era5_wd, fn)[1] for fn in fieldnames(ERA5SingleLevelsDriver)];
params = [];
for i in eachindex(era5_labs)
    push!(params, (era5_labs[i], era5_vars[i]));
end;

for year in 1980:dt_year
    # regrid_ERA5!(year, 1);
    # the lines below are supposed to run the code in parallel (but not yet tested)
    @everywhere thread_func(x) = regrid_ERA5!(year, 1, x[1], x[2]);
    pmap(thread_func, params);
    dynamic_workers!(0);
end;
