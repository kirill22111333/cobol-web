       identification division.
       program-id. tcp-client.
       
       data division.
       working-storage section.
       01  server.
           05  connect         pic S9(3).
           05  buffer          pic X(512).
           05  buffer-size     pic s9(3).
           05  buffer-size-st  pic 9(3).
           05  request-length  pic S9(3).
           05  input-value     pic X(512).
           
       77  server-address  pic X(21).

       77  exit-message    pic X(5) value "!exit".
       77  entry-message   pic X(7) value "connect".
      
       procedure division.
           
           start-client.
               set buffer-size-st to 512.

               perform connect-server.
               perform working-client.
               stop run.

           connect-server.
               move "127.0.0.1:8000" to server-address.

               call "connect_tcp" using by content server-address
                   returning connect.

               if connect is less than 0 then
                   display "CONNECT ERROR: "connect
                   stop run
               end-if.

               exit paragraph.

           working-client.
               move spaces to buffer.
               set buffer-size to 1.

               string
                   function trim(entry-message)
                   into buffer
                   with pointer buffer-size
               end-string.

               call "send_tcp" using by value connect,
                   by content function trim(buffer),
                   by value buffer-size.

               move spaces to buffer.

               call "request_tcp" using by value connect,
                   by reference buffer, by value buffer-size-st
                   returning request-length.

               display "SERVER MESSAGE: "buffer(1:request-length).

               perform send-data.

               call "close_tcp" using by value connect.

               exit paragraph.

           send-data.
               accept input-value from console.

               move spaces to buffer.
               set buffer-size to 1.
               
               string
                   function trim(input-value)
                   into buffer
                   with pointer buffer-size
               end-string.
               
               call "send_tcp" using by value connect,
                   by content function trim(buffer),
                   by value buffer-size.

               if input-value is equal exit-message 
               or input-value is equal spaces then
                   exit paragraph
               end-if.

               move spaces to buffer.

               call "request_tcp" using by value connect,
                   by reference buffer, by value buffer-size-st
                   returning request-length.

               if buffer(1:request-length) is equal exit-message then
                   exit paragraph
               end-if.

               display "SERVER MESSAGE: "buffer(1:request-length).

               perform send-data.

               exit paragraph.
      
       end program tcp-client.
