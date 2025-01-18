" vim-pane-title.vim
" Updates tmux pane title based on current vim buffer state

if exists('g:loaded_vim_pane_title') || !exists('$TMUX')
    finish
endif
let g:loaded_vim_pane_title = 1

" Allow users to customize format
if !exists('g:vim_pane_title_format')
    let g:vim_pane_title_format = 'vim: %f%m %r'
endif

function! s:UpdatePaneTitle()
    " Don't update for certain buffer types
    if &filetype ==# 'nerdtree' 
        return
    endif
    
    if &filetype ==# 'tagbar'
        return
    endif

    " Get current buffer info
    let l:title = expand(g:vim_pane_title_format)
    
    " Replace placeholders
    let l:title = substitute(l:title, '%f', expand('%:t'), 'g')  " Filename
    let l:title = substitute(l:title, '%F', expand('%:p'), 'g')  " Full path
    let l:title = substitute(l:title, '%Y', &filetype, 'g')      " Filetype
    let l:title = substitute(l:title, '%m', &modified ? '[+]' : '', 'g')  " Modified flag
    let l:title = substitute(l:title, '%r', &readonly ? '[RO]' : '', 'g') " Read-only flag

    " Get git branch if available
    if exists('*FugitiveHead')
        let l:branch = FugitiveHead()
        if l:branch != ''
            let l:title .= ' (' . l:branch . ')'
        endif
    endif

    " If in a special window like help, show that instead
    if &buftype ==# 'help'
        let l:title = 'vim: help ' . expand('%:t:r')
    endif

    " If QuickFix window
    if &buftype ==# 'quickfix'
        let l:title = 'vim: quickfix'
    endif

    " Update tmux pane title
    call system('tmux select-pane -T ' . shellescape(l:title))
endfunction

" Set up autocommands for title updates
augroup VimPaneTitle
    autocmd!
    autocmd BufEnter,BufFilePost * call s:UpdatePaneTitle()
    autocmd FileType * call s:UpdatePaneTitle()
    autocmd BufWritePost * call s:UpdatePaneTitle()
augroup END

" Manual command to update title
command! UpdatePaneTitle call s:UpdatePaneTitle()
