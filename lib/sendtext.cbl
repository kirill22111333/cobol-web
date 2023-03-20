       identification division.
       program-id. sendtext_http.
       
       data division.
       
       linkage section.
       77 connect  pic 9(5).
       77 content-data pic x(1024).
       77 content-size pic 9(4).

       procedure division using connect, content-data, content-size.
        
      *    SEND HEADER

           call "sendheader_http"
           using by content connect.

      *    SEND CONTENT

           call "send_tcp" 
           using by value connect,
           by content content-data(1:content-size),
           by value content-size.

           exit program.
       
       end program sendtext_http.
