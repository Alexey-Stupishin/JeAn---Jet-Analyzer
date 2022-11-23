function pipeline_aia_irc_clust_verbose, clust

pipeline_aia_irc_get_clust_val, clust, cx, cy, limx, limy

return, '[' + strcompress(fix(limx[0]),/remove_all) + '-' + strcompress(fix(limx[1]),/remove_all) + ']x[' $
            + strcompress(fix(limy[0]),/remove_all) + '-' + strcompress(fix(limy[1]),/remove_all) + '], [' $
            + strcompress(fix(cx),/remove_all) + ',' + strcompress(fix(cy),/remove_all) + ']' $
            + ', c=' + strcompress(n_elements(clust.x),/remove_all) + ', a=' + strcompress(clust.aspect,/remove_all)
end
