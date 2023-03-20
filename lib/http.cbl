       identification division.
       program-id. listen_http.
       
       data division.
       working-storage section.
       01 host.
           05 listener pic s9(5).
           05 connect  pic s9(5).
       01 buffer.
           05 buffer-param.
               10 buffer-data      pic x(2080).
               10 buffer-size      pic s9(4).
               10 param-size-val   pic 9(4).
       01 request.
           05 request-start.
               10 request-method   pic x(16).
               10 request-path     pic x(2048).
               10 request-proto    pic x(16).
           05 request-headers occurs 256 times.
               10 request-header       pic x(2048).
           05 request-headers-size  pic 9(3).
       77 i            pic 9.
       77 j            pic 9.
       77 k            pic 9.
       77 status-func  pic 9.
       77 idx-func     pic 9(5).
       77 start-str    pic 9(6).
       77 str-pointer  pic 9(6).
       77 max-size-str pic 9(6).

       linkage section.
       01 http-tbl.
           05 http-host pic x(50).
           05 http-len  pic 9(5).
           05 http-cap  pic 9(5).
           05 http-func occurs 256 times.
              10 func usage procedure-pointer.
           05 http-tab  occurs 256 times.
              10 tab-path pic x(2048).

       77 status-code pic 9.
       
       procedure division using http-tbl, status-code.
           set listener to 0.
           set connect to 0.

           set param-size-val to 2080.
        
           call "listen_tcp" 
           using by content http-host,
           returning listener.

           if listener is less than 0 then
               set status-code to 1
               exit program
           end-if.

           set i to 0.

           perform http-connect until i is equal 1.

           call "close_tcp"
           using by value listener.

           exit program.

           http-connect.
               call "accept_tcp"
               using by value listener,
               returning connect.

               if connect is less than 0 then
                   exit paragraph
               end-if.

               perform new-request.

               set j to 0.

               perform http-request until j is equal 1.

               perform switch-http.

               call "close_tcp"
               using by value connect.

               exit paragraph.

           http-request.
               set buffer-size to 0.
               set buffer-data to spaces.

               call "request_tcp"
               using by value connect,
               by reference buffer-data,
               by value param-size-val,
               returning buffer-size.

               if buffer-size is less than 0 then
                   set j to 1
                   exit paragraph
               end-if.

               perform parse-request.

               if buffer-size not equal param-size-val then
                   set j to 1
                   exit paragraph
               end-if.

               exit paragraph.

           parse-request.
               set max-size-str to function length(buffer).
               set start-str to 1.
               set k to 1.

               perform varying str-pointer from 1 by 1 
               until str-pointer is greater than max-size-str

               if buffer(str-pointer:1) is equal space 
               or buffer(str-pointer:1) is equal X"0A" then
                   evaluate k
                       when 1
                           set request-method 
                           to buffer(start-str:str-pointer - start-str)
                       when 2
                           set request-path 
                           to buffer(start-str:str-pointer - start-str)
                       when 3
                           set request-proto 
                           to buffer(start-str:str-pointer - start-str)
                   end-evaluate
                   compute start-str = str-pointer + 1
                   add 1 to k

                   if k is equal 4 then
                       exit perform
                   end-if
               end-if

               end-perform. 

               set request-headers-size to 0.

               perform varying str-pointer from start-str by 1 
               until str-pointer is greater than max-size-str 
                   if buffer(str-pointer:1) is equal X"0A" or 
                   str-pointer is equal max-size-str then
                       add 1 to request-headers-size
                       set request-headers(request-headers-size) 
                       to buffer(start-str:str-pointer - start-str)
                       compute start-str = str-pointer + 1
                   end-if
               end-perform.

               set request-headers(request-headers-size) to spaces.
               set request-headers(request-headers-size - 1) to spaces.

               subtract 2 from request-headers-size.

               exit paragraph.

           new-request.
               set request-method to spaces.
               set request-path to spaces.
               set request-proto to spaces.

               exit paragraph.
           
           switch-http.
               perform get-func

               if status-func is equal 0 then
                   perform page404-http
                   exit paragraph
               end-if.

               call func(idx-func)
               using by content request
               by content connect.

               exit paragraph.

           page404-http.
               set buffer-data to spaces.
               set buffer-size to 1.

               string
                   "HTTP/1.1" X"20" "404" X"20" "Not Found" X"0A" X"0A"
                   into buffer-data
                   with pointer buffer-size
               end-string.

               call "send_tcp" 
               using by value connect,
               by content function trim(buffer-data),
               by value buffer-size.

               exit paragraph.

           get-func.
               set status-func to 0.

               perform varying idx-func from 1 
               until idx-func is greater than http-len
                   if tab-path(idx-func) is equal request-path then
                       set status-func to 1
                       exit paragraph
                   end-if
               end-perform.

               exit paragraph.
       
       end program listen_http.