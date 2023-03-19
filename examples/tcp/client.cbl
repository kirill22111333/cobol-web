       identification division.
       program-id. tcp-client.
       
       data division.
       working-storage section.
       01  server.
           05  connect         pic S9(3).
           05  buffer          pic X(512).
           05  buffer-size     pic 9(3) value 512.
           05  request-length  pic S9(3).
           05  input-value     pic X(512).
           
       77  server-address  pic X(21).

       77  exit-message    pic X(5) value "!exit".
       77  entry-message   pic X(7) value "connect".
      
       procedure division.
           
           start-client.
               perform connect-server.
               perform working-client.
               stop run.

           connect-server.
               set server-address to "127.0.0.1:8000".

               call "connect_tcp" using by content server-address
                   returning connect.

               if connect is less than 0 then
                   display "CONNECT ERROR: "connect
                   stop run
               end-if.

               exit paragraph.

           working-client.
               call "send_tcp" using by value connect,
                   by content entry-message,
                   by value buffer-size.

               call "request_tcp" using by value connect,
                   by reference buffer, by value buffer-size
                   returning request-length.

               display "SERVER MESSAGE: "buffer(1:request-length).

               perform send-data.

               call "close_tcp" using by value connect.

               exit paragraph.

           send-data.
               accept input-value from console.
               
               call "send_tcp" using by value connect,
                   by content function trim(input-value),
                   by value buffer-size.

               if input-value is equal exit-message 
               or input-value is equal spaces then
                   exit paragraph
               end-if.

               call "request_tcp" using by value connect,
                   by reference buffer, by value buffer-size
                   returning request-length.

               if buffer(1:request-length) is equal exit-message then
                   exit paragraph
               end-if.

               display "SERVER MESSAGE: "buffer(1:request-length).

               perform send-data.

               exit paragraph.
      
       end program tcp-client.
      