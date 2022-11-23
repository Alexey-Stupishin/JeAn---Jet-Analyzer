function pipeline_aia_find_candidates_m2, work_dir, aia_dir_wave_sel, wave, obj_dir, config, files_in, presets, run_diff, data, ind_seq, no_cand = no_cand

t0 = systime(/seconds)

pipeline_aia_get_input_files, config, work_dir + path_sep() + aia_dir_wave_sel, files_in
pipeline_aia_read_prepare_data, files_in.ToArray(), rd_proc, data, ind_seq, presets
run_diff = rd_proc

szd = size(data)
nd = szd[3]
;flux = dblarr(nd)
;for i = 0, nd-1 do begin
;    flux[i] = total(data[*, *, i])
;endfor
;save, filename = "s:\University\Work\11312_for_2022\flux171.sav", flux

data = float(data)
save, filename = "s:\University\Work\12835\AIA\data171.sav", data

;frame = fltarr(szd[1], szd[2])
;sframe = {frame:frame}
;ssframe = replicate(sframe, nd)
;for i = 0, nd-1 do begin
;    ssframe[i].frame = float(data[*, *, i])
;endfor
;save, filename = "s:\University\Work\12835\AIA\data171.sav", ssframe

if keyword_set(no_cand) then return, 0

;preprocess run_dif
message,'Preprocessing data...',/info
pipeline_aia_irc_preprocess_rd, rd_proc
;run_diff = rd_proc

message, ' preparation in ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /info

t0 = systime(/seconds)

szr = size(rd_proc)
n = szr[3]

prefix = work_dir + path_sep() + obj_dir + path_sep() + strcompress(fix(wave),/remove_all)

exp1 = max([presets.min_size, presets.fill_size, presets.border])
exp2 = exp1
exp3 = max([presets.min_size_t, presets.fill_size_t, presets.border_t])
lims1 = [exp1, -exp1-1]
lims2 = [exp2, -exp2-1]
lims3 = [exp3, -exp3-1]
cmask = intarr(szr[1]+2*exp1, szr[2]+2*exp2, szr[3]+2*exp3)

pipeline_aia_irc_get_mask_3d, rd_proc, presets.mask_threshold, bmask, presets, rd_check
if presets.debug then initmask = bmask

;if presets.debug then save, filename = prefix + '_presets.debug.sav', rd_proc, rd_check, bmask
;pipeline_aia_irc_get_mask_3d, rd_proc2, 3.5, bmask2, presets.debug, rd_check2
;if presets.debug then save, filename = prefix + '_presets.debug.sav', rd_proc, rd_proc2, bmask1, bmask2
;bmask = bmask or bmask2
;if presets.debug then bmaskc = bmask

cmask[lims1[0]:lims1[1], lims2[0]:lims2[1], lims3[0]:lims3[1]] = bmask
message, ' mask preprocessing ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /info

t0 = systime(/seconds)
;removing small objects
pattern = pipeline_aia_irc_pattern_3d(presets.min_size, presets.min_size, presets.min_size_t)
cmask = morph_open(cmask, pattern)
if presets.debug then cmask_open = cmask
message, ' morph_open ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /info

t0 = systime(/seconds)
;filling large gaps
pattern = pipeline_aia_irc_pattern_3d(presets.fill_size, presets.fill_size, presets.fill_size_t)
;cmask = morph_close(cmask, pattern)
cmask = dilate(cmask, pattern)
if presets.debug then cmask_dilate = cmask
message, ' morph_close (dilate) ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /info
t0 = systime(/seconds)
cmask = erode(cmask, pattern)
if presets.debug then cmask_erode = cmask
message, ' morph_close (erode) ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /info

;t0 = systime(/seconds)
;;extend border
;pattern = pipeline_aia_irc_pattern_3d(presets.border, presets.border, presets.border_t)
;cmask = dilate(cmask, pattern)
;pipeline_aia_irc_get_mask_3d, rd_proc, 1.5, bmask2, presets.debug, rd_check
;cmask[lims1[0]:lims1[1], lims2[0]:lims2[1], lims3[0]:lims3[1]] = cmask[lims1[0]:lims1[1], lims2[0]:lims2[1], lims3[0]:lims3[1]] and bmask2
;if presets.debug then cmask_border = cmask
;message, ' expand ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /info

cmask = cmask[lims1[0]:lims1[1], lims2[0]:lims2[1], lims3[0]:lims3[1]]

clust3d = label_region(cmask, /all_neighbors, /ulong)
n_candidates = max(clust3d)
message,strcompress(n_candidates)+" candidates initially ",/info

;if presets.debug then save, filename = prefix + '_debug.sav', cmask_erode, cmask_border; rd_proc, rd_check, cmask0, result ; , clust3d, data, ind_seq

t0 = systime(/seconds)
found_candidates = pipeline_aia_irc_filter_clusters_proc_all(clust3d, presets, rd_check)
message, ' filtering ' + asu_sec2hms(systime(/seconds)-t0, /issecs) + ', found ' + strcompress(found_candidates.Count()), /info

;t0 = systime(/seconds)
;pipeline_aia_irc_get_mask_3d, rd_proc, 1.7, bmask2, presets.debug, rd_check
;cmask = intarr(szr[1]+2*exp1, szr[2]+2*exp2, szr[3]+2*exp3)
;cmask[lims1[0]:lims1[1], lims2[0]:lims2[1], lims3[0]:lims3[1]] = bmask
;pattern = pipeline_aia_irc_pattern_3d(presets.fill_size, presets.fill_size, presets.fill_size_t)
;patternd = pipeline_aia_irc_pattern_3d(presets.border, presets.border, presets.border_t)
;for k = 0, found_candidates.Count()-1 do begin
;    xmask = clust3d eq found_candidates[k].clust_n
;    cmask = intarr(szr[1]+2*exp1, szr[2]+2*exp2, szr[3]+2*exp3)
;    cmask[lims1[0]:lims1[1], lims2[0]:lims2[1], lims3[0]:lims3[1]] = xmask
;    cmask = dilate(cmask, patternd)
;    cmask = cmask[lims1[0]:lims1[1], lims2[0]:lims2[1], lims3[0]:lims3[1]]
;    amask = cmask and bmask2
;    emask = morph_close(amask, pattern)
;;    pipeline_aia_irc_get_cluster_coords, emask, 1, x, y
;        idxs = where(emask eq 1)
;        xy = array_indices(emask, idxs)
;        x = transpose(xy[0, *])
;        y = transpose(xy[1, *])
;;    found_candidates[k].frame[].xex.Add, x
;endfor 
;message, ' expand ' + asu_sec2hms(systime(/seconds)-t0, /issecs) + ', found ' + strcompress(found_candidates.Count()), /info

message,'Saving objects...',/info
pipeline_aia_csv_output, prefix + '.csv', found_candidates, ind_seq, presets = presets
save, filename = prefix + '.sav', found_candidates,  ind_seq

return, found_candidates.Count()
 
end