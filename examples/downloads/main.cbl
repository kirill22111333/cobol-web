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
             10 http-public pic x(256).

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

           set host-path to "/".
           set host-handle to entry "http-index".

           call "handle_http"
           using by reference http-tbl,
                 by content host-path,
                 by content path-method,
                 by content host-handle,
                 by content handle-func-type.

           set host-path to "/download".
           set host-handle to entry "http-download".

           call "handle_http"
           using by reference http-tbl,
                 by content host-path,
                 by content path-method,
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
             10 request-header       pic x(2048).
          05 request-header-size  pic 9(3).
             
       77 connect pic s9(5).
       
       procedure division using request, connect.

           set file-name to "./layouts/index.html".

           call "sendhtml_http"
           using by content response-data,
           by content connect,
           by content file-name.
                 
           exit program.
       
       end program http-index.

      **********************
      * DOWNLOAD PAGE
      **********************

       identification division.
       program-id. http-download.

       data division.
       working-storage section.
       01 response-data.
           05 http-version pic x(10).
           05 status-code  pic 9(3).
           05 status-text  pic x(50).
           05 response-headers occurs 8 times.
               10 header-data pic x(256).
           05 response-headers-size pic 9(3).
       
       01 parse-path.
           05 parse-get occurs 256 times.
               10 get-name     pic x(32).
               10 get-value    pic x(256).
           05 parse-get-size pic 9(3).

       01 string-for-send.
           05 string-data pic x(1024).
           05 string-size pic 9(4).

       01 file-info.
           05 file-path    pic x(2048).
           05 file-name    pic x(512).

       77 status-func pic 9.

       linkage section.
       01 request.
          05 request-start.
             10 request-method pic x(16).
             10 request-path   pic x(2048).
             10 request-proto  pic x(16).
          05 request-headers occurs 256 times indexed by i.
             10 request-header       pic x(2048).
          05 request-header-size  pic 9(3).
             
       77 connect pic s9(5).
       
       procedure division using request, connect.

           initialize response-data, parse-path.

           call "parse-path"
           using by reference parse-path
           by content request-path.

           set file-path to spaces.

           perform varying i from 1 by 1 
           until i is greater parse-get-size
               display "GET #" i
               display "GET-NAME: " function trim(get-name(i))
               display "GET-VALUE: " function trim(get-value(i))
               display "********************"

               if get-name(i) is equal "filename" then
                   string
                       "./files/"
                       function trim(get-value(i))
                       into file-path
                   end-string
               end-if
           end-perform.

           call "download"
           using by content file-info,
           by content connect,
           by reference status-func.

           if status-func is equal 1 then
               exit program
           end-if.

           set status-code to 404.
           set status-text to "Not Found".

           set string-data to "File not found".
           set string-size to 
               function length(function trim(string-data)).

           call "sendtext_http"
           using by content response-data,
           by content connect,
           by content string-data,
           by content string-size.

           exit program.
       
       end program http-download.
