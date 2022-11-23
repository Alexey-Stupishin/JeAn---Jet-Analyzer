pro pipeline_aia_csv_output, filename, candlist, aiaseq, presets = presets

if n_elements(presets) eq 0 then mincard = 0 else mincard = presets.MIN_AREA

openw, fnum, filename, /GET_LUN

printf, fnum, 'T start', 'T max', 'T end', '#', 'Duration', 'Total. card.', 'Max. card.', 'Jet asp. ratio', 'LtoW asp. ratio', 'Max. asp. ratio', 'Max. LtoW asp. ratio' $
            , 'Speed est.', 'Max speed est.', 'Av speed est.', 'Med speed est.', 'Base speed est.', 'Total length', 'Av. width', '25%', '50%', '75%', 'X from', 'X to', 'Y from', 'Y to', $
     FORMAT = '(%"%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s")'

for i = 0, candlist.Count()-1 do begin
    jet = candlist[i]
    tstart = !NULL
    tmax = !NULL
    tend = !NULL
    maxcard = 0L
    xbox = !NULL
    ybox = !NULL
    pstart = !NULL
    pend = !NULL
    for j = 0, jet.frames.Count()-1 do begin
        frames = jet.frames
        clust = frames[j]
        pos = clust.pos
        if tstart eq !NULL then begin
            tstart = aiaseq[pos].date_obs
            tmax = aiaseq[pos].date_obs
            pstart = pos
        endif
        tend = aiaseq[pos].date_obs
        pend = pos
        xarc = ([min(clust.x), max(clust.x)] - aiaseq[pos].CRPIX1)*aiaseq[pos].CDELT1 + aiaseq[pos].CRVAL1 
        yarc = ([min(clust.y), max(clust.y)] - aiaseq[pos].CRPIX2)*aiaseq[pos].CDELT2 + aiaseq[pos].CRVAL2 
        if xbox eq !NULL then begin
            xbox = xarc
            ybox = yarc
        endif
        xbox[0] = min([xbox[0], xarc[0]])
        xbox[1] = max([xbox[1], xarc[1]])
        ybox[0] = min([ybox[0], yarc[0]])
        ybox[1] = max([ybox[1], yarc[1]])
        maxcard = max([maxcard, n_elements(clust.x)], imax)
        if imax eq 1 then tmax = aiaseq[pos].date_obs
    endfor
    wsec = (pend - pstart) * 12;
    dmin = wsec/60
    dsec = wsec - dmin*60
    dur = string(dmin, "'", dsec, '"', FORMAT = '(I, A, I02, A)') 
    printf, fnum, tstart, tmax, tend, i+1, dur, jet.total_card, jet.max_card, jet.total_asp, jet.total_wasp, jet.max_asp, jet.max_wasp, jet.total_speed, jet.max_speed, jet.av_speed, jet.med_speed, jet.from_start_speed $
                    , jet.total_lng, jet.av_width, jet.quartiles[0], jet.quartiles[1], jet.quartiles[2], xbox[0], xbox[1], ybox[0], ybox[1] $
          , FORMAT = '(%"%s, %s, %s, %d,   %s,  %d,             %d,           %7.2f,         %7.2f,          %7.2f,       %7.2f,        %8.0f,           %8.0f,         %8.0f,        %8.0f,         %8.0f,         ' $
                   + '%8.1f,         %8.1f,        %8.1f,            %8.1f,            %8.1f,            %8.1f, %8.1f, %8.1f, %8.1f")'
endfor    

close, fnum
FREE_LUN, fnum

end
