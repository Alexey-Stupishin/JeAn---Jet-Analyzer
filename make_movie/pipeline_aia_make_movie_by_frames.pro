pro pipeline_aia_make_movie_by_frames, prefix, from_dir, to_filename, use_jpg = use_jpg, fps = fps, instrument = instrument

extns = '.png'
if n_elements(use_jpg) ne 0 && use_jpg then extns = '.jpg'
if n_elements(instrument) eq 0 then instrument = 'aia'

asu_make_movie_by_pattern, prefix + '_' + instrument, from_dir, to_filename, fps = fps, postfix = extns

end
