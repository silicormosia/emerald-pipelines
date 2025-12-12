using Emerald
using EmeraldPipelines


# Run Emerald with FvCB and J3B models for comparison
# Do not remove the threads after running FvCB to keep the workers for J3B
# Remember to change the tags in the settings
settings_fvcb = Emerald.Land.land_model_settings(mode = "testing");
settings_fvcb["CONFIG_TAG"] = "testing_fvcb";
settings_fvcb["REMOVE_WHEN_DONE"] = false;

settings_j3b = Emerald.Land.land_model_settings(mode = "testing");
settings_j3b["C3_MODEL"] = "J3B";
settings_j3b["CONFIG_TAG"] = "testing_j3b";
settings_j3b["REMOVE_WHEN_DONE"] = true;

EmeraldPipelines.run_emerald_land!(2019, settings_fvcb);
EmeraldPipelines.run_emerald_land!(2019, settings_j3b);
