function pipeline_aia_all, config_file, work_dir $
                    , fps = fps, no_load = no_load, no_cut = no_cut $
                    , no_save_empty = no_save_empty $
                    , no_visual = no_visual, no_vis_hmi = no_vis_hmi, no_cand = no_cand, no_details = no_details $
                    , presets_file = presets_file, ref_images = ref_images $
                    , remote_cutout = remote_cutout, cache_dir = cache_dir $
                    , method = method, graphtype = graphtype, maxtime = maxtime, waves = waves $
                    , warc = warc, harc = harc, use_jpg = use_jpg, use_contour = use_contour $
                    , throw_error = throw_error, throw_error_hmi = throw_error_hmi $
                    , test = test 

cand_report = list()
tt = systime(/seconds)
if n_elements(remote_cutout) eq 0 then remote_cutout = 1 ; use remote cutout by default
if n_elements(method) eq 0 then method = 2
if n_elements(use_jpg) eq 0 then use_jpg = 0
if n_elements(ref_images) eq 0 then ref_images = 0
if n_elements(no_cand) eq 0 then no_cand = 0
if n_elements(throw_error) eq 0 then throw_error = 0
if n_elements(throw_error_hmi) eq 0 then throw_error_hmi = 0

pipeline_aia_read_presets, presets, presets_file = presets_file 
pipeline_aia_read_down_config, config, method, config_file = config_file, waves = waves, warc = warc, harc = harc 
if not keyword_set(work_dir) then cd, current = work_dir
pipeline_aia_dir_tree, work_dir, config, aia_dir_cache, event_rel, aia_dir_wave_sel, hmi_dir_wave_sel, obj_dir $
                     , vis_data_dir, vis_data_dir_wave, hmi_vis_data_dir_wave $
                     , cache_dir = cache_dir, method = method, test = test, remote_cutout = remote_cutout

message, '********************************************************************', /info
message, '* Config = ' + config_file, /info
message, '* Output = ' + work_dir + path_sep() + event_rel, /info
message, '********************************************************************', /info

if ~pipeline_aia_check_dates(config, work_dir+path_sep()+event_rel, maxtime = maxtime) then begin
    print, '******** PROGRAM FINISHED ABNORMALLY, CHECK TIMES IN CONFIG! ********'
    asu_cond_message, throw_error, '!!!!!!!! INCORRECT TIMES IN CONFIG'  
    return, cand_report
endif

asu_json_save_list, config, work_dir + path_sep() + obj_dir + path_sep() + 'config.json'
asu_json_save_list, presets, work_dir + path_sep() + obj_dir + path_sep() + 'presets.json'

foreach wave, config.waves, i do begin
    t0 = systime(/seconds)
    if keyword_set(remote_cutout) then begin
        if ~keyword_set(no_load) then begin
            save_dir = work_dir + path_sep() + aia_dir_wave_sel[i]
            if ref_images then begin
                save_dir_full = save_dir + path_sep() + 'fullimage'
                file_mkdir, save_dir_full
                pipeline_aia_download_aia_full_selected, wave, save_dir_full, config
            endif
            lims = aia_utils_download_cutout(wave, save_dir, config)
        endif
    endif else begin
      if ~keyword_set(no_load) then aia_download_by_config, wave, aia_dir_cache, config, dirmode = 'cache'
      if ~keyword_set(no_cut) then pipeline_aia_cutout, aia_dir_cache, work_dir, wave, aia_dir_wave_sel[i], config, nofits = nofits, sav = sav
    endelse
    message, '******** AIA DOWNLOAD/CUTOFF performed in ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /info
    
    pipeline_aia_get_input_files, config, work_dir + path_sep() + aia_dir_wave_sel[i], files_in
    if files_in.Count() eq 0 then begin
        asu_cond_message, throw_error, '!!!!!!!! NO AIA FILES DOWNLOADED'  
    endif else begin
        case method of
            0: ncand = pipeline_aia_find_candidates_m0(work_dir, aia_dir_wave_sel[i], wave, obj_dir, config, files_in, presets)
            1: ncand = pipeline_aia_find_candidates(work_dir, aia_dir_wave_sel[i], wave, obj_dir, config, files_in, presets)
            2: ncand = pipeline_aia_find_candidates_m2(work_dir, wave, obj_dir, config, files_in, presets, run_diff, data, ind_seq, no_cand = no_cand)
        endcase
        cand_report.Add, {wave:wave, ncand:ncand}
        if ~keyword_set(no_visual) then begin   
            t0 = systime(/seconds)
            pipeline_aia_movie_prep_pict_movie, work_dir, obj_dir, vis_data_dir, wave, aia_dir_wave_sel[i], vis_data_dir_wave[i], details, config, presets, files_in.ToArray() $
                                        , use_jpg = use_jpg, use_contour = use_contour, no_save_empty = no_save_empty, graphtype = graphtype, no_details = no_details $
                                        , run_diff = run_diff, data_full = data, ind_seq = ind_seq, fps = fps
            message, '******** AIA PICTURES/VIDEO prepared in ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /info
        endif
    endelse    
endforeach

config.wpix = config.whmi
config.hpix = config.hhmi
foreach mag, config.mag, i do begin
    t0 = systime(/seconds)
    if ~keyword_set(no_load) then begin
        save_dir = work_dir + path_sep() + hmi_dir_wave_sel[i]
        lims = hmi_utils_download_cutout(mag, save_dir, config)
    endif
    message, '******** HMI DOWNLOAD/CUTOFF performed in ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /info
    
    if ~keyword_set(no_vis_hmi) then begin   
        t0 = systime(/seconds)
        pipeline_aia_get_input_files, config, work_dir + path_sep() + hmi_dir_wave_sel[i], files_in
        if files_in.Count() eq 0 then begin
            asu_cond_message, throw_error_hmi, message, '!!!!!!!!  NO HMI FILES DOWNLOADED'
        endif else begin    
            n_files = pipeline_aia_movie_hmi(work_dir, obj_dir, vis_data_dir, mag, files_in, hmi_vis_data_dir_wave[i], config, fps = fps)
            message, '******** HMI PICTURES/VIDEO prepared in ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /info
        endelse    
    endif
endforeach

print, '******** PROGRAM FINISHED SUCCESSFULLY, found: ', pipeline_aia_cand_report(cand_report), ' in ', asu_sec2hms(systime(/seconds)-tt, /issecs), ' ********'

return, cand_report

end
