pro l_irc_clust_proc, kx, ky, cmask, clust, clustn, is_diag

if cmask[kx, ky] eq 0 || clust[kx, ky] gt 0 then return

sz = size(cmask)
clust[kx, ky] = clustn

for kyy = ky-1, ky+1 do begin
    for kxx = kx-1, kx+1 do begin
        if kxx lt 0 || kxx gt sz[1]-1 || kyy lt 0 || kyy gt sz[2]-1 then continue
        if ~is_diag && ~(kx eq kxx || ky eq kyy) then continue
        l_irc_clust_proc, kxx, kyy, cmask, clust, clustn, is_diag 
    endfor
endfor

end

pro pipeline_aia_irc_cluster_m0, cmask, is_diag, clust

sz = size(cmask)
clust = intarr(sz[1], sz[2])

clustn = 0

for ky = 0, sz[2]-1 do begin
    for kx = 0, sz[1]-1 do begin
        if cmask[kx, ky] eq 0 || clust[kx, ky] gt 0 then continue
        clustn++
        l_irc_clust_proc, kx, ky, cmask, clust, clustn, is_diag
    endfor
endfor

end
