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
              10 tab-path  pic x(2048).

       77 path          pic x(2048).
       77 func-handle   usage procedure-pointer.
      
       procedure division using http-tbl, path, func-handle.
        
           set tab-path(http-len) to path.
           set func(http-len) to func-handle.

           add 1 to http-len.

           exit program.
      
       end program handle_http.
       