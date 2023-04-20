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

           move "127.0.0.1:8000" to host-address.
        
           call "define_http" 
           using by reference http-tbl, 
                 by content host-address.

           move "/" to host-path.
           set host-handle to entry "http-index".

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
       
       environment division.
       configuration section.

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
           05 parse-data occurs 256 times.
               10 parse-name     pic x(32).
               10 parse-value    pic x(256).
           05 parse-size pic 9(3).

       01 string-for-send.
           05 string-data pic x(1024).
           05 string-size pic 9(4).

       77 temp-string pic x(1024).
       77 i pic 9(3).

       linkage section.
       01 request.
          05 request-start.
             10 request-method pic x(16).
             10 request-path   pic x(2048).
             10 request-proto  pic x(16).
          05 request-headers occurs 256 times.
             10 request-header     pic x(2048).
          05 request-header-size  pic 9(3).
          05 request-body pic x(2048).
             
       77 connect pic 9(5).
       
       procedure division using request, connect.

           initialize parse-path.

           move spaces to string-data.

           call "parse-path"
           using by reference parse-path
           by content request-path.

           string
               '<a href="/?get1=test&get2=cobol">click</a><br/>'
               "GET DATA: <ul>" 
               into string-data
           end-string

           perform varying i from 1 by 1 until i is greater parse-size
               move string-data to temp-string
               string
                   function trim(temp-string)
                   "<li>"
                   function trim(parse-name(i))
                   ": "
                   function trim(parse-value(i))
                   "</li>"
                   into string-data
               end-string
           end-perform

           move string-data to temp-string
           set string-size to 1

           string
               function trim(temp-string)
               "</ul>" 
               into string-data
               with pointer string-size
           end-string
      
           call "sendtext_http"
           using by content response-data,
           by content connect,
           by content string-data,
           by content string-size.
                 
           exit program.
       
       end program http-index.
