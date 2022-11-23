function pipeline_aia_irc_filter_clusters_proc_all, clust3d, presets, rd_check

N = max(clust3d)

found_candidates = list()

ctrl = 0 
for k = 1, N do begin
    candidate = pipeline_aia_irc_filter_clusters_proc_one(clust3d, k, presets, rd_check)
    if candidate ne !NULL then begin
        found_candidates.Add, candidate
    endif
      
    if double(k)/N*100d gt ctrl then begin
        message, ' filtering ' + strcompress(ctrl,/remove_all) + '%',/info
        ctrl += 5 
    endif
endfor

return, found_candidates

end
