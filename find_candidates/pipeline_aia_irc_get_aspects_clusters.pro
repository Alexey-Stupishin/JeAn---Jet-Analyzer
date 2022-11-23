function pipeline_aia_irc_get_aspects_clusters, clust3d, clustN, aspect_threshold_2d, min_aspect_area, aspect_threshold_3d, max_aspect_2d, aspect_3d, candidate = candidate

OK = 0 

mask_3d = clust3d eq clustN
mask = total(mask_3d, 3) gt 0
idxs = where(mask eq 1)
xy = array_indices(mask, idxs)
x = transpose(xy[0, *])
y = transpose(xy[1, *])
;pipeline_aia_irc_get_cluster_coords, mask, 1, x, y
irc_principale_comps, x, y, vx, vy, caspect = total_aspect
OK = total_aspect ge aspect_threshold_3d

if OK then begin
    ind = where(mask_3d)
    ids = array_indices(clust3d, ind)
    mi = min(ids[2, *])
    ma = max(ids[2, *])
    
    asp2d = 0d
    for f = mi, ma do begin
        c = clust3d[*,*,f]
        mask = where(c eq clustN)
        if total(mask) ge 0 then begin
            pipeline_aia_irc_get_cluster_coords, c, clustN, x, y
            if n_elements(x) gt 0 then begin
                irc_principale_comps, x, y, vx, vy, vbeta = vbeta, rotx = rotx, roty = roty, caspect = caspect, baspect = baspect
                if n_elements(x) ge min_aspect_area then begin
                    if finite(caspect) && caspect gt asp2d then begin
                        asp2d = caspect
                    endif
                endif
                if arg_present(candidate) then begin
                    j = {pos:f, x:x, y:y, aspect:caspect, baspect:baspect, vbeta:vbeta, rotx:rotx, roty:roty, clust:clustN, totasp:total_aspect}
                    candidate.add,j
                endif
            endif
        endif 
    endfor
    OK = asp2d ge aspect_threshold_2d
endif

return, OK

end
