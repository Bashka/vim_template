" Date Create: 2015-01-17 10:48:16
" Last Change: 2015-02-03 10:41:43
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Plugin = vim_lib#sys#Plugin#

let s:p = s:Plugin.new('vim_template', '1', {'plugins': ['vim_prj']})

let s:p.tmpldir = 'templates'         " Имя каталога, содержащего шаблоны.
let s:p.tmplname = '___'              " Шаблонное имя файла шаблона.
if !exists('g:vim_template#keywords')
  let g:vim_template#keywords = {}    " Словарь маркеров.
endif

call s:p.au('BufReadPost,BufNewFile', '*', 'load')

call s:p.reg()
