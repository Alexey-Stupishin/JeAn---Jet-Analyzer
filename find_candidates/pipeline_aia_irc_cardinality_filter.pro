pro pipeline_aia_irc_cardinality_filter, cmask, clust, card

for k = 1, max(clust) do begin
    index = where(clust eq k)
    if n_elements(index) lt card then begin
        clust[index] = 0
        cmask[index] = 0
    endif
endfor

end
