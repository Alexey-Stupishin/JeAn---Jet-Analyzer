function pipeline_aia_find_candidates, work_dir, aia_dir_wave_sel, wave, obj_dir, config, files_in, presets

t0 = systime(/seconds)

pipeline_aia_get_input_files, config, work_dir + path_sep() + aia_dir_wave_sel, files_in
pipeline_aia_read_prepare_data, files_in.ToArray(), run_diff, data, ind_seq

;message, strcompress(string(systime(/seconds)-t0,format="('******** CANDIDATES: preparation in ',g0,' seconds')")), /cont
message, '******** CANDIDATES: preparation in ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /info

t0 = systime(/seconds)

szr = size(run_diff)
n = szr[3]
postponed = list()
postID = 0

sz = size(data)
clust3d = lonarr(sz[1], sz[2], sz[3])
n_clust = 0
ctrl = 5
for i = 0, n-1 do begin
    pipeline_aia_irc_process, data[*,*,i], run_diff[*, *, i], presets,clust
    ind = where(clust gt 0)
    if ind[0] ne -1 then begin
      n_clust_cur = max(clust)
      clust[ind] += n_clust
      n_clust = n_clust + n_clust_cur
      clust3d[*,*,i] = clust    
    endif

    if double(i)/n*100d gt ctrl then begin
        print, 'find candidates, ' + strcompress(ctrl,/remove_all) + '%'
        ctrl += 5 
    endif
endfor
;message, strcompress(string(systime(/seconds)-t0,format="('******** CANDIDATES: finding in ',g0,' seconds')")), /cont
message, '******** CANDIDATES: finding in ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /info

t0 = systime(/seconds)
pipeline_aia_irc_merge_clusters, clust3d
pipeline_aia_irc_renumber_clusters, clust3d
n_candidates = max(clust3d)
message,strcompress(n_candidates)+" candidates found ",/info
;message, strcompress(string(systime(/seconds)-t0,format="('******** CANDIDATES: found in ',g0,' seconds')")), /cont
message, '******** CANDIDATES: found in ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /info

t0 = systime(/seconds)
pipeline_aia_irc_remove_short_clusters, clust3d, presets.min_duration
pipeline_aia_irc_renumber_clusters, clust3d
n_candidates = max(clust3d)
message,strcompress(n_candidates)+" candidates after removing short events ",/info
;message, strcompress(string(systime(/seconds)-t0,format="('******** CANDIDATES: removing short in ',g0,' seconds')")), /cont
message, '******** CANDIDATES: removing short clusters ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /info

t0 = systime(/seconds)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NB! Interface is changed!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pipeline_aia_irc_aspect_filter_clusters, clust3d, total_aspects, presets.min_aspect
pipeline_aia_irc_renumber_clusters, clust3d
n_candidates = max(clust3d)
message,strcompress(n_candidates)+" candidates after removing events with low aspect ",/info
;message, strcompress(string(systime(/seconds)-t0,format="('******** CANDIDATES: removing low aspects in ',g0,' seconds')")), /cont
message, '******** CANDIDATES: removing low aspect clusters ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /info

; fill found_candidates list
found_candidates = list()


n_frames = sz[3]

t0 = systime(/seconds)
for k =1, n_candidates do begin
  candidate = list()
  message,'Processing candidate '+strcompress(k)+" of " +strcompress(n_candidates)+'...',/info
  for t = 0, n_frames-1 do begin
    clust = clust3d[*,*,t]
    if total(clust eq k) gt 0 then begin
;      pipeline_aia_irc_get_cluster_coords, clust, k, x, y
      idxs = where(clust eq k)
      xy = array_indices(clust, idxs)
      x = transpose(xy[0, *])
      y = transpose(xy[1, *])
      irc_principale_comps, x, y, vx, vy, vbeta = vbeta, rotx = rotx, roty = roty, caspect = caspect, baspect = baspect
      j = {pos:t, x:x, y:y, aspect:caspect, baspect:baspect, vbeta:vbeta, rotx:rotx, roty:roty, clust:k, totasp:total_aspects[k]}
      candidate.add,j
    endif
  endfor
  found_candidates.add, candidate
endfor
;message, strcompress(string(systime(/seconds)-t0,format="('******** CANDIDATES: reported in ',g0,' seconds')")), /cont
message, '******** CANDIDATES: reported in ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /info

message,'Saving objects...',/info
prefix = work_dir + path_sep() + obj_dir + path_sep() + strcompress(fix(wave),/remove_all)
pipeline_aia_csv_output, prefix + '.csv', found_candidates, ind_seq
prefix = work_dir + path_sep() + obj_dir + path_sep() + strcompress(fix(wave),/remove_all)
save, filename = prefix + '.sav', found_candidates,  ind_seq

return, found_candidates.Count()


;    mask_3d = clust eq k
;    ind = where(mask_3d)
;    mask = total(mask_3d,3) gt 0
;    pipeline_aia_irc_get_cluster_coords, mask, 1, x, y
;    irc_principale_comps, x, y, vx, vy
;    aspect = vx gt vy ? vx/vy : vy/vx

 
end