pro pipeline_aia_irc_cluster_clean_exp, clust, mask

clust[where(mask eq 0)] = 0

end
