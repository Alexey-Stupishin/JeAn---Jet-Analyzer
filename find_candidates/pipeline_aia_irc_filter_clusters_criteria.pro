function pipeline_aia_irc_filter_clusters_criteria, features, presets

;{total_card:0L, length:0L, max_card:0L, total_asp:0d, max_asp:0d, max_basp:0d, max_wasp:0d, total_wasp:0d, total_speed:0d, max_speed:0d, av_speed:0d, med_speed:0d, total_lng:0d, av_width:0d, frames:list()}

if features.total_card lt presets.min_area*presets.area_duration then return, 0
if features.max_card lt presets.min_max_card then return, 0
if features.total_card/features.length*12 lt presets.min_av_card then return, 0
if features.length lt presets.min_duration then return, 0
if features.total_asp lt presets.min_aspect_3d then return, 0
if features.total_wasp lt presets.min_waspect_3d then return, 0
if features.max_asp lt presets.min_aspect then return, 0
if features.max_speed lt presets.min_max_speed then return, 0
if features.av_speed lt presets.min_av_speed then return, 0
if features.quartiles[0] lt presets.min_q25 then return, 0
if features.quartiles[2] lt presets.min_q75 then return, 0

return, 1

end
