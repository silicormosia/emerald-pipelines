using Emerald
using EmeraldPipelines
using PkgUtility.DataIO: read_jld2

settings = Emerald.Land.land_model_settings(mode = "testing");
settings["CONFIG_TAG"] = "testing_fvcb";
settings["MESSAGE_LEVEL"] = 1;
settings["REMOVE_WHEN_DONE"] = false;

EmeraldPipelines.prepare_grid_jld!(2019, settings);
jld2_to_read = EmeraldPipelines.jld2_dict_file(2019, settings["GM_VERSION"]);
jld_dicts = read_jld2(jld2_to_read, "GRID_INFO");
gmd = jld_dicts[1];

sd = Emerald.Land.parameters_to_save(settings["VARIABLES_TO_SAVE"]);
config = Emerald.Land.site_config(settings);
spac = Emerald.Land.site_spac(config, gmd);
wd = Dict{String,Vector{settings["FT"]}}(read_jld2(EmeraldPipelines.jld2_driver_file(settings, gmd)));
driver = Emerald.Land.site_driver_tuple(gmd, wd);
results = Emerald.Land.site_result_tuple(spac, wd, sd);
df = Emerald.Land.simulation!(config, spac, driver, results; saving_setting = sd, selection = settings["SIMULATION_PERIOD"], δt = settings["TIME_STEP"]);
