pro pipeline_aia_irc_preprocess_rd, run_diff
  sz = size(run_diff)
  rd = dblarr(sz[1], sz[2], sz[3])
  nt = sz[3]
  med_map = median(run_diff, dim = 3)
  deviation = run_diff
  for t=0, nt-1 do begin
    deviation[*,*,t] -= med_map
  endfor
  std_map = median(abs(deviation), dim =3)
  
  for t=0, nt-1 do begin
    run_diff[*,*,t] /= std_map
  endfor

end