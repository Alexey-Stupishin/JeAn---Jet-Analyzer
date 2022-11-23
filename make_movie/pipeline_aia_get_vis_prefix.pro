function pipeline_aia_get_vis_prefix, config

time = anytim(config.tstart, out_style = 'UTC_EXT')
time_rel = string(time.year,FORMAT = '(I04)') + string(time.month,FORMAT='(I02)') + string(time.day,FORMAT='(I02)') + '_' $
         + string(time.hour,FORMAT = '(I02)') + string(time.minute,FORMAT='(I02)') + string(time.second,FORMAT='(I02)')
prefix = time_rel $
    + '_' + strcompress(fix(config.xc),/remove_all) + '_' + strcompress(fix(config.yc),/remove_all) 

return, prefix

end
    