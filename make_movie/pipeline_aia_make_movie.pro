pro pipeline_aia_make_movie, wave, vis_data_dir_wave, vis_data_dir, details, work_dir, config, use_jpg = use_jpg, fps = fps

if n_elements(fps) eq 0 then fps = 5

prefix = pipeline_aia_get_vis_prefix(config)

filename = work_dir + path_sep() + vis_data_dir + path_sep() + prefix + '_' + strcompress(long(wave),/remove_all) + '.mp4'
pipeline_aia_make_movie_by_frames, prefix, work_dir + path_sep() + vis_data_dir_wave, filename, use_jpg = use_jpg, fps = fps

for k = 0, n_elements(details)-1 do begin
    detdir = work_dir + path_sep() + vis_data_dir_wave + path_sep() + details[k]
    filename = work_dir + path_sep() + vis_data_dir + path_sep() + prefix + '_' + strcompress(long(wave),/remove_all) + '_' + details[k] + '.mp4'
    pipeline_aia_make_movie_by_frames, prefix, detdir, filename, use_jpg = use_jpg, fps = fps
endfor  

end
