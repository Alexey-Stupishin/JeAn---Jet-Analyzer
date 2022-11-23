;----------------------------------------------------------------
pro l_pipeline_aia_irc_post_clear, par, curr_pos, snap, postponed

n = n_elements(postponed)

if n gt 0 then begin
    torem = intarr(n)
    nrem = 0
    for i = 0, n-1 do begin
        if postponed[i].pos eq curr_pos then begin
           critk = pipeline_aia_irc_same_cluster(postponed[i].cluster, snap, par, area)
           if critk ge 0 then begin
               print, '   ' + strcompress(postponed[i].pos,/remove_all) + ' removed, ID = ' + strcompress(postponed[i].ID,/remove_all) + ', ' + pipeline_aia_irc_clust_verbose(postponed[i].cluster)
               torem[nrem] = i
               nrem++ 
           endif 
        endif 
    endfor
    
    for i = nrem-1, 0, -1 do begin
        postponed.Remove, torem[i]
    endfor
endif

end

;----------------------------------------------------------------
pro pipeline_aia_irc_process_multi_m0, run_diff, postponed, par, parcom, jet

S_BACK = 1
S_FORWARD = 3

sz = size(run_diff)
n = sz[3]

curr = postponed[0].cluster
jet = list()
jet.Add, curr
seed = curr
curr_pos = postponed[0].pos
print, '   pos = ' + strcompress(postponed[0].pos,/remove_all) + ', ID = ' + strcompress(postponed[0].ID,/remove_all)+ ', ' + pipeline_aia_irc_clust_verbose(postponed[0].cluster) 
postponed.Remove, 0

seed_pos = curr_pos
from = seed_pos
to = seed_pos
state = S_BACK
gap = 0
while curr_pos lt n do begin
    case state of
        S_BACK: begin
            curr_pos--
            stopback = 1
            if curr_pos ge 0 then begin
                pipeline_aia_irc_process_m0, run_diff[*, *, curr_pos], par, clusters, curr_pos, seed
                if not clusters.IsEmpty() then begin
                    print, strcompress(fix(curr_pos),/remove_all) + ' back, ' + pipeline_aia_irc_clust_verbose(clusters[0])
                    l_pipeline_aia_irc_post_clear, par, curr_pos, clusters[0], postponed
                    jet.Add, clusters[0], 0
                    seed = clusters[0]
                    state = S_BACK
                    from = curr_pos
                    stopback = 0
                    gap = 0
                endif else begin
                    if gap lt parcom.gap then begin
                        stopback = 0
                        gap++
                    endif    
                endelse    
            endif
            if stopback then begin
                seed = curr
                curr_pos = seed_pos
                state = S_FORWARD
                gap = 0
            endif
        end
             
        S_FORWARD: begin
            curr_pos++
            stopforw = 1
            if curr_pos lt n then begin
                pipeline_aia_irc_process_m0, run_diff[*, *, curr_pos], par, clusters, curr_pos, seed
                if not clusters.IsEmpty() then begin
                    print, strcompress(fix(curr_pos),/remove_all) + ' forward, ' + pipeline_aia_irc_clust_verbose(clusters[0])
                    l_pipeline_aia_irc_post_clear, par, curr_pos, clusters[0], postponed
                    jet.Add, clusters[0]
                    seed = clusters[0]
                    to = curr_pos
                    stopforw = 0
                    gap = 0
                endif else begin
                    if gap lt parcom.gap then begin
                        stopforw = 0
                        gap++
                    endif    
                endelse                
            endif
            if stopforw then begin
                if to-from lt parcom.cadences then jet = list()
                print, strcompress(fix(curr_pos),/remove_all) + ' return, ' + (jet.IsEmpty() ? '' : 'not ') + 'empty list'
                return
            endif
        end 
    endcase
endwhile

end
