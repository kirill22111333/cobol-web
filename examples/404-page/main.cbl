       identification division.
       program-id. http.
       
       data division.
       working-storage section.
       01 http-data.
          05 http-tbl.
             10 http-host pic x(50).
             10 http-len  pic 9(5).
             10 http-cap  pic 9(5).
             10 http-func occurs 256 times.
                15 func usage procedure-pointer.
             10 http-tab  occurs 256 times.
                15 tab-path   pic x(2048).
                15 tab-method pic x(16).

       01 host-data.
          05 host-address pic x(50).
          05 host-path    pic x(2048).
          05 host-handle  usage procedure-pointer.

       77 handle-func-type pic x(16).
       77 path-method      pic x(16).
       
       procedure division.

           set host-address to "127.0.0.1:8000".
        
           call "define_http" 
           using by reference http-tbl, 
                 by content host-address.

           set handle-func-type to "404".
           set host-handle to entry "http-404".

           call "handle_http"
           using by reference http-tbl,
                 by content host-path,
                 by content path-method,
                 by content host-handle,
                 by content handle-func-type.

           set handle-func-type to spaces.

           call "listen_http" 
           using by reference http-tbl.

           goback.
       
       end program http.
      
      **********************
      * 404 PAGE
      **********************
       
       identification division.
       program-id. http-404.
       
       data division.
       working-storage section.
       01 response-data.
           05 http-version pic x(10).
           05 status-code  pic 9(3).
           05 status-text  pic x(50).
           05 response-headers occurs 8 times.
               10 header-data pic x(256).
           05 response-headers-size pic 9(3).

       77 file-name pic x(512).

       linkage section.
       01 request.
          05 request-start.
             10 request-method pic x(16).
             10 request-path   pic x(2048).
             10 request-proto  pic x(16).
          05 request-headers occurs 256 times.
             10 request-header    pic x(2048).
          05 request-header-size  pic 9(3).
             
       77 connect pic s9(5).
       
       procedure division using request, connect.

           display "404-page".
        
           set file-name to "./layouts/404.html".

           set status-code to 404.
           set status-text to "Not Found".

           call "sendhtml_http"
           using by content response-data,
           by content connect,
           by content file-name.

           exit program.
       
       end program http-404.
       