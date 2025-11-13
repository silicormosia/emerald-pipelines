"""

    regrid_all_ERA5!(nx::Int = 1)

Regrid all the hourly ERA5 data from EARLIEST_ERA5_YEAR to the most recent year available, given
- `nx`: the spatial resolution factor (nX means the grid size is 1/n degree, default is 1)

"""
function regrid_all_ERA5!(nx::Int = 1)
    # read current date
    dt_today = today();
    dt_year = year(dt_today);
    dt_month = month(dt_today);

    # if current month is before May, regrid data up to year-2; otherwise, regrid data up to year-1
    if dt_month < 5
        dt_year -= 2
    else
        dt_year -= 1
    end;

    # regrid data year by year
    for year in EARLIEST_ERA5_YEAR:dt_year
        regrid_ERA5!(year, 1);
    end;

    return nothing
end;
