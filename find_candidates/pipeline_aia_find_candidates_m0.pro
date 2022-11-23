function pipeline_aia_find_candidates_m0, work_dir, aia_dir_wave_sel, wave, obj_dir, config, files_in, presets

pipeline_aia_get_input_files, config, work_dir + path_sep() + aia_dir_wave_sel, files_in

;seq = !NULL
;aia_lim = !NULL
;rdf_lim = !NULL
n_files = files_in.Count()

pipeline_aia_read_prepare_data, files_in.ToArray(), run_diff, data, ind_seq

aia_lim = minmax(data)
rdf_lim = minmax(run_diff)

par1 = presets.par1
par2 = presets.par2
parcom = presets.parcom

szr = size(run_diff)
n = szr[3]
postponed = list()
postID = 0

ctrl = 5
for i = 0, n-1 do begin
    pipeline_aia_irc_process_m0, run_diff[*, *, i], par1, clusters, i
    for k = 0, n_elements(clusters)-1 do begin
        postponed.Add, {pos:i, ID:postID, cluster:clusters[k]}
        print, '   pos = ' + strcompress(i,/remove_all) + ', ID = ' + strcompress(postID,/remove_all)+ ', ' + pipeline_aia_irc_clust_verbose(clusters[k]) 
        postID++
    endfor
    if double(i)/n*100d gt ctrl then begin
        print, 'find candidates, ' + strcompress(ctrl,/remove_all) + '%'
        ctrl += 5 
    endif
endfor

found_candidates = list()
while ~postponed.IsEmpty() do begin
    pipeline_aia_irc_process_multi_m0, run_diff, postponed, par2, parcom, jet_seq
    if ~jet_seq.IsEmpty() then found_candidates.Add, jet_seq
endwhile 

print, ' '
print, 'Found ' + strcompress(n_elements(found_candidates),/remove_all) + ' candidates'
foreach cand, found_candidates, i do begin
    lng = n_elements(cand)
    limx = intarr(2)
    limy = intarr(2)
    limx[0] = 10000
    limy[0] = 10000
    for k = 0, lng-1 do begin
        pipeline_aia_irc_get_clust_val, cand[k], cx, cy, climx, climy
        limx[0] = min([limx[0], climx[0]])
        limx[1] = max([limx[1], climx[1]])
        limy[0] = min([limy[0], climy[0]])
        limy[1] = max([limy[1], climy[1]])
    endfor 
    print, strcompress(i,/remove_all) + ': ' + strcompress(cand[0].pos,/remove_all) + ' - ' + strcompress(cand[lng-1].pos,/remove_all) $
                       + ' [' + strcompress(fix(limx[0]),/remove_all) + '-' + strcompress(fix(limx[1]),/remove_all) + ']x[' $
                       + strcompress(fix(limy[0]),/remove_all) + '-' + strcompress(fix(limy[1]),/remove_all) + ']'        
endforeach

prefix = work_dir + path_sep() + obj_dir + path_sep() + strcompress(fix(wave),/remove_all)
save, filename = prefix + '.sav', found_candidates, aia_lim, rdf_lim, ind_seq
if n_elements(found_candidates) gt 0 then begin
    pipeline_aia_csv_output, prefix + '.csv', found_candidates, ind_seq
endif

return, found_candidates.Count()
 
end