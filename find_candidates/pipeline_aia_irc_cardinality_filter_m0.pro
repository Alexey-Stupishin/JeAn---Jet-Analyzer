pro pipeline_aia_irc_cardinality_filter_m0, clust, card, rd = rd

av = 0
if keyword_set(rd) then av = mean(rd)

for k = 1, max(clust) do begin
    index = where(clust eq k)
    if n_elements(index) lt card then begin
        if keyword_set(rd) then rd[index] = av
        clust[index] = 0
    endif
endfor

end
