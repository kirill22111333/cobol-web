       identification division.
       program-id. sendfile_http.

       environment division.
       input-output section.
       file-control.
           select in-file assign to dynamic ws-fname
           organization is sequential.
       
       data division.

       file section.
       fd in-file record is varying 512 depending on ws-flen.
       01 file-data pic x(512).

       working-storage section.
      
       01 ws.
           05 ws-eof   pic x.
           05 ws-fname pic x(512).
           05 ws-flen  pic 9(3).
       
       linkage section.
       77 connect  pic 9(5).
       77 filename pic x(512).

       procedure division using connect, filename.

           move space to ws-eof.
           move filename to ws-fname.
        
           open input in-file.

           perform until ws-eof is equal 'Y'
               move spaces to file-data
               
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
       
       end program sendfile_http.
