" Date Create: 2015-01-17 10:48:16
" Last Change: 2015-01-24 12:55:43
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Plugin = vim_lib#sys#Plugin#

let s:p = s:Plugin.new('vim_template', '1', {'plugins': ['vim_prj']})

call s:p.def('tmpldir', 'templates') " Имя каталога, содержащего шаблоны.
call s:p.def('tmplname', '___') " Шаблонное имя файла шаблона.
call s:p.def('vim_template#keywords', {}) " Словарь маркеров.

call s:p.au('BufReadPost,BufNewFile', '*', 'load')

call s:p.reg()
