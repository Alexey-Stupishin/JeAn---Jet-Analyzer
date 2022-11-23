pro pipeline_aia_download_aia_full_selected, wave, aia_dir_add, config, down_message = down_message, downlist = downlist
compile_opt idl2

tt = strarr(3) 
tt[0] = config.tstart
tt[2] = config.tstop

tsj = asu_anytim2julday(tt[0])
tej = asu_anytim2julday(tt[2])
tcj = (tsj+tej)/2
tt[1] = asu_julday2str(tcj)

delt = wave gt 1000 ? 12 : 6

for k = 0, n_elements(tt)-1 do begin
    conft = config
    t = asu_anytim2julday(tt[k])
    tm = asu_julday_mod(t, secs = -delt)
    conft.tstart = asu_julday2str(tm)
    tp = asu_julday_mod(t, secs = delt)
    conft.tstop = asu_julday2str(tp)
    pipeline_aia_download_aia_full, wave, aia_dir_add, conft, dirmode = 'direct'
end

end
