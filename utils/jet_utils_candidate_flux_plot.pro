function jet_utils_candidate_flux_plot, candlist, numbers = numbers, lim_plots = lim_plots, strat_from = strat_from, windim = windim, title = title, sec = sec
compile_opt idl2

if n_elements(windim) eq 0 then windim = [1500, 1000]
win = window(dimensions = windim)

if n_elements(numbers) eq 0 then numbers = indgen(candlist.Count())
n = n_elements(numbers)
ymax_arr = dblarr(n)
for k = 0, n-1 do begin
    cand = jet_utils_get_candidate(candlist, numbers[k])
    frames = jet_utils_get_candidate_frames(cand)
    ymax_arr[k] = max(frames.flux)
endfor

idx = reverse(sort(ymax_arr))

if n_elements(lim_plots) eq 0 then lim_plots = n else lim_plots = min([lim_plots, n])
numbers = numbers[idx[0:lim_plots-1]]

n = n_elements(numbers)
ymax = 0
ymin = !values.d_infinity
xmax = 0
xmin = !values.d_infinity
for k = 0, n-1 do begin
    cand = jet_utils_get_candidate(candlist, numbers[k])
    frames = jet_utils_get_candidate_frames(cand)
    ymax = max([ymax, max(frames.flux)]) * 1.05d 
    ymin = max([ymin, min(frames.flux)])
    xmin = min([xmin, frames[0].sec_from_start])
    xmax = max([xmax, frames[-1].sec_from_start])
endfor
if n_elements(start_from) ne 0 then xmin = start_from

thick = 2
ytitle = 'Flux, c.u.'
jd0 = asu_anytim2julday(frames[0].datetime) - frames[0].sec_from_start/24d/60d/60d
jdmin = jd0 + xmin/24d/60d/60d
jdmax = jd0 + xmax/24d/60d/60d
xjdrange = [jdmin, jdmax]
xtickinterval = 1d/24d/60d * ceil((xjdrange[1] - xjdrange[0])*24d*60d /10d)
yrange = [0, ymax]

col = asu_color_cycling(index)
p = list()
for k = 0, n-1 do begin
    cand = jet_utils_get_candidate(candlist, numbers[k])
    frames = jet_utils_get_candidate_frames(cand)
    name = 'detail ' + asu_compstr(numbers[k])
    if n_elements(sec) ne 0 then begin
        pp = plot(frames.sec_from_start, frames.flux, color = col, thick = thick, name = name, title = title $
                , xtitle = 'Time, s', ytitle = ytitle, xrange = [xmin, xmax], yrange = yrange, /current)
    endif else begin
        jdtimes = asu_anytim2julday(frames.datetime)
        pp = plot(jdtimes, frames.flux, color = col, thick = thick, name = name, title = title $
                , xtickformat='asu_julday_tick', xtickinterval = xtickinterval $
                , xtitle = 'Time, HH:MM', ytitle = ytitle, xrange = xjdrange, yrange = yrange, /current)
    endelse
    p.Add, pp          
    col = asu_color_cycling(index)
endfor

foo = legend(target = p.ToArray())

return, win

end
 