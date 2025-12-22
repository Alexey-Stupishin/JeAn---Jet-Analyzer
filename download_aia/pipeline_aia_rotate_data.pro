function l_pipeline_aia_rotate_data_coords, coords, trans
    compile_opt idl2

    r = dblarr(2)
    r[0] =   coords[0]*trans.cs + coords[1]*trans.ss - trans.x0
    r[1] =  -coords[0]*trans.ss + coords[1]*trans.cs - trans.y0

    return, r
end

function pipeline_aia_rotate_data, data_full, transform
compile_opt idl2

data_full = double(data_full)

if transform eq !NULL then return, data_full

sz = size(data_full)
trans = asu_rotation_transformator(sz[1:2], -transform.angle)
xlim = minmax(trans.xt)
ylim = minmax(trans.yt)
;xsz = ceil(xlim[1] - xlim[0])
;ysz = ceil(ylim[1] - ylim[0])
xp = dindgen(sz[1])
yp = dindgen(sz[2])

coords = dblarr(2, 4)
coords[*, 0] = [0, transform.dleft]
coords[*, 1] = [transform.dtop, sz[2]-1]
coords[*, 2] = [sz[1]-1, transform.dright]
coords[*, 3] = [transform.dbottom, 0]

coords[*,0] = l_pipeline_aia_rotate_data_coords(coords[*,0], trans)
coords[*,1] = l_pipeline_aia_rotate_data_coords(coords[*,1], trans)
coords[*,2] = l_pipeline_aia_rotate_data_coords(coords[*,2], trans)
coords[*,3] = l_pipeline_aia_rotate_data_coords(coords[*,3], trans)

xleft = ceil(min([coords[0,0], coords[0,3]]))
xright = floor(max([coords[0,1], coords[0,2]]))
ybottom = ceil(min([coords[1,2], coords[1,3]]))
ytop = floor(max([coords[1,0], coords[1,1]]))

cut = dblarr(xright-xleft+1, ytop-ybottom+1, sz[3])
for k = 0, sz[3]-1 do begin
    remap = interp2d(data_full[*,*,k], xp, yp, trans.xt, trans.yt, missing = 0)
    ; tvplot, remap, /aspect_ratio
    cut[*,*,k] = remap[xleft:xright, ybottom:ytop]
endfor

return, cut

end
