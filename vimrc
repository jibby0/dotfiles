" start plugins
execute pathogen#infect()

" set black color scheme
colorscheme torte
" enable syntax processing
syntax enable

" number of visual spaces per TAB
set tabstop=4

" number of spaces in tab when editing
set softtabstop=4

" number of space when using > or <
set shiftwidth=4	

" tabs are spaces
set expandtab		

" show line numbers
set number		

" show command in bottom bar
set showcmd		

" don't highlight current line
set nocursorline		

" load filetype-specific indent files
filetype indent on	

" visual autocomplete for command menu
set wildmenu		

" redraw only when necessary (faster macros)
set lazyredraw		

" highlight matching brackets
set showmatch		

" search as characters are entered
set incsearch   

" fold based on indent
set foldmethod=indent   

" foldlevel when window is loaded
set foldlevelstart=1   

" space is Leader
map <space> <leader>

" fold based on indent level
set foldmethod=indent	

" set shell to zsh (if it exists)
if !(has("win32") || has("win16") || has("win32unix"))
    if filereadable("/bin/zsh")
        silent! set shell=/bin/zsh  
    endif
endif

" function to check for running instances of vim on Linux
function! UnixCapsControl()
    silent! let running = system('echo $(pgrep -c vim)')
    if(running <= 1)
        silent! !xmodmap -e 'clear Lock' -e 'keycode 0x42 = Caps_Lock'
    endif
endfunction

" map caps lock to escape under Linux
if !(has("win32") || has("win16") || has("win32unix"))
    au VimEnter * silent! !xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'
    au VimLeave * :call UnixCapsControl() 
endif

" function to check for running instances of vim on Windows
function! WindowsCapsControl()
    silent! let running = system('tasklist /FI "IMAGENAME eq vim.exe" 2>NUL | find /I /C "vim.exe"')
    if(running <= 1)
        silent! !start taskkill /IM CapsEsc.exe
    endif
endfunction

" map caps lock to escape under Windows
if (has("win32") || has("win16"))
    au VimEnter * silent! !start C:\Users\Josh\vimfiles\CapsEsc.exe
    au VimLeave * :call WindowsCapsControl()
endif
"
" function to check for running instances of vim on Cygwin
function! CygwinCapsControl()
    silent! let running = system('echo $(pgrep -c vim)')
    if(running <= 1)
        silent! !pkill CapsEsc
    endif
endfunction

" map caps lock to excape under Cygwin
if (has("win32unix"))
    au VimEnter * silent! !/home/josh/.vim/CapsEsc.exe &
    au VimLeave * :call CygwinCapsControl()
endif

" swap files are rotated every 10 keystrokes
set updatecount=10  

" backspace is used to remove previous characters, indents, and newlines
set backspace=indent,eol,start	

" <Leader>l formats a line
noremap <Leader>l Vgq   

" make an undo file to allow undoing after closing a file
set undofile
set undodir=~/.vim/undodir

" set Makefiles with tabs not spaces
autocmd FileType make setlocal noexpandtab

" compare current buffer to saved file
function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()

" map the comp buff function above
noremap <Leader>d :DiffSaved<CR>

" function to write a file and immediately run make
function! s:writeAndMake()
    :w
    :make
endfunction
com! WriteMake call s:writeAndMake()

" map the write and make function
noremap <Leader>c :WriteMake<CR>

" write w/ privileges when Vim isn't started as root
cmap w!! %!sudo tee > /dev/null %

" plugins

" show recently opened files
noremap <Leader>m :MRU<CR>  

" Start Geeknote
noremap <Leader>g :Geeknote<CR>  

" show undo tree
noremap <Leader>u :UndotreeToggle<CR>  

" syntastic 
if exists(':SyntasticStatuslineFlag()')
    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*

    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_check_on_open = 1
    let g:syntastic_check_on_wq = 0
endif

" YouCompleteMe
let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/third_party/ycmd/examples/.ycm_extra_conf.py'    
" autoclose suggestion windows
let g:ycm_autoclose_preview_window_after_insertion=1

" colors
highlight YcmWarningSection ctermfg=Yellow
highlight YcmWarningSign ctermfg=Yellow

highlight YcmErrorSection ctermfg=Red
highlight YcmErrorsign ctermfg=Red
