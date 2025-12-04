using EmeraldPipelines
using PkgUtility


setting = EmeraldPipelines.emerald_land_config();
jld2_to_read = EmeraldPipelines.jld2_dict_file(2019, setting["GM_VERSION"]);
jld_dicts = PkgUtility.DataIO.read_jld2(jld2_to_read, "GRID_INFO");
gmd = jld_dicts[1];
gmd["MESSAGE_LEVEL"] = 1;
EmeraldPipelines.thread_simulation!(setting, gmd);
