       identification division.
       program-id. handle_http.
      
       data division.
       linkage section.
       01 http-tbl.
           05 http-host pic x(50).
           05 http-len  pic 9(5).
           05 http-cap  pic 9(5).
           05 http-func occurs 256 times.
              10 func usage procedure-pointer.
           05 http-tab  occurs 256 times.
              10 tab-path   pic x(2048).
              10 tab-method pic x(16).

       77 path         pic x(2048).
       77 path-method  pic x(16). 
       77 func-handle  usage procedure-pointer.
       77 func-type    pic x(16).
      
       procedure division using http-tbl, path, path-method, 
                           func-handle, func-type.

           evaluate func-type
               when "404"
                   move "##404" to tab-path(http-len)
                   move spaces to tab-method(http-len)
               when other
                   if path-method is equal spaces then
                       move "GET" to path-method
                   end-if

                   move path to tab-path(http-len)
                   move path-method to tab-method(http-len)
           end-evaluate
        
           set func(http-len) to func-handle.

           add 1 to http-len.

           exit program.
      
       end program handle_http.
