pro pipeline_aia_read_presets_m0, presets, presets_file = presets_file 

par1 = {sigma1:2.5, card1:25, sigma2:4.0, border:2, card2:60, ellipse:4.0}
par2 = {sigma1:2.5, card1:20, sigma2:3.5, border:2, card2:25, ellipse:2.5, crit_dist:15, crit_area:0.3}
parcom = {cadences:6, gap:2}

if keyword_set(presets_file) then begin
    presets_data = asu_read_json_config(presets_file)
    
    par1.sigma1 = asu_get_safe_json_key(presets_data, "PASS1_SIGMA1", par1.sigma1)
    par1.card1 = asu_get_safe_json_key(presets_data, "PASS1_CARD1", par1.card1)
    par1.sigma2 = asu_get_safe_json_key(presets_data, "PASS1_SIGMA2", par1.sigma2)
    par1.card2 = asu_get_safe_json_key(presets_data, "PASS1_CARD2", par1.card2)
    par1.border = asu_get_safe_json_key(presets_data, "PASS1_BORDER", par1.border)
    par1.ellipse = asu_get_safe_json_key(presets_data, "PASS1_ELLIPSE", par1.ellipse)
        
    par2.sigma1 = asu_get_safe_json_key(presets_data, "PASS2_SIGMA1", par2.sigma1)
    par2.card1 = asu_get_safe_json_key(presets_data, "PASS2_CARD1", par2.card1)
    par2.sigma2 = asu_get_safe_json_key(presets_data, "PASS2_SIGMA2", par2.sigma2)
    par2.card2 = asu_get_safe_json_key(presets_data, "PASS2_CARD2", par2.card2)
    par2.border = asu_get_safe_json_key(presets_data, "PASS2_BORDER", par2.border)
    par2.ellipse = asu_get_safe_json_key(presets_data, "PASS2_ELLIPSE", par2.ellipse)
    par2.crit_dist = asu_get_safe_json_key(presets_data, "CRIT_DIST", par2.crit_dist)
    par2.crit_area = asu_get_safe_json_key(presets_data, "CRIT_AREA", par2.crit_area)
        
    parcom.cadences = asu_get_safe_json_key(presets_data, "CADENCES", parcom.cadences)
    parcom.gap = asu_get_safe_json_key(presets_data, "GAP", parcom.gap)
endif
    
presets = {par1:par1, par2:par2, parcom:parcom}

end