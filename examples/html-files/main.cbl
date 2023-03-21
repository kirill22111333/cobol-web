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
                15 tab-path  pic x(2048).

       01 host-data.
          05 host-address pic x(50).
          05 host-path    pic x(2048).
          05 host-handle  usage procedure-pointer.

       77 handle-func-type pic x(16).
       
       procedure division.

           set host-address to "127.0.0.1:8000".
        
           call "define_http" 
           using by reference http-tbl, 
                 by content host-address.

           set host-path to "/".
           set host-handle to entry "http-index".

           call "handle_http"
           using by reference http-tbl,
                 by content host-path,
                 by content host-handle,
                 by content handle-func-type.

           set host-path to "/about".
           set host-handle to entry "http-about".

           call "handle_http"
           using by reference http-tbl,
                 by content host-path,
                 by content host-handle,
                 by content handle-func-type.

           call "listen_http" 
           using by reference http-tbl.

           goback.
       
       end program http.
       
      **********************
      * INDEX PAGE
      **********************

       identification division.
       program-id. http-index.
       
       environment division.
       configuration section.

       data division.
       working-storage section.
       77 file-name pic x(512).
       77 i pic 9(3).

       linkage section.
       01 request.
          05 request-start.
             10 request-method pic x(16).
             10 request-path   pic x(2048).
             10 request-proto  pic x(16).
          05 request-headers occurs 256 times.
             10 request-header       pic x(2048).
          05 request-header-size  pic 9(3).
             
       77 connect pic s9(5).
       
       procedure division using request, connect.
        
           display "index-page".

           display "METHOD: " function trim(request-method).
           display "PATH: " function trim(request-path).
           display "PROTO: " function trim(request-proto).

           display "HEADERS".
           display "HEADERS SIZE: " request-header-size.

           perform varying i from 1 by 1 
           until i is greater than request-header-size
             display i ". " function trim(request-header(i))
           end-perform.

           set file-name to "./layouts/index.html".

           call "sendhtml_http"
           using by content connect,
           by content file-name.
                 
           exit program.
       
       end program http-index.

      **********************
      * ABOUT PAGE
      **********************

       identification division.
       program-id. http-about.
       
       environment division.
       configuration section.

       data division.
       working-storage section.
       77 file-name pic x(512).
       77 i pic 9(3).

       linkage section.
       01 request.
          05 request-start.
             10 request-method pic x(16).
             10 request-path   pic x(2048).
             10 request-proto  pic x(16).
          05 request-headers occurs 256 times.
             10 request-header       pic x(2048).
          05 request-header-size  pic 9(3).
             
       77 connect pic s9(5).
       
       procedure division using request, connect.
        
           display "about-page".

           display "METHOD: " function trim(request-method).
           display "PATH: " function trim(request-path).
           display "PROTO: " function trim(request-proto).

           display "HEADERS".
           display "HEADERS SIZE: " request-header-size.

           perform varying i from 1 by 1 
           until i is greater than request-header-size
             display i ". " function trim(request-header(i))
           end-perform.

           set file-name to "./layouts/about.html".

           call "sendhtml_http"
           using by content connect,
           by content file-name.
                 
           exit program.
       
       end program http-about.
