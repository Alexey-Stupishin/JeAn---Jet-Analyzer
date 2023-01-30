function pipeline_aia_irc_filter_clusters_get_features_frame, pos, card, x, y, vbeta, aspect, baspect, waspect, rotx, roty, clust, speed
    frame = {pos:pos, card:card, x:x, y:y, beta:vbeta, aspect:aspect, baspect:baspect, waspect:waspect, rotx:rotx, roty:roty, clust:clust, speed:speed}
    return, frame
end

function pipeline_aia_irc_filter_clusters_get_features, clust, k, presets, rd_check

features = {clust_n:k, pos: 0L, length:0L, total_card:0L, max_card:0L, total_asp:0d, max_asp:0d, max_basp:0d, max_wasp:0d, total_wasp:0d $
          , total_speed:0d, max_speed:0d, av_speed:0d, med_speed:0d, from_start_speed:0d, total_lng:0d, av_width:0d, frames:list(), quartiles:[0d, 0d, 0d]}

cmask = clust eq k

index = where(cmask, count)
features.total_card = count
if features.total_card eq 0 then return, features

ids = array_indices(cmask, index)
mi = min(ids[2, *])
ma = max(ids[2, *])
features.pos = mi
features.length = ma - mi + 1

tmask = total(cmask, 3) gt 0
pipeline_aia_irc_get_cluster_coords, tmask, 1, x, y
irc_principale_comps, x, y, vx, vy, caspect = caspect, waspect = waspect, tot_lng = tot_lng, av_width = av_width
features.total_asp = caspect
features.total_wasp = waspect
features.total_lng = tot_lng
features.av_width = av_width

c = clust[*, *, mi]
pipeline_aia_irc_get_cluster_coords, c, k, x1, y1
c = clust[*, *, ma]
pipeline_aia_irc_get_cluster_coords, c, k, x2, y2
features.total_speed = pipeline_aia_irc_get_aspects_clusters_get_speed(x1, y1, x2, y2, ma - mi)

totcard = 0
for f = mi, ma do begin
    mask = where(clust[*, *, f] eq k, count)
    totcard += count
endfor
    
prevx = !NULL
prevy = !NULL
prevf = !NULL
speeds = dblarr(ma-mi+1)
nspeeds = 0
sigma = dblarr(totcard);
sigpos = 0
xsc0 = !NULL
ys0 = !NULL
for f = mi, ma do begin
    frame = pipeline_aia_irc_filter_clusters_get_features_frame(f, 0, 0L, 0L, 0d, 0d, 0d, 0d, 0d, 0d, 0d, 0d)
    c = clust[*, *, f]
    cmask = where(c eq k, count)
    if count gt 0 then begin
        rd = rd_check[*, *, f]
        sigma[sigpos:sigpos+count-1] = rd[cmask]
        sigpos += count
        
        features.max_card = max([features.max_card, count])
        
;        pipeline_aia_irc_get_cluster_coords, c, k, x, y
        xy = array_indices(c, cmask)
        x = transpose(xy[0, *])
        y = transpose(xy[1, *])
        irc_principale_comps, x, y, vx, vy, vbeta = vbeta, rotx = rotx, roty = roty, caspect = caspect, baspect = baspect, waspect = waspect
        if n_elements(x) ge presets.min_aspect_area then begin
            features.max_asp  = max([features.max_asp,  caspect])
            features.max_basp = max([features.max_basp, baspect])
            features.max_wasp = max([features.max_wasp, waspect])
        endif
            
        speed = 0d
        if prevx ne !NULL then begin
            speed = pipeline_aia_irc_get_aspects_clusters_get_speed(prevx, prevy, x, y, f - prevf)
            speeds[nspeeds] = speed
            nspeeds += 1
        endif
        features.max_speed = max([features.max_speed, speed])
        
        if f eq mi then begin
            xs0 = x 
            ys0 = y
        endif else begin
            features.from_start_speed = max([features.from_start_speed, pipeline_aia_irc_get_aspects_clusters_get_speed(xs0, ys0, x, y, f - mi)])
        endelse
        
        prevx = x
        prevy = y
        prevf = f
        
        frame = pipeline_aia_irc_filter_clusters_get_features_frame(f, n_elements(x), x, y, vbeta, caspect, baspect, waspect, rotx, roty, k, speed)
    endif
    features.frames.Add, frame
endfor

idxs = where(sigma ge presets.mask_threshold, count)
if count gt 1 then begin
    sigma = sigma(idxs)
    q2 = median(sigma)
    idxs = where(sigma le q2)
    q1 = median(sigma[idxs])
    idxs = where(sigma ge q2)
    q3 = median(sigma[idxs])
    features.quartiles = [q1, q2, q3]
endif
if nspeeds gt 0 then begin
    speeds = speeds[0:nspeeds-1]
    features.av_speed = total(speeds)/nspeeds
    features.med_speed = median(speeds)
endif

return, features

end
