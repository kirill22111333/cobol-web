       identification division.
       program-id. setCookie.
       
       data division.

       working-storage section.
       01 header.
           05 header-title pic x(32).
           05 header-value pic x(224).
       
       linkage section.
       01 response-data.
           05 http-version pic x(10).
           05 status-code  pic 9(3).
           05 status-text  pic x(50).
           05 response-headers occurs 8 times.
               10 header-data pic x(256).
           05 response-headers-size pic 9(3).
      
       01 cookie.
           05 cookie-name      pic x(32).
           05 cookie-value     pic x(160).
           05 cookie-expires   pic x(29).
           05 cookie-path      pic x(32).
           05 cookie-days      pic 9(4).

       procedure division using response-data, cookie.

           if cookie-name is equal spaces
               exit program
           end-if.

           if cookie-value is equal spaces
               exit program
           end-if.
        
           if cookie-expires is equal spaces
               call "date-utc"
               using by reference cookie-expires,
               by content cookie-days
               end-call
           end-if.

           if cookie-path is equal spaces
               set cookie-path to "/"
           end-if.

           if cookie-expires is equal "SESSION" then
               string
                   function trim(cookie-name)
                   X"3D"
                   function trim(cookie-value)
                   X"3B" X"20"
                   "path"
                   X"3D"
                   function trim(cookie-path)
                   into header-value
               end-string
           else
               string
                   function trim(cookie-name)
                   X"3D"
                   function trim(cookie-value)
                   X"3B" X"20"
                   "expires"
                   X"3D"
                   function trim(cookie-expires)
                   X"3B" X"20"
                   "path"
                   X"3D"
                   function trim(cookie-path)
                   into header-value
               end-string
           end-if.

           set header-title to "Set-Cookie".

           call "setheader"
           using by reference response-data,
           by content header-title,
           by content header-value.
           
           exit program.
       
       end program setCookie.

      *****************************************
       
       identification division.
       program-id. parseCookie.
       
       data division.

       working-storage section.
       77 header-cookies-size pic 9(4).
       77 j pic 9(4).
       77 k pic 9(4).
       77 ct pic 9.

       linkage section.
       01 parse-cookie.
           05 cookie-data occurs 16 times.
               10 cookie-name  pic x(32).
               10 cookie-value pic x(256).
           05 cookie-size pic 9(2).

       01 request.
           05 request-start.
               10 request-method pic x(16).
               10 request-path   pic x(2048).
               10 request-proto  pic x(16).
           05 request-headers occurs 256 times indexed by i.
               10 request-header     pic x(2048).
           05 request-header-size  pic 9(3).
       
       procedure division using parse-cookie, request.
           set cookie-size to 0.
        
           perform varying i from 1 by 1 
           until i is greater request-header-size
               if request-header(i)(1:6) is equal "Cookie" then
                   set cookie-size to 1
                   exit perform
               end-if
           end-perform.

           if cookie-size is not equal 1 then
               exit program
           end-if.

           set header-cookies-size to 
               function length(function trim(request-header(i))).
           set k to 1.
           set ct to 1.

           perform varying j from 9 by 1 
           until j is greater header-cookies-size
               if ct is equal 2 then
                   if request-header(i)(j:1) is equal ";" then
                       set ct to 1
                       set k to 0
                       add 1 to j
                       add 1 to cookie-size
                   else
                       set cookie-value(cookie-size)(k:1) to 
                           request-header(i)(j:1)
                   end-if
               end-if

               if ct is equal 1 then
                   if request-header(i)(j:1) is equal "=" then
                       set ct to 2
                       set k to 0
                   else
                       set cookie-name(cookie-size)(k:1) to 
                           request-header(i)(j:1)
                   end-if
               end-if

               add 1 to k
           end-perform.

           exit program.
       
       end program parseCookie.
