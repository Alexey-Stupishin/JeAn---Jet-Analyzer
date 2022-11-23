pro pipeline_aia_irc_speed_filter_clusters, clust

message,"Filtering clusters by speed...",/info
n = max(clust)
sz = size(clust)
for k = 1, n do begin
    OK = pipeline_aia_irc_get_speed_clusters(clust, k)
    if ~OK then begin
        mask_3d = clust eq k
        ind = where(mask_3d)
        clust[ind] = 0
    endif
endfor

end