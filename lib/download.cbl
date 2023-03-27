       identification division.
       program-id. download.

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

       77 i pic 9(4).
       77 j pic 9(4).
       77 k pic 9(4).
       77 file-size pic 9(4).

       linkage section.
       01 file-info.
           05 file-path    pic x(2048).
           05 file-name    pic x(512).
       77 connect      pic 9(5).
       77 status-func  pic 9.

       procedure division using file-info, connect, status-func.

           set status-func to 0.

           if file-path is equal spaces then
               exit program
           end-if.
      
           set ws-fname to file-path.

           open input in-file.

           if file-stat is not equal "35" then
               set status-func to 1
           end-if.

           close in-file.

           if status-func is equal 0 then
               exit program
           end-if.
        
      *    SEND HEADER

           set status-code to 200.
           set status-text to "OK".

           if file-name is equal spaces then
               set file-size 
                   to function length(function trim(file-path))

               set j to 1
               set k to 1

               perform varying i from 1 by 1
               until i is greater file-size
                   add 1 to j
                   if file-path(i:1) is equal "/" then
                       set j to 1
                       compute k = i + 1
                   end-if
               end-perform

               set file-name to file-path(k:j)
           end-if. 

           set response-headers(1) to spaces.

           string 
               "Content-Disposition: attachment; filename="
               function trim(file-name)
               into response-headers(1)
           end-string.

           set response-headers-size to 1.

           call "sendheader_http"
           using by content response-data,
           by content connect.

      *    SEND CONTENT

           call "sendfile_http"
           using by content connect,
           by content ws-fname.

           exit program.
       
       end program download.
