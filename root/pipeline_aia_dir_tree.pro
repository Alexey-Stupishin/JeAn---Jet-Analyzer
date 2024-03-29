pro pipeline_aia_dir_tree, work_dir, config, aia_dir_cache, event_rel, aia_wave_sel_rel, hmi_wave_sel_rel, objects_rel $
                         , vis_data_rel, vis_data_wave_rel, hmi_vis_data_wave_rel $
                         , cache_dir = cache_dir, method = method, test = test, remote_cutout = remote_cutout

time = anytim(config.tstart, out_style = 'UTC_EXT')
time_rel = string(time.year,FORMAT = '(I04)') + string(time.month,FORMAT='(I02)') + string(time.day,FORMAT='(I02)') + '_' $
         + string(time.hour,FORMAT = '(I02)') + string(time.minute,FORMAT='(I02)') + string(time.second,FORMAT='(I02)')
time = anytim(config.tstop, out_style = 'UTC_EXT')
time_rel += '_' + string(time.year,FORMAT = '(I04)') + string(time.month,FORMAT='(I02)') + string(time.day,FORMAT='(I02)') + '_' $
                + string(time.hour,FORMAT = '(I02)') + string(time.minute,FORMAT='(I02)') + string(time.second,FORMAT='(I02)')

event_rel = time_rel $
    + '_' + strcompress(fix(config.xc),/remove_all) + '_' + strcompress(fix(config.yc),/remove_all) $ 
    + '_' + strcompress(fix(config.wpix),/remove_all) + '_' + strcompress(fix(config.hpix),/remove_all) 

if not remote_cutout then begin
    if keyword_set(cache_dir) then begin
        aia_dir_cache = cache_dir
    endif else begin
            global_rel = 'global_cache'
            aia_dir_cache = work_dir + path_sep() + global_rel
    endelse
    file_mkdir, aia_dir_cache
endif

event_dir = work_dir + path_sep() + event_rel
file_mkdir, event_dir

smeth = '_m' + strcompress(string(method), /remove_all)

if n_elements(test) eq 0 then test = 0
prefix = test ne 0 ? (isa(test, 'STRING') ? test : asu_now_to_filename()) + path_sep() : ''

objects_rel = event_rel + path_sep() + prefix + 'objects' + smeth
objects = work_dir + path_sep() + objects_rel
file_mkdir, objects 
vis_data_rel = event_rel + path_sep() + prefix + 'visual_data' + smeth
vis_data = work_dir + path_sep() + vis_data_rel
file_mkdir, vis_data

aia_wave_sel_rel = []
vis_data_wave_rel = []
n_waves = n_elements(config.waves)
if n_waves gt 0 then begin
    aia_dir_rel = event_rel + path_sep() + 'aia_data'
    file_mkdir, work_dir + path_sep() + aia_dir_rel
    aia_wave_sel_rel = strarr(n_waves)
    vis_data_wave_rel = strarr(n_waves)
    foreach wavelength, config.waves, i do begin
        strwav = strcompress(fix(wavelength),/remove_all)
        aia_wave_sel_rel[i] = aia_dir_rel + path_sep() + strwav
        aia_wave_sel = work_dir + path_sep() + aia_wave_sel_rel[i]
        file_mkdir, aia_wave_sel 
        vis_data_wave_rel[i] = vis_data_rel + path_sep() + strwav
        vis_data_wave = work_dir + path_sep() + vis_data_wave_rel[i]
        file_mkdir, vis_data_wave
    endforeach 
end

n_mag = n_elements(config.mag)
hmi_wave_sel_rel = []
hmi_vis_data_wave_rel = []
if n_mag gt 0 then begin
    hmi_dir_rel = event_rel + path_sep() + 'hmi_data'
    file_mkdir, work_dir + path_sep() + hmi_dir_rel
    hmi_wave_sel_rel = strarr(n_mag)
    hmi_vis_data_wave_rel = strarr(n_mag)
    foreach cadence, config.mag, i do begin
        strcad = strcompress(fix(cadence),/remove_all)
        hmi_wave_sel_rel[i] = hmi_dir_rel + path_sep() + strcad
        hmi_wave_sel = work_dir + path_sep() + hmi_wave_sel_rel[i]
        file_mkdir, hmi_wave_sel 
        hmi_vis_data_wave_rel[i] = vis_data_rel + path_sep() + 'm' + strcad
        hmi_vis_data_wave = work_dir + path_sep() + hmi_vis_data_wave_rel[i]
        file_mkdir, hmi_vis_data_wave
    endforeach 
end

end
