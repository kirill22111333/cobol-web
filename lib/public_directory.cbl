       identification division.
       program-id. public_directory.

       environment division.
       input-output section.
       file-control.
           select in-file assign to dynamic ws-fname
           file status is file-stat.
       
       data division.

       file section.
       fd in-file.
       01 file-data pic x(512).
              
       working-storage section.
       01 response-data.
           05 http-version pic x(10).
           05 status-code  pic 9(3).
           05 status-text  pic x(50).
           05 response-headers occurs 8 times.
               10 header-data pic x(256).
           05 response-headers-size pic 9(3).

       01 buffer.
           05 buffer-data pic x(2304).
           05 buffer-size pic 9(4).
       
       01 ws.
           05 ws-fname     pic x(512).
           05 file-stat    pic xx.

       linkage section.
       77 http-public  pic x(256).
       77 request-path pic x(2048).
       77 status-func  pic 9.
       77 connect      pic 9(5).
       
       procedure division using http-public, request-path, 
                           status-func, connect.
        
           move spaces to buffer-data.
           set buffer-size to 1.
           
           string
               function trim(http-public) delimited by size
               function trim(request-path) delimited by size
               into buffer-data
           end-string.
      
           move buffer-data to ws-fname.

           open input in-file.

           set status-func to 0.

           if file-stat is not equal "35" then
               set status-func to 1
           end-if.

           close in-file.

           if status-func is equal 0 then
               exit program
           end-if.

      *    SEND HEADER

           set status-code to 200.
           move "OK" to status-text.

           move "Server: COBOL WEB" to response-headers(1).
           set response-headers-size to 1.

           call "sendheader_http"
           using by content response-data,
           by content connect.

      *    SEND CONTENT

           call "sendfile_http"
           using by content connect,
           by content ws-fname.

           exit program.
       
       end program public_directory.
