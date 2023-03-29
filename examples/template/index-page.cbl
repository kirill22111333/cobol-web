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

       01 string-for-send.
           05 string-data pic x(1024).
           05 string-size pic 9(4).

       linkage section.
       01 request.
          05 request-start.
             10 request-method pic x(16).
             10 request-path   pic x(2048).
             10 request-proto  pic x(16).
          05 request-headers occurs 256 times.
             10 request-header       pic x(2048).
          05 request-header-size  pic 9(3).
             
       77 connect pic 9(5).
       
       procedure division using request, connect.

           set string-data to spaces.
           set string-size to 1.

           string
               "COBOL"
               into string-data
               with pointer string-size
           end-string.
      
           call "sendtext_http"
           using by content response-data,
           by content connect,
           by content string-data,
           by content string-size.
                 
           exit program.
       
       end program http-index.
