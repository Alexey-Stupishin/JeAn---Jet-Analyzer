pro pipeline_aia_irc_morph_filter,cmask, min_size, fill_size, border
  
  ;removing small objects
  radius = min_size
  sz = radius*2+1
  pattern = shift(dist(sz),radius,radius) le radius
  cmask = morph_open(cmask, pattern)
  
  ;filling large gaps
  radius = fill_size
  sz = radius*2+1
  pattern = shift(dist(sz),radius,radius) le radius
  cmask = morph_close(cmask, pattern)
  
  ;extend border
  radius = border
  sz = radius*2+1
  pattern = shift(dist(sz),radius,radius) le radius
  cmask = dilate(cmask, pattern)
end