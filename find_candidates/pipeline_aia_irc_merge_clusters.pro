pro pipeline_aia_irc_merge_clusters, clust
  message,"Merging clusters...",/info
  sz = size(clust)
  nt = sz[3]
  
  for t =0, nt - 2 do begin
    cross_mask = (clust[*,*,t] * clust[*,*,t+1]) gt 0
    if total(cross_mask) eq 0 then continue
    current = clust[*,*,t]
    next = clust[*,*,t+1]
    for i =0, 100 do begin
      diff_mask = ((current gt 0) and (next gt 0)and (current ne next))
      diff_ind = where(diff_mask)
      if diff_ind[0] eq -1 then begin
        clust[*,*,t+1] = next
        break
      endif
      cur_region = current[diff_ind[0]]
      change_ind = where(next eq next[diff_ind[0]])
      next[change_ind] = cur_region
    endfor
  endfor

end