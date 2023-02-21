pro pipeline_aia_read_presets, presets, presets_file = presets_file 

pipeline_aia_read_presets_m0, presets0, presets_file = presets_file 

presets = { $
           MEDIAN_LIM:0.3d $
         , AIA_MEDIAN:5 $
         , MASK_THRESHOLD:3.3d $
         , STD_MEDIAN:7 $
         , MIN_SIZE:2, FILL_SIZE:15, BORDER:2 $ % space morphology
         , MIN_SIZE_T:0, FILL_SIZE_T:12, BORDER_T:0 $ % time morphology
         , MIN_AREA:80, AREA_DURATION:6 $
         , MIN_DURATION:19 $
         , MIN_MAX_CARD:80 $
         , MIN_AV_CARD:51 $
         , MIN_ASPECT:2.0d $ ; SA, MM3D methods (1, 2)
         , MIN_ASPECT_3D:1.25d $ ; MM3D methods (2)
         , MIN_WASPECT_3D:5.9d $ ; MM3D methods (2)
         , MIN_ASPECT_AREA:20 $ ; MM3D methods (2)
         , MIN_MAX_SPEED:122.0d $ ; MM3D methods (2)
         , MIN_AV_SPEED:20.9d $ ; MM3D methods (2)
         , MIN_Q25:3.49d $ ; MM3D methods (2)
         , MIN_Q75:4.23d $ ; MM3D methods (2)
         , DEBUG:0 $
         , par1:presets0.par1, par2:presets0.par2, parcom:presets0.parcom $ ; for AS method (0)
          }

if keyword_set(presets_file) then begin
    presets_data = asu_read_json_config(presets_file)
    
    presets.MEDIAN_LIM = asu_get_safe_json_key(presets_data, "MEDIAN_LIM", presets.MEDIAN_LIM)
    
    presets.AIA_MEDIAN = asu_get_safe_json_key(presets_data, "AIA_MEDIAN", presets.AIA_MEDIAN)
    presets.MASK_THRESHOLD = asu_get_safe_json_key(presets_data, "MASK_THRESHOLD", presets.MASK_THRESHOLD)
    presets.STD_MEDIAN = asu_get_safe_json_key(presets_data, "STD_MEDIAN", presets.STD_MEDIAN)
    presets.MIN_SIZE = asu_get_safe_json_key(presets_data, "MIN_SIZE", presets.MIN_SIZE)
    presets.FILL_SIZE = asu_get_safe_json_key(presets_data, "FILL_SIZE", presets.FILL_SIZE)
    presets.BORDER = asu_get_safe_json_key(presets_data, "BORDER", presets.BORDER)
    presets.MIN_SIZE_T = asu_get_safe_json_key(presets_data, "MIN_SIZE_T", presets.MIN_SIZE_T)
    presets.FILL_SIZE_T = asu_get_safe_json_key(presets_data, "FILL_SIZE_T", presets.FILL_SIZE_T)
    presets.BORDER_T = asu_get_safe_json_key(presets_data, "BORDER_T", presets.BORDER_T)
    
    presets.MIN_AREA = asu_get_safe_json_key(presets_data, "MIN_AREA", presets.MIN_AREA)
    presets.AREA_DURATION = asu_get_safe_json_key(presets_data, "AREA_DURATION", presets.AREA_DURATION)
    presets.MIN_DURATION = asu_get_safe_json_key(presets_data, "MIN_DURATION", presets.MIN_DURATION)
    presets.MIN_ASPECT = asu_get_safe_json_key(presets_data, "MIN_ASPECT", presets.MIN_ASPECT)
    presets.MIN_ASPECT_3D = asu_get_safe_json_key(presets_data, "MIN_ASPECT_3D", presets.MIN_ASPECT_3D)
    presets.MIN_WASPECT_3D = asu_get_safe_json_key(presets_data, "MIN_WASPECT_3D", presets.MIN_WASPECT_3D)
    presets.MIN_ASPECT_AREA = asu_get_safe_json_key(presets_data, "MIN_ASPECT_AREA", presets.MIN_ASPECT_AREA)

    presets.MIN_MAX_CARD = asu_get_safe_json_key(presets_data, "MIN_MAX_CARD", presets.MIN_MAX_CARD)
    presets.MIN_AV_CARD = asu_get_safe_json_key(presets_data, "MIN_AV_CARD", presets.MIN_AV_CARD)
    presets.MIN_MAX_SPEED = asu_get_safe_json_key(presets_data, "MIN_MAX_SPEED", presets.MIN_MAX_SPEED)
    presets.MIN_AV_SPEED = asu_get_safe_json_key(presets_data, "MIN_AV_SPEED", presets.MIN_AV_SPEED)
    presets.MIN_Q25 = asu_get_safe_json_key(presets_data, "MIN_Q25", presets.MIN_Q25)
    presets.MIN_Q75 = asu_get_safe_json_key(presets_data, "MIN_Q75", presets.MIN_Q75)
    presets.DEBUG = asu_get_safe_json_key(presets_data, "DEBUG", presets.DEBUG)
endif

end
