#
# This script is meant to download the MODIS data to use in Emerald
#
using Dates: today, year

using GriddingMachine.Fetcher: MOD09A1v061, MYD09A1v061
using GriddingMachine.Fetcher: fetch_data!


# 1. create the data struct to download
mod09a1 = MOD09A1v061();
myd09a1 = MYD09A1v061();


# 2. download the data from 2000 to the current year
for tyear in [2024]#2000:year(today())
    fetch_data!(mod09a1, tyear);
    fetch_data!(myd09a1, tyear);
end;
