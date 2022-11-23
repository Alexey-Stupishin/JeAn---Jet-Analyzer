function l_pipeline_aia_find_candidates_index, index

return, {date_obs:index.date_obs, t_obs:index.t_obs, WAVELNTH:index.WAVELNTH $
         , naxis1:index.naxis1, naxis2:index.naxis2 $
         , CRPIX1:index.CRPIX1, CRPIX2:index.CRPIX2, CDELT1:index.CDELT1, CDELT2:index.CDELT2, CRVAL1:index.CRVAL1, CRVAL2:index.CRVAL2 $
         , exptime:index.exptime}

end

pro pipeline_aia_read_prepare_data, files_in_arr, run_diff, data_full, index, presets

;reading AIA files
message,'Reading data...',/info
read_sdo_silent, files_in_arr, ind_seq, data_full, /silent, /use_shared, /hide
n_files = n_elements(files_in_arr)
ind0 = l_pipeline_aia_find_candidates_index(ind_seq[0])
index = replicate(ind0, n_files)
;normalizing exposure
data_full = double(data_full > 1); change to double if necessary

kernel = [ [1, 2, 3, 2, 1], [2, 4, 6, 4, 2], [4, 8, 12, 8, 4], [2, 4, 6, 4, 2], [1, 2, 3, 2, 1] ] * 1d
kernel /= total(kernel)

meds = dblarr(n_files)
;exps = dblarr(n_files)
for i = 0, n_files-1 do begin
    index[i] = l_pipeline_aia_find_candidates_index(ind_seq[i])
;    exps[i] = ind_seq[i].exptime
    data_full[*, *, i] = median(data_full[*, *, i], presets.aia_median)
;    data_full[*, *, i] = CONVOL(data_full[*, *, i], kernel)
    meds[i] = median(data_full[*, *, i])
endfor
;medexp = median(exps)
mmeds = median(meds)

;sz = size(data_full)
;data_exp = dblarr(sz[1], sz[2], sz[3])
;data_med = dblarr(sz[1], sz[2], sz[3])
sz = size(data_full)
tot = sz[1]*sz[2]
dmax = 1d + presets.median_lim
dmin = 1d/dmax
for i = 0, n_files-1 do begin
;    data_exp[*,*,i] = data_full[*,*,i]/exps[i]*medexp
    if meds[i]/mmeds ge dmin && mmeds/meds[i] le dmax then begin
        data_full[*,*,i] = data_full[*,*,i]/meds[i]*mmeds
;        if i gt 0 then begin
;            xc = total(data_full[*,*,i])
;            xp = total(data_full[*,*,i-1])
;            xc2 = total(data_full[*,*,i]*data_full[*,*,i])
;            xcxp = total(data_full[*,*,i]*data_full[*,*,i-1])
;            a = (tot*xcxp - xp*xc)/(tot*xc2 - xc^2)
;            b = (xp - a*xc)/tot
;            data_full[*,*,i] = a*data_full[*,*,i] + b
;            message, '*** a = ' + asu_compstr(a) + ', b = ' + asu_compstr(b), /info
;        endif
    endif
endfor

mm = minmax(meds)
message, '* med/min = ' + asu_compstr(mmeds/mm[0]) + ', max/med = ' + asu_compstr(mm[1]/mmeds), /info

clust = label_region(meds/mmeds lt dmin or mmeds/meds gt dmax, /all_neighbors, /ulong)
for c = 1, max(clust) do begin
    idxs = where(clust eq c)
    n_el = n_elements(idxs)
    from = idxs[0] eq 0 ? idxs[n_el-1]+1 : idxs[0]-1  
    to = idxs[n_el-1] eq n_elements(meds)-1 ? idxs[0]-1 : idxs[n_el-1]+1
    for pos = from+1, to-1 do begin
        data_full[*,*,pos] = data_full[*,*,from] + (data_full[*,*,to]-data_full[*,*,from])*double(pos-from)/double(n_el+1)
    endfor  
endfor

;meds2 = dblarr(n_files)
;for i = 0, n_files-1 do begin
;    meds2[i] = median(data_exp[*, *, i])
;endfor
;mmeds2 = median(meds2)

;for i = 0, n_files-1 do begin
;    if medexp*0.95 ge exps[i] && exps[i] le medexp*1.05 then begin
;        data_full[*,*,i] = data_full[*,*,i]/exps[i]*medexp
;    endif else begin
;        data_full[*,*,i] = data_full[*,*,i]/meds[i]*mmeds
;    endelse
;endfor

;running difference
;data_full = (data_full[*,*,1:*] + data_full[*,*,0:-2])*0.5
;run_diff = data_full[*,*,1:-2] - data_full[*,*,0:-3]
;run_diff2 = data_full[*,*,2:*] - data_full[*,*,0:-3]
;data_full = data_full[*,*,0:-3]
;index = index[0:-3]

;data_full = data_exp
;data_full = data_med

run_diff = data_full[*,*,1:*] - data_full[*,*,0:-2]
data_full = data_full[*,*,0:-2]
index = index[0:-2]

end
