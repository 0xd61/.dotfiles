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
set autoread
" :W sudo saves the file
" (useful for handling the permission-denied error)
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!
set shortmess=I


" Copy & Paste
set pastetoggle=<F2>
set clipboard=unnamedplus
set mouse=a "(alt + click)

set nocompatible
set background=dark

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"set so=7 " Set 7 lines to the cursor - when moving vertically using j/k
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
set history=10000
set cursorline

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
"set columns=120
set ai "Auto indent
set si "Smart indent
"set wrap "Wrap lines
"nnoremap <leader>c :execute "set colorcolumn=" . (&colorcolumn == "" ? "80" : "")<CR>
highlight ColorColumn ctermbg=8

inoremap {      {}<Left>
inoremap {<CR>  {<CR>}<Esc>O
inoremap {{     {
inoremap {}     {}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Build Config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO(dgl): make this overridable in a local config
set makeprg=./build.teak