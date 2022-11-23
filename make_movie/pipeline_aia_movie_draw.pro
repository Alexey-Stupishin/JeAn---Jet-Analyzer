pro pipeline_aia_movie_draw, data, rd, jet,  jtitle, rtitle, xstep,$
 xshift, ystep, yshift, aia_lim,  rdf_lim,  wave = wave

data[0, 0] = aia_lim[0]
data[0, 1] = aia_lim[1]
data = data>aia_lim[0]<aia_lim[1]
sz = size(data)
x = findgen(sz[1])*xstep+xshift
y = findgen(sz[2])*ystep+yshift
!p.multi = [2,2,1]
!p.background = 'FFFFFF'x

device, decomposed = 0
aia_lct_silent,wave = wave,/load
implot,comprange(data,2,/global),x,y,/iso,title = jtitle

rd[0, 0] = rdf_lim[0]
rd[0, 1] = rdf_lim[1]
rd = rd>rdf_lim[0]<rdf_lim[1]
loadct,0,/silent
implot, rd,x,y,/iso,title = rtitle

device, decomposed = 1
contour, gauss_smooth(jet,3,/edge_truncate),x,y, levels =[0.05],/overplot, color = '0000FF'x, thick = 3

;uniq_val = jet[uniq(jet, sort(jet))]
;for i = 1, n_elements(uniq_val)-1 do begin
;    ind = where(jet eq uniq_val[i])
;    if n_elements(ind) gt 5 then begin
;        ids = array_indices(jet, ind)
;        qhull, ids, qh
;        sz = size(qh)
;        for k = 0, sz[2]-1 do begin
;            plot, [ids[0, qh[0,k]], ids[0, qh[1,k]]]*xstep+xshift, [ids[1, qh[0,k]], ids[1, qh[1,k]]]*ystep+yshift, /noerase, color = '00FFFF'x, thick = 2
;        endfor
;    endif    
;endfor

!p.multi = 0

end
