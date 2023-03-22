       identification division.
       program-id. get-func.
       
       environment division.
       configuration section.
       
       data division.
       linkage section.
       01 http-tbl.
           05 http-host pic x(50).
           05 http-len  pic 9(5).
           05 http-cap  pic 9(5).
           05 http-func occurs 256 times.
              10 func usage procedure-pointer.
           05 http-tab  occurs 256 times.
              10 tab-path   pic x(2048).
              10 tab-method pic x(16).

       77 request-path     pic x(2048).
       77 request-method   pic x(16).
       77 status-func      pic 9.
       77 idx-func         pic s9(5).
       
       procedure division using http-tbl, request-path, request-method, 
                           status-func, idx-func.
        
           set status-func to 0.

           perform varying idx-func from 1 
           until idx-func is greater than http-len
               if tab-path(idx-func) is equal request-path 
               and tab-method(idx-func) is equal request-method then
                   set status-func to 1
                   exit program
               end-if
           end-perform.

           exit program.
       
       end program get-func.
