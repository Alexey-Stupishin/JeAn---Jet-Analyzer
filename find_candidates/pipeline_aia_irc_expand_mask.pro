pro l_irc_expand_mask, cmask

sz = size(cmask)
mex = intarr(sz[1]+2, sz[2]+2)

for kx = 0, 2 do begin
    for ky = 0, 2 do begin
        mex[kx:sz[1]-1+kx, ky:sz[2]-1+ky] += cmask
    endfor
endfor

cmask = mex[1:sz[1], 1:sz[2]]
cmask[where(cmask gt 0)] = 1

end

pro pipeline_aia_irc_expand_mask, cmask, border, maskexp

maskexp = cmask
for k = 1, border do begin
    l_irc_expand_mask, maskexp
endfor

end
