pro pipeline_aia_irc_renumber_clusters, clust
  uniq_val = clust[uniq(clust, sort(clust))]
  n = n_elements(uniq_val)
  ren_asp = dblarr(n+1)
  for i=1,n-1 do begin
    ind = where(clust eq uniq_val[i])
    clust[ind] = i
  endfor

end