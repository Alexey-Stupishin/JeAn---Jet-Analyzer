pro pipeline_aia_make_movie_by_frames, prefix, from_dir, to_filename, use_jpg = use_jpg, fps = fps, instrument = instrument

extns = '.png'
if n_elements(use_jpg) ne 0 then extns = '.jpg'
if n_elements(instrument) eq 0 then instrument = 'aia'

inst_mask = from_dir + path_sep() + prefix + '_' + instrument + '%05d' + extns
asu_make_movie_by_frames, inst_mask, to_filename, fps = fps

end
