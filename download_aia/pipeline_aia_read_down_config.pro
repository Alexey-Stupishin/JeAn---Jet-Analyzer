pro pipeline_aia_read_down_config, config, method, config_file = config_file, waves = waves, warc = warc, harc = harc

if not keyword_set(config_file) then config_file = "config.json"

config_data = asu_read_json_config(config_file)

arcppix_aia = 0.6d
arcppix_hmi = 0.504d

def_aia_size = 500
def_hmi_size = fix(def_aia_size*arcppix_aia/arcppix_hmi)
config = {tstart:config_data["TIME_START"], tstop:config_data["TIME_STOP"], tref:config_data["TIME_START"] $
        , xc:config_data["X_CENTER"], yc:config_data["Y_CENTER"] $
        , wpix:def_aia_size, hpix:def_aia_size $
        , whmi:def_hmi_size, hhmi:def_hmi_size $
        , waves:list() $
        , mag:list() $
        , method:method $
        , timeout:3, count:3, limit:30, timeout_post:5, count_post:3}

config.waves = asu_get_safe_json_key(config_data, "WAVES", list())
if n_elements(waves) ne 0 then begin
    wlist = list()
    foreach vwave, waves do wlist.Add, vwave
    config.waves = wlist
endif

config.mag = asu_get_safe_json_key(config_data, "MAG", list())

config.wpix = asu_get_safe_json_key(config_data, "WIDTH_PIX", config.wpix)
config.wpix = round(asu_get_safe_json_key(config_data, "WIDTH_ARC", round(config.wpix*arcppix_aia))/arcppix_aia)
if n_elements(warc) ne 0 then config.wpix = warc
config.whmi = fix(config.wpix*arcppix_aia/arcppix_hmi)

config.hpix = asu_get_safe_json_key(config_data, "HEIGHT_PIX", config.hpix)
config.hpix = round(asu_get_safe_json_key(config_data, "HEIGHT_ARC", round(config.hpix*arcppix_aia))/arcppix_aia)
if n_elements(harc) ne 0 then config.hpix = harc
config.hhmi = fix(config.hpix*arcppix_aia/arcppix_hmi)

config.tref = asu_get_safe_json_key(config_data, "TIME_REF", config.tref)
config.timeout = asu_get_safe_json_key(config_data, "TRY_TIMEOUT", config.timeout)
config.count = asu_get_safe_json_key(config_data, "TRY_COUNT", config.count)
config.limit = asu_get_safe_json_key(config_data, "TRY_LIMIT", config.limit)
config.timeout_post = asu_get_safe_json_key(config_data, "TRY_TIMEOUT_POST", config.timeout_post)
config.count_post = asu_get_safe_json_key(config_data, "TRY_COUNT_POST", config.count_post)

end
