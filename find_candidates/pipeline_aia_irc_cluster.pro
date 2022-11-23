
pro pipeline_aia_irc_cluster, cmask,all_neighbors, clust

clust = label_region(cmask, all_neighbors=all_neighbors)

end
