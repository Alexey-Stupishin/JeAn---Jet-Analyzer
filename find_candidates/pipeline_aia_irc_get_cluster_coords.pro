pro pipeline_aia_irc_get_cluster_coords, clust, k, x, y

x = []
y = []

xt = lonarr(n_elements(clust))
yt = lonarr(n_elements(clust))

sz = size(clust)
cnt = 0L
for kx = 0, sz[1]-1 do begin
    for ky = 0, sz[2]-1 do begin
        if clust[kx, ky] eq k then begin
            xt[cnt] = kx
            yt[cnt] = ky
            cnt++
        endif
    endfor
endfor

if cnt gt 0 then begin
    x = xt[0:cnt-1]
    y = yt[0:cnt-1]
endif

end
