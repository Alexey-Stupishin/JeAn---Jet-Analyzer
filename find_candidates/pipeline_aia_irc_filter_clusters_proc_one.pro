function pipeline_aia_irc_filter_clusters_proc_one, clust3d, k, presets, rd_check

features = pipeline_aia_irc_filter_clusters_get_features(clust3d, k, presets, rd_check)
OK = pipeline_aia_irc_filter_clusters_criteria(features, presets)

if OK eq 0 then return, !NULL

return, features

end
