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

    let @" = substitute(@", '\n\s*\\', '', 'g')

    " source the content
    @"

    let &selection = sel_save
    let @" = reg_save
endfunction

nnoremap <silent> <leader>s :set opfunc=SourceVimscript<CR>g@
vnoremap <silent> <leader>s :<C-U>call SourceVimscript("visual")<CR>
nnoremap <silent> <leader>ss :call SourceVimscript("currentline")<CR>

" split lines on whitespace
" repeatable (requires vim-repeat)
function! SplitOnSpace()
  execute "normal f\<space>i\r\e"
  silent! call repeat#set("\<Plug>CustomSplitOnSpace")
endfunction

nnoremap <silent> <Plug>CustomSplitOnSpace :call SplitOnSpace()<cr>
nnoremap <silent> <leader>j :call SplitOnSpace()<cr>

function! GetVisualSelection()
  let old_reg = @v
  normal! gv"vy
  let raw_search = @v
  let @v = old_reg
  return substitute(escape(raw_search, '\/.*$^~[]'), "\n", '\\n', "g")
endfunction

" Easy search/replace (from romainl/dotvim)
nnoremap <space><space> :%s/\<<C-r>=expand('<cword>')<CR>\>/
vnoremap <space><space> :<C-u>%s/<C-r>=GetVisualSelection()<CR>/

" Easy multiple cursors
nnoremap <space>n :MultipleCursorsFind \<<C-r>=expand('<cword>')<CR>\><cr>
vnoremap <space>n :<C-u>MultipleCursorsFind <C-r>=GetVisualSelection()<CR><cr>

function! FormatJsonFun(a1, a2)
  if a:a1 == a:a2
    .!python -m json.tool
  else
    execute a:a1 . "," . a:a2 . "!python -m json.tool"
  endif
  normal! gg=G
endfunction

command! -range FormatJson call FormatJsonFun(<line1>, <line2>)

function! RunCommand()
    let s:sel = GetVisualSelection()
    let s:result = system(s:sel)
    if !v:shell_error
        set paste
        execute "normal gvc" . s:result
        set nopaste
    else
        echom 'Error executing command: ' . s:sel
    endif
endfunction

" Run bash command
nnoremap <leader>! !!bash<cr>
vnoremap <leader>! :<c-u>call RunCommand()<cr>

" makes * and # work on visual mode. Taken from nelstrom/vim-visual-star-search
function! s:VSetSearch(cmdtype)
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
  let @s = temp
endfunction

xnoremap * :<C-u>call <SID>VSetSearch('/')<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch('?')<CR>?<C-R>=@/<CR><CR>
