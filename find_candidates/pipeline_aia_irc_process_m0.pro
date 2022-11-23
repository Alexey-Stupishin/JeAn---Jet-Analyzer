pro pipeline_aia_irc_process_m0, rd, par, snaps, pos, seed

snaps = list()

pipeline_aia_irc_get_mask_m0, rd, par.sigma1, cmask
pipeline_aia_irc_cluster_m0, cmask, 1, clust
pipeline_aia_irc_cardinality_filter_m0, clust, par.card1, rd = rd
pipeline_aia_irc_get_mask_m0, rd, par.sigma2, cmask
pipeline_aia_irc_expand_mask, cmask, par.border, maskexp
pipeline_aia_irc_cluster_m0, maskexp, 0, clust
pipeline_aia_irc_cluster_clean_exp, clust, cmask
pipeline_aia_irc_cardinality_filter_m0, clust, par.card2

crit = !NULL
jmin = !NULL
for k = 1, max(clust) do begin
;    pipeline_aia_irc_get_cluster_coords, clust, k, x, y
    idxs = where(clust eq k)
    xy = array_indices(clust, idxs)
    x = transpose(xy[0, *])
    y = transpose(xy[1, *])
    if n_elements(x) gt 0 then begin
        jcx = mean(x)
        jcy = mean(y)
    endif
    found = 0
    if n_elements(x) gt par.card2 then begin
        irc_principale_comps, x, y, vx, vy, vbeta = vbeta, rotx = rotx, roty = roty, caspect = caspect, baspect = baspect
        j = {pos:pos, x:x, y:y, aspect:caspect, baspect:baspect, vbeta:vbeta, rotx:rotx, roty:roty, clust:k, totasp:0}
        if caspect gt par.ellipse then found = 1
    endif
    
    if found then begin
        if ~keyword_set(seed) then begin
            snaps.Add, j
        endif else begin
            critk = pipeline_aia_irc_same_cluster(seed, j, par, area)
            if critk ge 0 then begin
                if crit eq !NULL || critk lt crit then begin
                    crit = critk
                    jmin = j
                endif
            endif
        endelse
    endif    
endfor

if jmin ne !NULL then begin
    snaps.Add, jmin
endif
    
end
