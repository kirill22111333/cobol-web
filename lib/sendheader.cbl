       identification division.
       program-id. sendheader_http.
       
       data division.

       working-storage section.
       01 response-data.
           05 http-version pic x(10).
           05 http-header  pic x(50).
           05 status-code  pic 9(3).
           05 status-text  pic x(50).
       01 buffer.
           05 buffer-data pic x(512).
           05 buffer-size pic 9(3).
       
       linkage section.
       77 connect  pic 9(5).

       procedure division using connect.
        
           set http-version to "HTTP/1.1".
           set status-code to 200.
           set status-text to "OK".

           set http-header to "Content-type: text/html"

           set buffer-data to spaces.
           set buffer-size to 1.
           
           string 
               function trim(http-version) delimited by size
               X"20"
               function trim(status-code) delimited by size
               X"20"
               function trim(status-text) delimited by size
               X"0A"
               function trim(http-header) delimited by size
               X"0A"
               X"0A"
               into buffer-data
               with pointer buffer-size
           end-string.

           subtract 1 from buffer-size.

           call "send_tcp" 
           using by value connect,
           by content function trim(buffer-data),
           by value buffer-size.

           exit program.
       
       end program sendheader_http.
