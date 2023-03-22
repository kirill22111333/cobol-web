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
      
       01 ws.
           05 ws-eof   pic x.
           05 ws-fname pic x(512).
           05 ws-flen  pic 9(3).
       
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
