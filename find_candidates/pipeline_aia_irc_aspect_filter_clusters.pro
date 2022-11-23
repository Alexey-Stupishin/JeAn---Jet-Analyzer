pro pipeline_aia_irc_aspect_filter_clusters, clust, aspect_threshold_2d, min_aspect_area, aspect_threshold_3d

message,"Filtering clusters by aspect...",/info
n = max(clust)
sz = size(clust)
for k = 1, n do begin
    OK = pipeline_aia_irc_get_aspects_clusters(clust, k, aspect_threshold_2d, min_aspect_area, aspect_threshold_3d, max_aspect_2d, aspect_3d)
    if ~OK then begin
        mask_3d = clust eq k
        ind = where(mask_3d)
        clust[ind] = 0
    endif
endfor

end