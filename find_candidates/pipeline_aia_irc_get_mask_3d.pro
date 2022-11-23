pro pipeline_aia_irc_get_mask_3d, rd, sigma, cmask, presets, rd_check

sz = size(rd)

cmask = lonarr(sz[1], sz[2], sz[3])
rd_check = dblarr(sz[1], sz[2], sz[3])
ctrl = 0
for i = 0, sz[3]-1 do begin
    rd_check[*, *, i] = median(abs(rd[*, *, i]), presets.std_median)
    cmask[*, *, i] = rd_check[*, *, i] gt sigma
    
    if double(i)/sz[3]*100d gt ctrl then begin
        message, ' mask preprocessing ' + strcompress(ctrl,/remove_all) + '%',/info
        ctrl += 5 
    endif
endfor

;cmask = abs(rd) gt sigma 
;if debug then rd_check = abs(rd)

end
