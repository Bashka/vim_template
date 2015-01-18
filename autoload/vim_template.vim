" Date Create: 2015-01-17 21:36:40
" Last Change: 2015-01-18 11:05:53
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:File = vim_lib#base#File#
let s:Content = vim_lib#sys#Content#
let s:Publisher = vim_lib#sys#Publisher#

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
          call s:Publisher.new().fire('VimTemplateLoad', {'template': l:applicant})
          return
        endif
      endfor
    endfor
  endif
endfunction " }}}