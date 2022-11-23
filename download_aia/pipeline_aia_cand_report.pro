function pipeline_aia_cand_report, cand_list

s = ''

for i = 0, cand_list.Count()-1 do begin
    if i gt 0 then s += ', '
    elem = cand_list[i]
    s += strcompress(elem.wave, /remove_all) + '(' + strcompress(elem.ncand, /remove_all) + ')' 
endfor    

return, s

end
