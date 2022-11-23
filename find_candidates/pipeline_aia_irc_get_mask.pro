pro pipeline_aia_irc_get_mask,data, rd, sigma, cmask

rd_abs_norm = median(abs(rd),5)

;therdolding
cmask = rd_abs_norm gt  sigma 

end
