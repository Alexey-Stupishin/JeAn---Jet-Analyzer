pro pipeline_aia_irc_process,data, rd, par,  regions

pipeline_aia_irc_get_mask,data, rd, par.mask_threshold, cmask
PIPELINE_AIA_IRC_MORPH_FILTER, CMASK, par.min_size, par.fill_size, par.border
pipeline_aia_irc_cluster, cmask, 1, clust
pipeline_aia_irc_cardinality_filter, cmask, clust, par.min_area
regions = clust


    
end
