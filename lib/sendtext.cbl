       identification division.
       program-id. sendtext_http.
       
       data division.
       
       linkage section.
       01 response-data.
           05 http-version pic x(10).
           05 status-code  pic 9(3).
           05 status-text  pic x(50).
           05 response-headers occurs 8 times.
               10 header-data pic x(256).
           05 response-headers-size pic 9(3).
       
       77 connect  pic 9(5).
       77 content-data pic x(1024).
       77 content-size pic 9(4).

       procedure division using response-data, connect, 
                           content-data, content-size.
        
      *    SEND HEADER

           call "sendheader_http"
           using by content response-data,
           by content connect.

      *    SEND CONTENT

           call "send_tcp" 
           using by value connect,
           by content content-data(1:content-size),
           by value content-size.

           exit program.
       
       end program sendtext_http.
