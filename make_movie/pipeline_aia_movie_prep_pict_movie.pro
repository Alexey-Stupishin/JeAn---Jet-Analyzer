pro l_pipeline_aia_movie_get_pict_scale, x, y, ind, xstep, xshift, ystep, yshift

xstep = ind.CDELT1
ystep = ind.CDELT2
 
xshift = (x - ind.CRPIX1)*ind.CDELT1 + ind.CRVAL1 
yshift = (y - ind.CRPIX2)*ind.CDELT2 + ind.CRVAL2 

end

pro pipeline_aia_movie_prep_pict_movie, work_dir, obj_dir, vis_data_dir, wave, aia_dir_wave_sel, vis_data_dir_wave, details, config, presets, files_in $
                                , use_jpg = use_jpg, use_contour = use_contour, no_save_empty = no_save_empty, graphtype = graphtype, no_details = no_details $
                                , run_diff = run_diff, data_full = data_full, ind_seq = ind_seq, fps = fps

if n_elements(graphtype) eq 0 then graphtype = 1
if n_elements(use_contour) eq 0 then use_contour = 1
extns = '.png'
if use_jpg then extns = '.jpg'

if n_elements(fps) eq 0 then fps = 5

windim = [1600, 800]

prefix = pipeline_aia_get_vis_prefix(config)

cand_mask = strcompress(fix(wave),/remove_all) + '.sav'
file_cand = file_search(filepath(cand_mask, root_dir = work_dir + path_sep() + obj_dir))
curr_seq = !NULL
pos0 = -1
aia_lim = !NULL
rdf_lim = !NULL
if file_cand eq '' then begin
    message, /info, "wave " + strcompress(wave,/remove_all) + " - no candidate file!"
    found_candidates = list()
    if keyword_set(no_save_empty) then return
endif else begin
    restore, file_cand
    if found_candidates.IsEmpty() then begin
        message, /info, "wave " + strcompress(wave,/remove_all) + " - no candidates!"
        if keyword_set(no_save_empty) then return
    endif
endelse

l_pipeline_aia_movie_get_pict_scale, 0, 0, ind_seq[0], xstep, xshift, ystep, yshift

if n_elements(run_diff) eq 0 || n_elements(data_full) eq 0 || n_elements(ind_seq) eq 0 then begin
    pipeline_aia_read_prepare_data, files_in, run_diff, data_full, ind_seq, presets
endif

;setting limits
aia_lim = minmax(data_full)
rdf_lim = minmax(sigrange(run_diff))

if graphtype eq 0 then begin
    win = window(dimensions = windim)
    pipeline_aia_get_colormaps, wave, aia_lim, cm_aia, rdf_lim, cm_run_diff
    graphtype = 0
endif else begin    
    ;Use Z-buffer for generating plots
    set_plot,'Z'
    device,set_resolution = windim, set_pixel_depth = 24, decomposed =0
    !p.color = 0
    !p.background = 255
    !p.charsize=1.5
    cm_aia = !NULL
    cm_run_diff = !NULL
    graphtype = 1
endelse


ctrl =0.
n_files = n_elements(files_in)
szrd = size(run_diff)
foreach file_in, files_in[0:szrd[3]-1], i do begin
    rtitle = ''

    pos = i-1 ; position in run_diff
    rd = run_diff[*,*,i]
    data = data_full[*,*,i]
    index = ind_seq[i]
    sz = size(rd)
    jet = lonarr(sz[1], sz[2])
    rtitle = ''
    for k = 0, found_candidates.Count()-1 do begin
        cand = found_candidates[k]
        frames = cand.frames
        for j = 0, frames.Count()-1 do begin
            snap = frames[j]
            if snap.pos eq pos then begin
                card = n_elements(snap.x)
                rtitle += ' ' + strcompress(k+1,/remove_all) + '(' + strcompress(card,/remove_all) + ')' ; + aspect?
                for n = 0, card-1 do begin
;                    jet(snap.x[n], snap.y[n]) = snap.clust
                    jet(snap.x[n], snap.y[n]) = 1
                endfor
            endif    
        endfor
    endfor
    
    jtitle = str_replace(str_replace(index.t_obs, 'T', ' '), 'Z', '')
        
    if double(i)/n_files*100d gt ctrl then begin
        message, 'Preparing movie , ' + strcompress(ctrl,/remove_all) + '%',/info
        ctrl += 5 
    endif
    outfile =  work_dir + path_sep() + vis_data_dir_wave + path_sep() + prefix + "_aia" + string(i, FORMAT = '(I05)') + extns
    if graphtype eq 0 then begin
        win.Erase
        pipeline_aia_movie_draw_m0, data, rd, jet, win, jtitle, rtitle, xstep, xshift, ystep, yshift, aia_lim, cm_aia, rdf_lim, cm_run_diff, use_contour
        if ~keyword_set(nosave) then win.Save, outfile, width = windim[0], height = windim[1], bit_depth = 2 
    endif else begin
        erase
        pipeline_aia_movie_draw, data, rd, jet,  jtitle, rtitle, xstep, xshift,$
           ystep, yshift, aia_lim, rdf_lim,  wave = wave
        if ~keyword_set(nosave) then begin
            if use_jpg then write_jpeg, outfile, tvrd(true=1), true =1, quality =100 $
            else write_png, outfile, tvrd(true=1)
        endif 
    endelse
endforeach

if graphtype eq 0 then win.Close

filename = work_dir + path_sep() + vis_data_dir + path_sep() + prefix + '_' + strcompress(long(wave),/remove_all) + '.mp4'
pipeline_aia_make_movie_by_frames, prefix, work_dir + path_sep() + vis_data_dir_wave, filename, use_jpg = use_jpg, fps = fps

details = list()

if n_elements(no_details) gt 0 and keyword_set(no_details) then return

frames_prev = 6
frames_post = 3
expandk = 1.4
minview = 70

details = list()
for k = 0, n_elements(found_candidates)-1 do begin
    cand = found_candidates[k]
    frames = cand.frames
    nc = frames.Count()
    xbox = !NULL
    ybox = !NULL
    for j = 0, nc-1 do begin
        snap = frames[j]
        if xbox eq !NULL then begin
            xbox = intarr(2)
            ybox = intarr(2)
            xbox[0] = min(snap.x)
            xbox[1] = max(snap.x)
            ybox[0] = min(snap.y)
            ybox[1] = max(snap.y)
        endif  
        xbox[0] = min([xbox[0], min(snap.x)])
        xbox[1] = max([xbox[1], max(snap.x)])
        ybox[0] = min([ybox[0], min(snap.y)])
        ybox[1] = max([ybox[1], max(snap.y)])
    endfor
    dx = xbox[1]-xbox[0]
    xexpand = fix(max([minview, dx*expandk])/2d)
    xbox[0] = max([0, xbox[0]-xexpand])  
    xbox[1] = min([ind_seq[0].naxis1-1, xbox[1]+xexpand])  
    dy = ybox[1]-ybox[0]
    yexpand = fix(max([minview, dy*expandk])/2d)
    ybox[0] = max([0, ybox[0]-yexpand])  
    ybox[1] = min([ind_seq[0].naxis2-1, ybox[1]+yexpand])  
    
    l_pipeline_aia_movie_get_pict_scale, xbox[0], ybox[0], ind_seq[0], xstep, xshift, ystep, yshift
    from = max([0, frames[0].pos-frames_prev])
    to = min([frames[nc-1].pos+frames_post, n_elements(files_in)-3])
    data_prev = !NULL

    if graphtype eq 0 then win = window(dimensions = windim)
    
    detname = "detail" + string(k+1, FORMAT = '(I04)')
    details.Add, detname 
    vis_data_wave_add = work_dir + path_sep() + vis_data_dir_wave + path_sep() + detname
    file_mkdir, vis_data_wave_add
    ctrl =0.
    n_files = to - from+1
    for i = from, to do begin
        file_in = files_in[i]
        pos = i-1 ; position in run_diff
        rd = run_diff[*,*,i]
        data = data_full[*,*,i]
        index = ind_seq[i]
        data = data[xbox[0]:xbox[1], ybox[0]:ybox[1]]
        rd = rd[xbox[0]:xbox[1], ybox[0]:ybox[1]]
        sz = size(rd)
        jet = dblarr(sz[1], sz[2])
        rtitle = ''
        snap = !NULL
        for jc = 0, nc-1 do begin
            if pos eq frames[jc].pos then begin
                snap = frames[jc]
                break
            endif  
        endfor  
        if snap ne !NULL then begin
            card = n_elements(snap.x)
            rtitle += ' ' + strcompress(k+1,/remove_all) + "(" + strcompress(card,/remove_all) + ", " + strcompress(string(snap.aspect, FORMAT = '(F6.1)'),/remove_all) + ")"
            for n = 0, card-1 do begin
                jet(snap.x[n]-xbox[0], snap.y[n]-ybox[0]) = 1
            endfor
        endif
        
        jtitle = str_replace(str_replace(index.t_obs, 'T', ' '), 'Z', '')
        if double(i - from+1)/n_files*100d gt ctrl then begin
          message, 'Preparing movie , ' + strcompress(ctrl,/remove_all) + '%',/info
          ctrl += 5
        endif
        outfile = vis_data_wave_add + path_sep() + prefix + "_aia" + string(i-from, FORMAT = '(I05)') + extns
        if graphtype eq 0 then begin
            win.Erase
            pipeline_aia_movie_draw_m0, data, rd, jet, win, jtitle, rtitle, xstep, xshift, ystep, yshift, aia_lim, cm_aia, rdf_lim, cm_run_diff, use_contour
            if ~keyword_set(nosave) then win.Save, outfile, width = windim[0], height = windim[1], bit_depth = 2 
        endif else begin 
            erase
            pipeline_aia_movie_draw, data, rd, jet,  jtitle, rtitle, xstep, xshift, ystep, yshift, aia_lim, rdf_lim,  wave = wave
            if ~keyword_set(nosave) then begin
                if use_jpg then write_jpeg, outfile, tvrd(true=1), true =1, quality =100 $
                else write_png, outfile, tvrd(true=1)
            endif 
        endelse
    endfor

    if graphtype eq 0 and win ne !NULL then win.Close
    
    detdir = work_dir + path_sep() + vis_data_dir_wave + path_sep() + details[k]
    filename = work_dir + path_sep() + vis_data_dir + path_sep() + prefix + '_' + strcompress(long(wave),/remove_all) + '_' + details[k] + '.mp4'
    pipeline_aia_make_movie_by_frames, prefix, detdir, filename, use_jpg = use_jpg, fps = fps
    
endfor

end
