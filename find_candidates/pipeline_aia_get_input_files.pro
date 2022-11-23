pro pipeline_aia_get_input_files, config, directory, files_in

ts = anytim(config.tstart)
te = anytim(config.tstop)

files_in_all = file_search(filepath('*.fits', root_dir = directory))
files_in = list()
foreach file_in, files_in_all, i do begin
    tf = aia_date_from_filename(file_in, /q_anytim)
    if tf ge ts && tf le te then files_in.Add, file_in
endforeach

if files_in.Count() lt 2 then begin
    message, "No AIA-fits to find jets, check config and input keys."
endif

end
