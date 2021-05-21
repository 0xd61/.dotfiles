" Credits:
" - to Max Cantor for his no-plugin config https://github.com/changemewtf/no_plugins/blob/master/no_plugins.vim
" - to Micha Mettke for his config https://github.com/vurtun/dotfiles/blob/master/.vimrc
"
"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Map leader
let mapleader=" "
" Automatic reloading
autocmd! bufwritepost .vimrc source %
set autoread
" :W sudo saves the file
" (useful for handling the permission-denied error)
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

" Copy & Paste
set pastetoggle=<F2>
set clipboard=unnamedplus
set mouse=a "(alt + click)

set nocompatible
set background=dark

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set so=7 " Set 7 lines to the cursor - when moving vertically using j/k
set cmdheight=2
set hid " Buffer becomes hidden, when abandoned
set backspace=eol,start,indent " Configure backspace so it acts as it should act
set whichwrap+=<,>,h,l
set ignorecase
set hlsearch " Highlight search results
set incsearch " Makes search act like search in modern browsers
set lazyredraw " Don't redraw while executing macros (good performance config)
set magic " For regular expressions turn magic on
set showmatch " Show matching brackets when text indicator is over them
set mat=2 " How many tenths of a second to blink when matching brackets
"set splitbelow " new splits are down
set splitright " new vsplits are to the right
set history=1000
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set list
set listchars=tab:>-,trail:- " show tabs and trailing
set smartcase " When searching try to be smart about cases
set smartindent
set smarttab
set expandtab
set showcmd
"set number
set linebreak
set textwidth=0
set cindent
set shiftwidth=4
set softtabstop=4
set autoread
set tabstop=4
set columns=80
set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines
nnoremap <leader>c :execute "set colorcolumn=" . (&colorcolumn == "" ? "80" : "")<CR>
highlight ColorColumn ctermbg=8

inoremap {      {}<Left>
inoremap {<CR>  {<CR>}<Esc>O
inoremap {{     {
inoremap {}     {}
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype indent on
filetype plugin indent on
filetype on
filetype plugin on
syntax on
set grepprg=grep\ -nH\ $*

syntax on
set t_Co=256
set encoding=utf8
" Use Unix as the standard file type
set ffs=unix,dos,mac
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Folding
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set foldenable " Turn on folding
set foldmethod=marker
autocmd FileType c setlocal foldmethod=syntax
set foldlevel=1
set foldlevel=100 " Don't autofold anything (but I can still fold manually)
set foldnestmax=1 " I only like to fold outer functions
set foldopen=block,hor,mark,percent,quickfix,tag " what movements open folds
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Menu
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set wildmenu " Display all matching files when we tab complete
set wildmode=list:longest,full
set wildignore=*.o,*~,*.pyc,
set wildignore+=*.pdf,*.pyo,*.pyc,*.zip,*.so,*.swp,*.dll,*.o,*.DS_Store,*.obj,*.bak,*.exe,*.pyc,*.jpg,*.gif,*.png,*.a
set wildignore+=.git\*,.hg\*,.svn\*.o,*~,*pyc
" Search down into subfolders
" Provides tab-completion for all file-related tasks
set path+=**
" set autochdir " tells vim to search in the parent dir

" find files and populate the quickfix list
fun! FindFiles(filename)
  let error_file = tempname()
  silent exe '!find . -iname "*'.a:filename.'*" | xargs file | sed "s/:/:1:/" > '.error_file
  set errorformat=%f:%l:%m
  exe "cfile ". error_file
  copen
  call delete(error_file)
endfun
command! -nargs=1 FindFile call FindFiles(<q-args>)

"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Backup
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Extra folders for swap, backup and undo files
set backupdir=$HOME/.vim/backup//
set directory=$HOME/.vim/swap//
set undodir=$HOME/.vim/undo//


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Mapping
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" move by visual line
nnoremap j gj
nnoremap k gk
xnoremap j gj
xnoremap k gk

nnoremap J 5j
nnoremap K 5k
xnoremap J 5j
xnoremap K 5k

" copy/paste replaced
vmap <Leader>y "+y
vmap <Leader>d "+d
vmap <Leader>P "+p

" Remove highlight after search
noremap <Leader>D :nohl<CR>

" Tabs
map <Leader>n <esc>:tabprevious<CR>
map <Leader>m <esc>:tabnext<CR>
map <Leader>b <esc>:tabnew<CR>

" Shifting
nnoremap < <S-V><<Esc>
nnoremap > <S-V>><Esc>
vnoremap < <gv
vnoremap > >gv

" Remapping Esc
inoremap jk <Esc>

" Remapping Tag jumping
noremap <Leader>t <C-]>
noremap <Leader>T <C-T>
noremap <Leader>bt <esc>:tab split<CR>:exec("tag ".expand("<cword>"))<CR>
noremap <Leader>st <esc>:vsp <CR>:exec("tag ".expand("<cword>"))<CR>

" Quick file open
"nnoremap <Leader>f :find 
nnoremap <Leader>f :FindFile 

""""""""""""""""""""""""""""""
" => Plugin
""""""""""""""""""""""""""""""

" TAG JUMPING:

" Create the `tags` file (may need to install ctags first)
command! MakeTags !ctags -a -u -R .
set tags=tags; "tells vim that the name of your tags file will always be the same as the default tags file generated by ctags

" NOW WE CAN:
" - Use ^] to jump to tag under cursor
" - Use g^] for ambiguous tags
" - Use ^T to jump back up the tag stack

" THINGS TO CONSIDER:
" - This doesn't help if you want a visual list of tags

" FILE BROWSING:

" Tweaks for browsing
let g:netrw_banner=0        " disable annoying banner
let g:netrw_browse_split=4  " open in prior window
let g:netrw_altv=1          " open splits to the right
let g:netrw_liststyle=3     " tree view
let g:netrw_list_hide=netrw_gitignore#Hide()
let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'
let g:netrw_winsize = 15
"augroup ProjectDrawer
"  autocmd!
"  autocmd VimEnter * :Vexplore
"augroup END

" NOW WE CAN:
" - :edit a folder to open a file browser
" - <CR>/v/t to open in an h-split/v-split/tab
" - check |netrw-browse-maps| for more mappings

" BUILD INTEGRATION:

" Configure the `make` command to run RSpec
set makeprg=./build.sh

" NOW WE CAN:
" - Run :make to run RSpec
" - :cl to list errors
" - :cc# to jump to error by number
" - :cn and :cp to navigate forward and back
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Ledger
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Account completion to be sorted by level of detail/depth instead of alphabetical
let g:ledger_detailed_first = 1
noremap <silent><buffer> <Leader>T :call ledger#transaction_state_toggle(line('.'), ' *?!')<CR>
