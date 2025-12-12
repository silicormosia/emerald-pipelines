"""

    visualize_simulation!(year::Int, settings::OrderedDict{String,Any}) :: Nothing

Plot an example figure to visualize the simulation results by calling a Python script, given
- `year`: the year of simulation
- `settings`: the configuration dictionary for Emerald Land simulations

"""
function visualize_simulation!(year::Int, settings::OrderedDict{String,Any}) :: Nothing
    # if the selection is not :, do not resample anything
    if !(typeof(settings["SIMULATION_PERIOD"]) <: Colon)
        pretty_display!("Custom simulation period detected, skipping visualization step...", "tinfo");

        return nothing
    end;

    pretty_display!("Visualizing simulation results by calling Python...", "tinfo_pre");
    nc_1y = simulation_global_file(year, settings, "1Y");
    nc_1y_jpg = replace(nc_1y, ".nc" => ".jpg");

    if !isfile(nc_1y_jpg)
        pretty_display!("Plotting simulation results ...", "tinfo_mid");
        myscript = "$(@__DIR__)/visualize-output.py";
        run(`python3 $myscript $nc_1y`);
        pretty_display!("Finished plotting the simulation results.", "tinfo_end");
    else
        pretty_display!("JPG file already exists, skipping...", "tinfo_end");
    end;

    return nothing
end;
