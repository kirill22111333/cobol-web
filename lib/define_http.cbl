       identification division.
       program-id. define_http.
      
       data division.
       linkage section.
       01 http-tbl.
          05 http-host pic x(50).
          05 http-len  pic 9(5).
          05 http-cap  pic 9(5).
       
       77 http-address pic x(50).
      
       procedure division using http-tbl, http-address.

           move http-address to http-host.
           set http-len to 1.
           set http-cap to 1000.
           
           exit program.
      
       end program define_http.
