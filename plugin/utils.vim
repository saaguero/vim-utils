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
  let current_char = getline('.')[col('.') - 1]
  if current_char == ' '
    execute "normal i\r\e"
  else
    execute "normal f\<space>i\r\e"
  endif
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

" Search current word with Ag
nnoremap <leader>m :Ag <C-r>=expand('<cword>')<cr><cr>

" makes * and # work on visual mode. Taken from nelstrom/vim-visual-star-search
function! s:VSetSearch(cmdtype)
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
  let @s = temp
endfunction

xnoremap * :<C-u>call <SID>VSetSearch('/')<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch('?')<CR>?<C-R>=@/<CR><CR>

function! FindTagFile(tag_file_name)
    " From our current directory, search up for tagfile
    let l:tag_file = findfile(a:tag_file_name, '.;/') " must be somewhere above us
    let l:tag_file = fnamemodify(l:tag_file, ':p')      " get the full path
    if filereadable(l:tag_file)
        return l:tag_file
    else
        return ''
    endif
endfunction

" Automatically include cscope db if available. Taken from idbrii/daveconfig
" Works either with cscope or gtags-cscope
if has("cscope")
    function! LocateCscopeFile()
        let l:tagfile = FindTagFile('cscope.out')
        let l:gtagfile = FindTagFile('GTAGS')
        let l:tagpath = fnamemodify(l:tagfile, ':h')
        let l:gtagpath = fnamemodify(l:gtagfile, ':h')
        if filereadable(l:tagfile)
            let g:cscope_database = l:tagfile
            let g:cscope_relative_path = l:tagpath
            " Set the cscope file relative to where it was found
            execute 'cscope add ' . l:tagfile . ' ' . l:tagpath
            set cscopetag
        elseif filereadable(l:gtagfile)
            set csprg=gtags-cscope
            set cscopetag
            execute 'cscope add ' . l:gtagfile . ' ' . l:gtagpath
        endif
    endfunction
endif

call LocateCscopeFile()


" TOhtml super charge with clipboard support (inspired from https://github.com/google/vim-syncopate)
function! CopyHtmlFun(a1, a2)
  let l:old_html_use_css = g:html_use_css
  let g:html_use_css = 0

  if a:a1 == a:a2
    execute '1,$ TOhtml'
  else
    execute a:a1 . ',' . a:a2 . 'TOhtml'
  endif

  let l:contents = join(getline(1, '$'), "\n")
  call system('xclip -t text/html -selection clipboard', l:contents)
  bwipeout!
  let g:html_use_css= l:old_html_use_css

  echo "Successfully copied html to clipboard"
endfunction

command! -range CopyHtml call CopyHtmlFun(<line1>, <line2>)
