function pipeline_aia_download_aia_cutout, wave, save_dir, config, down_message = down_message
compile_opt idl2

ts = anytim(config.tstart)
te = anytim(config.tstop)
n_frames = (te-ts)/12

n_done = 0

postponed = list()
post_n = 0

swave = strcompress(wave, /remove_all)

ds = 'aia.lev1_euv_12s'
if (swave eq '1600') or (swave eq '1700') then begin
  ds = 'aia.lev1_uv_24s'
endif

time = anytim(config.tstart, out_style = 'UTC_EXT')
Rctr = asu_solar_radius(time.year, time.month, time.day) - 15
Robs = sqrt(config.xc^2 + config.yc^2)
if Robs gt Rctr then begin
    config.xc *= Rctr/Robs 
    config.yc *= Rctr/Robs 
endif   

query = jsoc_get_query(ds,config.tstart, config.tstop,swave,segment='image', $
  processing=processing, t_ref=config.tref, x=config.xc, y=config.yc,$
   width=config.wpix, height=config.hpix)
message,"Requesting data from JSOC...",/info
urls = jsoc_get_urls(query,processing=processing, file_names=filenames)
msg = "got "+strcompress(n_elements(urls),/remove_all)+" URLs"
message,msg,/info

message,'downloading with aria2...',/info
aria2_urls_rand, urls, save_dir
message, 'download complete', /info

return, [ts, te]
  
end

