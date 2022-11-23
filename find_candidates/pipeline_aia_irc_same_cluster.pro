function pipeline_aia_irc_same_cluster, seed, j, par, same_area

same_area = -1

pipeline_aia_irc_get_clust_val, j, jcx, jcy, jlimx, jlimy
pipeline_aia_irc_get_clust_val, seed, scx, scy, slimx, slimy

dx = min([slimx[1], jlimx[1]]) - max([slimx[0], jlimx[0]])
dy = min([slimy[1], jlimy[1]]) - max([slimy[0], jlimy[0]])
if dx le 0 or dy le 0 then return, -1 

distance = sqrt((scx-jcx)^2 + (scy-jcy)^2)
if distance gt par.crit_dist then return, -1

jarea = (jlimx[1] - jlimx[0])*(jlimy[1] - jlimy[0])
sarea = (slimx[1] - slimx[0])*(slimy[1] - slimy[0])
cross_area = dx*dy
same_area = cross_area * 1d / min([jarea, sarea])
if same_area lt par.crit_area then return, -1

return, distance

end
