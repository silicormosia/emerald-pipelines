using Emerald
using EmeraldPipelines


# Run Emerald with default settings for the entire year
settings = Emerald.Land.land_model_settings(mode = "default");
EmeraldPipelines.run_emerald_land!(2019, settings);
