" Date Create: 2015-01-17 10:48:16
" Last Change: 2015-01-18 11:58:12
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Plugin = vim_lib#sys#Plugin#

let s:p = s:Plugin.new('vim_template', '1', {'plugins': ['vim_prj']})
call s:p.def('tmpldir', 'templates')
call s:p.def('tmplname', '___')

function! s:p.run() " {{{
  autocmd BufReadPost,BufNewFile * call vim_template#load()
endfunction " }}}

call s:p.reg()
