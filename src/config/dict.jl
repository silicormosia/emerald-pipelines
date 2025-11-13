function emerald_land_config()
    return OrderedDict{String,Any}(
        # general settings
        "NX"           => 1,
        "GM_VERSION"   => "gm2",
        # threading settings
        "GRID_THREADS" => 40,
        "SiMU_THREADS" => 480,
    );
end;
