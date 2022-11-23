pro pipeline_aia_get_colormaps, wavelength, aia_lim, cm_aia, rdf_lim, cm_run_diff

cm_aia = !NULL
cm_run_diff = !NULL

sunglobe_aia_colors, wavelength, red, green, blue

if aia_lim ne !NULL then begin ; FIXME
    cm_aia = bytarr(256, 3)
    cm_aia[*, 0] = red 
    cm_aia[*, 1] = green 
    cm_aia[*, 2] = blue
endif else begin
    cm_aia = bytarr(256, 3)
    cm_aia[*, 0] = red 
    cm_aia[*, 1] = green 
    cm_aia[*, 2] = blue
endelse

if rdf_lim ne !NULL then begin
    cm_run_diff = bytarr(256, 3) + 255
    cm_run_diff[255, *] = transpose([255, 0, 0])
endif else begin
    cm_run_diff = bytarr(256, 3) + 255
    cm_run_diff[255, *] = transpose([255, 0, 0])
endelse

end
