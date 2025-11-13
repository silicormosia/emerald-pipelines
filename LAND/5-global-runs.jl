#
# This script is meant to run the model at the global scale per grid
#
using Distributed: pmap, @everywhere
using ProgressMeter: @showprogress

using Emerald.EmeraldFrontier: simulation!
using Emerald.EmeraldIO.Folders: LAND_SETUP
using Emerald.EmeraldIO.Jld2: read_jld2
using Emerald.EmeraldIO.Terminal: input_integer
using Emerald.EmeraldUtility.Log: @tinfo, @twarn
using Emerald.EmeraldUtility.Threading: dynamic_workers!


# 1. function to locate the default JLD2 file
function jld2_dict_file end;

jld2_dict_file(gm_tag::String, year::Int) = "$(LAND_SETUP)/emerald_grid_info_$(gm_tag)_$(year).jld2";


# 2. load the JLD2 file to read all the grids
input_year = 2019    # input_integer("Please input the year to prepare the grid JLD2 file (best from 2001 to 2020)> ");
input_gm_n = 2       # input_integer("Please input the gm version (1, 2, or 3; default setting is 2)> ");
gm_tag = "gm$(input_gm_n)";
jld2_to_read = jld2_dict_file(gm_tag, input_year);
jld2_dict = read_jld2(jld2_to_read, "GRID_INFO");


# 3 prepare the workers and run in parallel
dynamic_workers!(500);
@everywhere using Emerald.EmeraldFrontier: simulation!, spac_config, grid_spac, grid_weather_driver
@everywhere using Emerald.EmeraldIO.Folders: LAND_CACHE
@everywhere using Emerald.EmeraldLand.SPAC: initialize_spac!

@everywhere thread_func!(gm_dict::Dict{String,Any}) = (
    cachefile = "$(LAND_CACHE)/emerald_gm2_wd1_$(gm_dict["YEAR"])_$(gm_dict["LAT_INDEX"])_$(gm_dict["LON_INDEX"])_$(gm_dict["RESO_SPACE"])X.nc";

    # if file exists, skip the simulation
    if isfile(cachefile)
        return nothing
    end;

    # otherwise, run the simulation
    try
        config = spac_config(gm_dict);
        spac = grid_spac(config, gm_dict);

        # customize the config and spac settings
        config.ALLOW_LEAF_REGROWTH = false;
        config.ALLOW_LEAF_SHEDDING = false;
        config.ALLOW_XYLEM_GROWTH = false;
        config.EFFECTIVE_LEAF_SPECTRA = false;
        config.ENABLE_DROUGHT_LEGACY = false;
        config.ENABLE_REF = true;
        config.ENABLE_SIF = true;

        for s in spac.soils
            s.state.θ = s.trait.vc.Θ_SAT;
        end;
        spac.plant.pool.c_pool = Inf;

        initialize_spac!(config, spac);

        df = grid_weather_driver("wd1", gm_dict);
        simulation!(config, spac, df; saving = cachefile);
        return nothing
    catch e
        @info "Simulation failed at LAT_INDEX=$(gm_dict["LAT_INDEX"]), LON_INDEX=$(gm_dict["LON_INDEX"])";
        return (gm_dict["LAT_INDEX"], gm_dict["LON_INDEX"])
    end;
);

# 4. run the model in parallel
results = @showprogress pmap(thread_func!, jld2_dict);
@tinfo "All grids have been simulated!";
if all(isnothing, results)
    @tinfo "All simulations completed successfully!";
else
    @twarn "Some simulations failed at the following grid points:";
    for res in results
        if !isnothing(res)
            println("    LAT_INDEX=$(res[1]), LON_INDEX=$(res[2])");
        end;
    end;
end;
