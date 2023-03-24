       identification division.
       program-id. sendheader_http.
       
       data division.

       working-storage section.
       01 buffer.
           05 buffer-data pic x(2050).
           05 buffer-size pic 9(4).
           05 tmp-buffer  pic x(2050).

       77 is-send-content-type pic 9.
       77 is-end               pic 9.
       
       linkage section.
       01 response-data.
           05 http-version pic x(10).
           05 status-code  pic 9(3).
           05 status-text  pic x(50).
           05 response-headers occurs 8 times indexed by i.
               10 header-data pic x(256).
           05 response-headers-size pic 9(3).
           
       77 connect  pic 9(5).

       procedure division using response-data, connect.

      *    STATUS LINE

           if http-version is equal spaces then
               set http-version to "HTTP/1.1"
           end-if.

           if status-code is equal 0 then
               set status-code to 200
           end-if.
        
           if status-text is equal spaces then
               set status-text to "OK"
           end-if.
           
           set is-send-content-type to 0.
           set is-end to 0.

           set buffer-data to spaces.
           set buffer-size to 1.
           
           string 
               function trim(http-version) delimited by size
               X"20"
               function trim(status-code) delimited by size
               X"20"
               function trim(status-text) delimited by size
               X"0A"
               into buffer-data
               with pointer buffer-size
           end-string.

           subtract 1 from buffer-size.

           call "send_tcp" 
           using by value connect,
           by content function trim(buffer-data),
           by value buffer-size.

      *    SEND HEADERS

           set buffer-data to spaces.
           set buffer-size to 1.

           if response-headers-size is equal 0 then
               set response-headers(1) to "Content-type: text/html"
           end-if.

           string 
               function trim(response-headers(1)) delimited by size
               into buffer-data
           end-string.

           perform varying i from 2 by 1 
           until i is greater than response-headers-size

               set tmp-buffer to buffer-data
               set buffer-data to spaces
               
               string 
                   function trim(tmp-buffer) delimited by size
                   X"0A"
                   function trim(header-data(i)) delimited by size
                   into buffer-data
               end-string
      
           end-perform.

           set tmp-buffer to buffer-data.
           set buffer-data to spaces.
           set buffer-size to 1.

           string 
               function trim(tmp-buffer) delimited by size
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
