function jet_utils_get_candidate, candlist, n

if n lt 0 || n ge candlist.Count() then return, !NULL

return, candlist[n]

end
