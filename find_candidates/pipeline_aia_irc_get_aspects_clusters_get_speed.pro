function pipeline_aia_irc_get_aspects_clusters_get_speed, x1, y1, x2, y2, dframe

if dframe eq 0 then return, 0d

dx = mean(x1) - mean(x2)
dy = mean(y1) - mean(y2)
return, sqrt(dx^2 + dy^2)*0.6d*725d / (dframe*12d)

end
