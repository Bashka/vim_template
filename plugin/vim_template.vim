" Date Create: 2015-01-17 10:48:16
" Last Change: 2015-02-15 12:16:22
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Plugin = vim_lib#sys#Plugin#
let s:System = vim_lib#sys#System#.new()

let s:p = s:Plugin.new('vim_template', '1', {'plugins': ['vim_prj']})

let s:p.tmpldir = 'templates'         " Имя каталога, содержащего шаблоны.
let s:p.tmplname = '___'              " Шаблонное имя файла шаблона.
if !exists('g:vim_template#keywords')
  let g:vim_template#keywords = {}    " Словарь маркеров.
endif

function! s:p.run() " {{{
  call s:System.au('BufReadPost,BufNewFile', function('vim_template#load'))
endfunction " }}}

call s:p.reg()
