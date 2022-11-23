pro pipeline_aia_get_query, wave, tstart, tstop, urls, filenames

ds = ssw_jsoc_wave2ds(wave)
time_query =  ssw_jsoc_time2query(tstart, tstop)
query = ds+'['+time_query+']'+'['+strcompress(wave, /remove_all)+']'
query = query[0]
urls = ssw_jsoc_query2sums(query,/urls)
index = ssw_jsoc(ds = query,/rs_list,/xquery)
filenames = ssw_jsoc_index2filenames(index)

end
