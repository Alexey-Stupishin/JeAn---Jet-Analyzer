function xy2carrington, x_arcsec, y_arcsec, time_ref
compile_opt idl2
  wcs_ref = wcs_2d_simulate(4096, 4096, date_obs = time_ref)
  n = n_elements(x_arcsec)
  crd = dblarr(2,n)
  crd[0,*] = x_arcsec
  crd[1,*] = y_arcsec
  wcs_convert_from_coord, wcs_ref, crd, 'HG', cr_lon, cr_lat,/carrington
  return, {cr_lon: cr_lon, cr_lat:cr_lat}

end

pro pipeline_aia_fits_cutout, fits_in, fits_out, config, nofits = nofits, sav = sav
compile_opt idl2
  cdelt = [0.6d, 0.6d]
  read_sdo_silent, fits_in, index_in, data_in, /use_shared, /uncomp_delete, /hide, /silent
  data_in = float(data_in)
  wcs_in = fitshead2wcs(index_in)
  
  size_px = [config.wpix, config.hpix]
  pos = config
  Robs = sqrt(pos.xc^2 + pos.yc^2)
  Rctr = index_in.rsun_obs - 15
  if Robs gt Rctr then begin
    pos.xc *= Rctr/Robs 
    pos.yc *= Rctr/Robs 
  endif   
  center = xy2carrington(pos.xc, pos.yc, config.tref)
  wcs_convert_to_coord, wcs_in, crval, 'HG', center.cr_lon, center.cr_lat, /carrington
  
  index_out = index_in
  index_out.cdelt1 = cdelt[0]
  index_out.cdelt2 = cdelt[1]
  index_out.naxis1 = size_px[0]
  index_out.naxis2 = size_px[1]
  index_out.crval1 = crval[0]
  index_out.crval2 = crval[1]
  index_out.crpix1 = size_px[0]*0.5
  index_out.crpix2 = size_px[1]*0.5
  wcs_out = fitshead2wcs(index_out)
  data_out = wcs_remap(data_in, wcs_in, wcs_out)
  
  ;exposure_normalisation
  data_out /= index_in.exptime
  index_out.exptime =1.0
  
  if not keyword_set(nofits) then begin
      writefits_silent, fits_out, float(data_out), struct2fitshead(index_out)
  endif
  if keyword_set(sav) then begin
      expr = stregex(fits_out,'(.+)\.fits',/subexpr,/extract)
      sav_out = expr[1] + '.sav'
      cdelt1 = index_out.cdelt1
      cdelt2 = index_out.cdelt2
      naxis1 = index_out.naxis1
      naxis2 = index_out.naxis2
      crval1 = index_out.crval1
      crval2 = index_out.crval2
      crpix1 = index_out.crpix1
      crpix2 = index_out.crpix2
      date_obs = index_out.date_obs
      dsun_obs = index_out.dsun_obs
      dsun_ref = index_out.dsun_ref
      rsun_obs = index_out.rsun_obs
      rsun_ref = index_out.rsun_ref
      rsun = index_out.r_sun
      wavelnth = index_out.wavelnth
      x0_mp = index_out.x0_mp
      xcen = index_out.xcen
      y0_mp = index_out.y0_mp
      ycen = index_out.ycen
      save, filename = sav_out, data_out, cdelt1, cdelt2, naxis1, naxis2, crval1, crval2, crpix1, crpix2 $
                              , date_obs, dsun_obs, dsun_ref, rsun_obs, rsun_ref, rsun, wavelnth, x0_mp, xcen, y0_mp, ycen   
  endif
end

;pro pipeline_aia_dir_cutout, dir_in, dir_out, center, size_px, nofits = nofits, sav = sav
;  files_in = file_search(filepath('*.fits', root_dir = dir_in))
;  files_out = filepath(file_basename(files_in), root_dir = dir_out)
;  foreach file_in, files_in, i do begin
;    file_out =  files_out[i]
;    pipeline_aia_fits_cutout, file_in, file_out, center, size_px, nofits = nofits, sav = sav
;  endforeach
;end


pro pipeline_aia_cutout, aia_dir_cache, work_dir, wave, aia_dir_wave_sel, config, nofits = nofits, sav = sav
    t0 = systime(/seconds)
   
    aia_download_get_query, wave, config.tstart, config.tstop, urls, filenames

    n_files = n_elements(filenames)
    
    cnt = 0
    ctrl = 5  
    save_dir = work_dir + path_sep() + aia_dir_wave_sel
    files_out = save_dir + path_sep() + filenames
    file_mkdir, save_dir
    foreach filename, filenames, j do begin
        file_out =  files_out[j]
        if file_test(file_out) then continue
        date = asu_date_from_filename(filename)
        wave_dir = aia_dir_cache + path_sep() + date + path_sep() + strcompress(wave, /remove_all)
        file_in = wave_dir + path_sep() + filename
        pipeline_aia_fits_cutout, file_in, file_out, config, nofits = nofits, sav = sav
        if double(cnt)/n_files*100d gt ctrl then begin
            print, 'Wave ' + strcompress(wave, /remove_all) + ': cutout area, ' + strcompress(ctrl,/remove_all) + '%'
            ctrl += 5 
        endif
        cnt++
    endforeach
  
;    message, strcompress(string(systime(/seconds)-t0,format="('cutoff performed in ',g0,' seconds')")), /cont
    message, 'cutoff performed in ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /cont
end