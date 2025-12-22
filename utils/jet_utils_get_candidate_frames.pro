function jet_utils_get_candidate_frames, cand

frames = cand.frames
n_frames = frames.Count()

fr = replicate({pos:0L, card:0L, datetime:'', sec_from_start:0d, juliandate:0d, baspect:0d, waspect:0d, clust:0L, speed:0d, flux:0d, xarc:0d, yarc:0d}, n_frames)
for k = 0, n_frames-1 do begin
    f = frames[k]
    
    fr[k].pos = f.pos
    fr[k].card = f.card
    fr[k].datetime = f.datetime
    fr[k].sec_from_start = f.sec_from_start
    fr[k].juliandate = f.juliandate
    fr[k].baspect = f.baspect
    fr[k].waspect = f.waspect
    fr[k].clust = f.clust
    fr[k].speed = f.speed
    fr[k].flux = f.flux
    fr[k].xarc = f.xarc
    fr[k].yarc = f.yarc
endfor

return, fr

end
