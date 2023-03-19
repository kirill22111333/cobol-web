       identification division.
       program-id. sendhtml_http.

       environment division.
       input-output section.
       file-control.
           select in-file assign to dynamic ws-fname
           organization is sequential.
       
       data division.

       file section.
       fd in-file record is varying depending ws-flen.
       01 file-data pic x(512).

       working-storage section.
       01 response-data.
           05 http-version pic x(10).
           05 http-header  pic x(50).
           05 status-code  pic 9(3).
           05 status-text  pic x(50).
       01 buffer.
           05 buffer-data pic x(512).
           05 buffer-size pic 9(3).
      
       01 ws.
           05 ws-eof   pic x.
           05 ws-fname pic x(512).
           05 ws-flen  pic 9(3).
       
       linkage section.
       77 connect  pic 9(5).
       77 filename pic x(512).

       procedure division using connect, filename.
        
      *    SEND HEADER

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

      *    SEND CONTENT

           set ws-eof to space.
           set ws-fname to filename.
        
           open input in-file.

           perform until ws-eof is equal 'Y'
               set file-data to spaces
               
               read in-file
               at end move 'Y' to ws-eof
               end-read

               if ws-eof is equal 'Y' then
                   exit perform
               end-if

               call "send_tcp" 
                   using by value connect,
                   by content file-data(1:ws-flen),
                   by value ws-flen
               end-call
           end-perform.

           close in-file.

           exit program.
       
       end program sendhtml_http.
