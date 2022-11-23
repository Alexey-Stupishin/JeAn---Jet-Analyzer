pro pipeline_aia_read_down_config, config, method, config_file = config_file, waves = waves, warc = warc, harc = harc

if not keyword_set(config_file) then config_file = "config.json"

config_data = asu_read_json_config(config_file)

config = {tstart:config_data["TIME_START"], tstop:config_data["TIME_STOP"], tref:config_data["TIME_START"] $
        , xc:config_data["X_CENTER"], yc:config_data["Y_CENTER"], wpix:500, hpix:500 $
        , waves:config_data["WAVES"] $
        , method:method $
        , timeout:3, count:3, limit:30, timeout_post:5, count_post:3}

if n_elements(waves) ne 0 then begin
    wlist = list()
    foreach vwave, waves do wlist.Add, vwave
    config.waves = wlist
endif

arcppix = 0.6

config.wpix = asu_get_safe_json_key(config_data, "WIDTH_PIX", config.wpix)
config.wpix = round(asu_get_safe_json_key(config_data, "WIDTH_ARC", round(config.wpix*arcppix))/arcppix)
if n_elements(warc) ne 0 then config.wpix = warc

config.hpix = asu_get_safe_json_key(config_data, "HEIGHT_PIX", config.hpix)
config.hpix = round(asu_get_safe_json_key(config_data, "HEIGHT_ARC", round(config.hpix*arcppix))/arcppix)
if n_elements(harc) ne 0 then config.hpix = harc

config.tref = asu_get_safe_json_key(config_data, "TIME_REF", config.tref)
config.timeout = asu_get_safe_json_key(config_data, "TRY_TIMEOUT", config.timeout)
config.count = asu_get_safe_json_key(config_data, "TRY_COUNT", config.count)
config.limit = asu_get_safe_json_key(config_data, "TRY_LIMIT", config.limit)
config.timeout_post = asu_get_safe_json_key(config_data, "TRY_TIMEOUT_POST", config.timeout_post)
config.count_post = asu_get_safe_json_key(config_data, "TRY_COUNT_POST", config.count_post)

end
