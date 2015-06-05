" source vimscript operator
function! SourceVimscript(type)
    let sel_save = &selection
    let &selection = "inclusive"
    let reg_save = @"

    if a:type == 'line'
        silent execute "normal! '[V']y"
    elseif a:type == 'char'
        silent execute "normal! `[v`]y"
    elseif a:type == "visual"
        silent execute "normal! gvy"
    elseif a:type == "currentline"
        silent execute "normal! yy"
    endif

    " source the content
    @"

    let &selection = sel_save
    let @" = reg_save
endfunction

nnoremap <silent> gs :set opfunc=SourceVimscript<CR>g@
vnoremap <silent> gs :<C-U>call SourceVimscript("visual")<CR>
nnoremap <silent> gss :call SourceVimscript("currentline")<CR>


" split lines on whitespace
" repeatable (requires vim-repeat)
function! SplitOnSpace()
  execute "normal f\<space>i\r\e"
  silent! call repeat#set("\<Plug>CustomSplitOnSpace")
endfunction

nnoremap <silent> <Plug>CustomSplitOnSpace :call SplitOnSpace()<cr>
nnoremap <silent> <leader>s :call SplitOnSpace()<cr>


function! GetVisualSelection()
  let old_reg = @v
  normal! gv"vy
  let raw_search = @v
  let @v = old_reg
  return substitute(escape(raw_search, '\/.*$^~[]'), "\n", '\\n', "g")
endfunction

" Easy search/replace (from romainl/dotvim)
nnoremap <Space><Space> :%s/\<<C-r>=expand('<cword>')<CR>\>/
vnoremap <Space><Space> :<C-u>%s/<C-r>=GetVisualSelection()<CR>/

