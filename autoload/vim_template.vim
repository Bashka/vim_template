" Date Create: 2015-01-17 21:36:40
" Last Change: 2015-01-24 12:54:57
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:File = vim_lib#base#File#
let s:Content = vim_lib#sys#Content#
let s:Publisher = vim_lib#sys#Publisher#

"" {{{
" Метод загружает шаблон в текущий буфер, если он пуст.
"" }}}
function! vim_template#load() " {{{
  if s:Content.new().isEmpty() " Заполнение только пустых буферов
    let l:file = expand('%:t')
    let l:ext = expand('%:e')
    " Последовательно исследуем каталоги, которые могут хранить шаблоны
    for l:templDir in [g:vim_prj#.prj, g:vim_prj#.user, g:vim_prj#.global]
      let l:templDir = l:templDir . s:File.slash . g:vim_template#.tmpldir
      " Если каталога шаблонов нет, пропускаем действия
      if !s:File.absolute(l:templDir).isExists()
        continue
      endif
      let l:path = split(expand('%:h'), s:File.slash)
      let l:templates = [] " Шаблоны, сгруппированные по иерархии каталогов пути целевого файла
      " Ищем подходящие шаблоны (сначала наиболее вложенные)
      call add(l:templates, globpath(l:templDir, join(l:path, s:File.slash) . s:File.slash . '**' . s:File.slash . '*.' . l:ext))
      while len(l:path) > 1
        let l:path = l:path[0:-2]
        call add(l:templates, globpath(l:templDir, join(l:path, s:File.slash) . s:File.slash . '**' . s:File.slash . '*.' . l:ext))
      endwhile
      call add(l:templates, globpath(l:templDir, '*.' . l:ext))
      " Проверяем последовательно каждую группу
      for l:group in l:templates
        " Ищем наиболее подходящий файл шаблона
        let l:minLen = 1000
        let l:applicant = ''
        for l:templ in split(l:group, "\n")
          " Заменяем ___ на "любая последовательность символов" для регулярного выражения
          let l:templPattern = substitute(fnamemodify(l:templ, ':t'), g:vim_template#.tmplname, '\\(\\.\\*\\)', '')
          let l:match = matchlist(l:file, '^\V' . l:templPattern)
          " Отбрасываем шаблоны, не соответствующие требованию
          if empty(l:match)
            continue
          endif
          " Определяем шаблон с минимальной "любой последовательностью символов"
          let l:matchLen = len(l:match[1])
          if l:matchLen < l:minLen
            let l:minLen = l:matchLen
            let l:applicant = l:templ
          endif
        endfor 
        " Вставляем шаблон, если таковой имеется
        if len(l:applicant) != 0
          exe '0r ' . l:applicant
          silent $ delete _
          call vim_template#replaceKeywords()
          call s:Publisher.new().fire('VimTemplateLoad', {'template': l:applicant})
          return
        endif
      endfor
    endfor
  endif
endfunction " }}}

"" {{{
" Метод заменяет в текущем буфере все маркеры, которые имеют вид: <+имя+>.
" Маркеры заменяются на свойства объекта vim_template#keywords с тем же именем. То есть маркер вида <+mark+> будет заменен на значение свойства vim_template#keywords.mark.
" Предопределены следующие маркеры:
"   - date - текущая дата в формате ГГГГ-ММ-ДД
"   - time - текущее время в формате ЧЧ-ММ-СС
"   - datetime - текущая дата и время
"   - fname - имя текущего файла
"   - ftype - расширение файла
"   - file - имя и расширение текущего файла
"   - dir - адрес каталога, содержащего текущий файл
"   - namespace - адрес каталога, содержащего текущий файл и его имя
" Метод так же заменяет все конструкции вида `...` на значения, получаемые в результате исполнения содержимого этих конструкции.
" Маркер <++> используется для указания места установки курсора после вставки шаблона.
"" }}}
function! vim_template#replaceKeywords() " {{{
  " Динамические маркеры. {{{
  let g:vim_template#keywords.date = strftime('%Y-%m-%d') " Текущая дата
  let g:vim_template#keywords.time = strftime('%T') " Текущее время
  let g:vim_template#keywords.datetime = strftime('%Y-%m-%d %T') " Текущая дата и время
  let g:vim_template#keywords.file = expand('%:t') " Имя текущего файла
  let g:vim_template#keywords.ftype = expand('%:e') " Расширение текущего файла
  let l:point = strridx(g:vim_template#keywords.file, '.')
  if l:point != -1
    let g:vim_template#keywords.fname = strpart(g:vim_template#keywords.file, 0, l:point) " Имя текущего файла без расширения
  else
    let g:vim_template#keywords.fname = g:vim_template#keywords.file
  endif
  let g:vim_template#keywords.dir = expand('%:h') " Адрес родительского каталога относительно текущего каталога редактора
  let g:vim_template#keywords.namespace = g:vim_template#keywords.dir . '/' . g:vim_template#keywords.fname " Адрес родительского каталога и имя текущего файла без расширения
  " }}}
  " Раскрываем все складки перед заменами, иначе могут быть потеряны некоторые складки полностью
  normal zR
	silent! %s/`\(.\{-}\)`/\=eval(submatch(1))/ge
	silent! %s/<+\(\w\+\)+>/\=(has_key(g:vim_template#keywords, submatch(1)))? g:vim_template#keywords[submatch(1)] : ''/ge
	if search('<++>')
    execute 'normal! "_da>'
	endif
endfunction " }}}
