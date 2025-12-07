using Emerald
using EmeraldPipelines
using PkgUtility


setting = EmeraldPipelines.emerald_land_config();
jld2_to_read = EmeraldPipelines.jld2_dict_file(2019, setting["GM_VERSION"]);
jld_dicts = PkgUtility.DataIO.read_jld2(jld2_to_read, "GRID_INFO");
gmd = jld_dicts[1];
gmd["MESSAGE_LEVEL"] = 1;
EmeraldPipelines.thread_simulation!(setting, gmd);


saving_dict = Emerald.Land.parameters_to_save(; save_all = true);
config = Emerald.Land.site_config(gmd);
spac = Emerald.Land.site_spac(config, gmd);
wd = Dict{String,Vector{setting["FT"]}}(PkgUtility.DataIO.read_jld2(EmeraldPipelines.jld2_driver_file(setting, gmd)));
driver = Emerald.Land.site_driver_tuple(gmd, wd);
results = Emerald.Land.site_result_tuple(spac, wd, saving_dict);
Emerald.Land.simulation!(config, spac, driver, results; saving = "test.nc", saving_dict = saving_dict, selection = setting["SIMULATION_PERIOD"]);
