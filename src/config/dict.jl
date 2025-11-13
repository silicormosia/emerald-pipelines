function emerald_land_config()
    return OrderedDict{String,Any}(
        # general settings
        "NX"                => 1,
        "GM_VERSION"        => "gm2",
        "WD_VERSION"        => "wd1",

        # threading settings
        "GRID_THREADS"      => 40,
        "SIMU_THREADS"      => 480,
        "REMOVE_WHEN_DONE"  => true,

        # saving settings
        "VARIABLES_TO_SAVE" => String["GPP", "ET", "SIF740"],
    );
end;
