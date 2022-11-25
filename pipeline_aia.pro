;
; Main entry for JeAn - Jet Analyzer
;   
; v 3.1.22.1125 (rev.662)
; 
; Call (see parameters and comments below):
; rc = pipeline_aia(config_file, work_dir $
;                 , no_visual = no_visual, no_cand = no_cand, no_details = no_details $
;                 , fps = fps $
;                 , presets_file = presets_file, ref_images = ref_images $
;                  ) 
; 
; Parameters description:
; 
; Parameters required:
;   (in)      config_file    (string)       path to configuration file (see Tutorial)
;   (in)      work_dir       (string)       path to the directory for output files (see Tutorial)
;   
; Parameters optional (in):
;   (in)      no_visual      (integer)      flag to ignore creating joint images of intensity and 
;                                             running difference and the creation of video files (default not set)     
;   (in)      no_cand        (integer)      flag to ignore searching jet-like candidates (default not set)
;                                             (use both keys /no_visual,/no_cand to fits downloading only) 
;   (in)      no_details     (integer)      flag to ignore creating individual details movies (default not set)
;   (in)      fps            (integer)      frames per second for movies (default = 5)
;   (in)      presets_file   (string)       path to presets file (see Tutorial)
;   (in)      ref_images     (integer)      flag to save images for full disk for the beginning, middle and end of event.
;   
; Return value:
;   IDL list. Each list item is the structure with fields:
;       wave: wavelength
;       ncand: number of details
;
; As the result of call directory structure with downloaded fits, calculated jets info, pictures and movies
; will be created. See Tutorial for details. 
;
; Tutorial can be found in the root of the package.
;    
; (c) Alexey G. Stupishin, Saint Petersburg State University, Saint Petersburg, Russia, 2020-2022
;     mailto:agstup@yandex.ru
;
;--------------------------------------------------------------------------;
;     \|/     Set the Controls for the Heart of the Sun           \|/      ;
;    --O--        Pink Floyd, "A Saucerful Of Secrets", 1968     --O--     ;
;     /|\                                                         /|\      ;  
;--------------------------------------------------------------------------;

function pipeline_aia, config_file, work_dir $
                    , no_visual = no_visual, no_cand = no_cand, no_details = no_details $
                    , fps = fps $
                    , presets_file = presets_file, ref_images = ref_images

return, pipeline_aia_all(config_file, work_dir $
                       , no_visual = no_visual, no_cand = no_cand, no_details = no_details $
                       , fps = fps $
                       , presets_file = presets_file, ref_images = ref_images $
                        )

end
