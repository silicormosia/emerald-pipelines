function emerald_land_config()
    settings = OrderedDict{String,Any}(
        # Emerald version
        "EMERALD_VERSION"      => "b01",
        "CONFIG_TAG"           => "testing",

        # general settings
        "FT"                   => Float64,
        "NX"                   => 1,
        "GM_VERSION"           => "gm2",
        "WD_VERSION"           => "wd1",

        # threading settings
        "GRID_THREADS"         => 40,
        "SIMU_THREADS"         => 480,
        "REMOVE_WHEN_DONE"     => true,

        # saving settings related to the global NetCDF output files
        "VARIABLES_TO_COMBINE" => String["GPP", "ET", "PPAR", "SIF740", "ΦF", "ΦP", "ΣSIF", "ΣSIF_CHL", "ΣSIF_LEAF"],

        # testing settings (by default, run the model for 10 days in the middle of a year)
        "SIMULATION_PERIOD"    => 4321:4344,
    );

    return settings
end;
