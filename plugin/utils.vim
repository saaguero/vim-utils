function! ToWinSharedPathFun()
    try
        substitute/\//\\/g
    catch
        return
    endtry
    normal dt\
    normal 2wi.my.domain.org
    normal "+Y
    normal 0
endfunction

command! ToWinSharedPath call ToWinSharedPathFun()
