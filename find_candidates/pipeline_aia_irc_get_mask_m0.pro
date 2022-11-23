pro pipeline_aia_irc_get_mask_m0, rd, sigma, cmask

av = mean(rd)
st = stddev(rd)
sz = size(rd)
cmask = intarr(sz[1], sz[2]) + 1
index = where(rd ge av-sigma*st and rd le av+sigma*st)
cmask[index] = 0

end
