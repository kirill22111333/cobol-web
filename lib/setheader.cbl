       identification division.
       program-id. setheader.
       
       data division.

       working-storage section.
       01 buffer.
           05 buffer-data pic x(256).

       linkage section.
       01 response-data.
           05 http-version pic x(10).
           05 status-code  pic 9(3).
           05 status-text  pic x(50).
           05 response-headers occurs 8 times.
               10 header-data pic x(256).
           05 response-headers-size pic 9(3).
       
       77 header-title     pic x(32).
       77 header-set-data  pic x(224).
       
       procedure division using response-data, header-title, 
                           header-set-data.

           string
               function trim(header-title)
               X"3A" X"20"
               function trim(header-set-data)
               into buffer-data
           end-string.
        
           add 1 to response-headers-size.

           set response-headers(response-headers-size) to buffer-data.
        
           exit program.
       
       end program setheader.
