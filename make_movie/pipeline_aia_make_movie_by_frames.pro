pro pipeline_aia_make_movie_by_frames, prefix, from_dir, to_filename, use_jpg = use_jpg, fps = fps

extns = '.png'
if use_jpg then extns = '.jpg'
aia_mask = from_dir + path_sep() + prefix + '_aia%05d' + extns
asu_make_movie_by_frames, aia_mask, to_filename, fps = fps

end
