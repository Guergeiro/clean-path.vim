" clean-path.vim - A clean way of adding directories and files to Vim's &path.
" Maintainer: Breno Salles <git@brenosalles.com>
" License:    MIT License
" Location:   autoload/cleanpath.vim
" Website:    https://github.com/Guergeiro/clean-path.vim"
"
let s:save_cpo = &cpo
set cpo&vim

function! cleanpath#cleanstring(line) abort
    " If line starts with a '/', remove it
    let l:output = a:line
    if l:output =~ '^/'
      let l:output = substitute(a:line, '/', '', '')
    endif

    if l:output =~ '/$'
      return l:output . '*'
    endif
    return l:output
endfunction

function! cleanpath#wildignore(path) abort
    let l:gitignore = a:path . '/.gitignore'
    if !filereadable(l:gitignore)
      return ''
    endif

    let l:igstring = ''
    for oline in readfile(l:gitignore)

      let l:line = substitute(oline, '\s|\n|\r', '', 'g')
      if line =~ '^#'   | con | endif
      if line == ''     | con | endif
      if line =~ '^!'   | con | endif
      if line =~ '^\s$' | con | endif

      let l:igstring .= ',' . a:path . '/' . cleanpath#cleanstring(l:line)
    endfor

    return substitute(l:igstring, '^,', '', 'g')
endfunction

function! cleanpath#getcwd() abort
  let l:projectDir = system('git rev-parse --show-toplevel')
  let l:projectDir = substitute(l:projectDir, '\n', '', 'g')
  if (l:projectDir == '')
    let l:projectDir = getcwd()
  endif
  return l:projectDir
endfunction

function cleanpath#getdirectories(path) abort
  let l:max_depth = get(g:, 'cleanpath_max_depth', 1)
  let l:findString = 'find ' .
        \ a:path .
        \ ' -maxdepth ' . l:max_depth .
        \ ' -type d -not -path ' .
        \ a:path
  return systemlist(l:findString)
endfunction

function! cleanpath#setpath() abort
  let l:cwd = cleanpath#getcwd()
  let l:systemDirs = cleanpath#getdirectories(l:cwd)
  let l:wildignore = cleanpath#wildignore(l:cwd)
  " Cleans directories
  let l:dirs = filter(l:systemDirs, {_,dir ->
              \ !empty(dir) && empty(filter(split(l:wildignore, ','), {_,v -> v =~? dir[0:]}))
              \ })

  if empty(l:dirs)
    return ''
  endif
  " Append directories to path
  return join(map(l:dirs, 'v:val[0:]."/**"'), ',')
endfunction

function! cleanpath#setwildignore() abort
  let l:cwd = cleanpath#getcwd()
  let l:wildignore = cleanpath#wildignore(l:cwd)
  return l:wildignore
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
