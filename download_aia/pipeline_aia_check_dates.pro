function pipeline_aia_check_dates, config, messpath, maxtime = maxtime

if n_elements(maxtime) eq 0 then maxtime = 8

ts = anytim(config.tstart)
te = anytim(config.tstop)

cond = 0
if te-ts le 0 then cond = 1
if cond eq 0 then begin
    if te-ts gt maxtime*60d*60d then cond = 2
endif

if cond ne 0 then begin
    filename = messpath + path_sep() + 'status.txt'
    openw, fnum, filename, /GET_LUN
    if cond eq 1 then printf, fnum, 'Start time greater than end time'
    if cond eq 2 then printf, fnum, 'Requested time period is too long'
    close, fnum
    FREE_LUN, fnum
    
    return, 0
endif

tref = anytim(config.tref)
if tref lt ts then config.tref = config.tstart
if tref gt te then config.tref = config.tstop

return, 1

end
