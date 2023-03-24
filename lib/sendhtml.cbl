       identification division.
       program-id. sendhtml_http.
       
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
       77 filename pic x(512).

       procedure division using response-data, connect, filename.
        
      *    SEND HEADER

           call "sendheader_http"
           using by content response-data,
           by content connect.

      *    SEND CONTENT

           call "sendfile_http"
           using by content connect,
           by content filename.

           exit program.
       
       end program sendhtml_http.
