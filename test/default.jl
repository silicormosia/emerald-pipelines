using EmeraldPipelines
using Revise


# run_emerald_land!(2019);


year = 2019;
config = EmeraldPipelines.emerald_land_config();
println();
EmeraldPipelines.prepare_grid_jld!(year, config);

println();
EmeraldPipelines.regrid_ERA5!(year, config["NX"]);

println();
EmeraldPipelines.prepare_weather_drivers!(year, config);

println();
global_simulations!(year, config);

println();
EmeraldPipelines.combine_cache_files!(year, config);

println();
EmeraldPipelines.resample_simulations!(year, config);
