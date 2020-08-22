" Maintainer:	Breno Salles <git@brenosalles.com>
" License:  	MIT License
"
"         Copyright (c) 2020 Breno Salles
"
"         Permission is hereby granted, free of charge, to any person obtaining a copy
"         of this software and associated documentation files (the "Software"), to deal
"         in the Software without restriction, including without limitation the rights
"         to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
"         copies of the Software, and to permit persons to whom the Software is
"         furnished to do so, subject to the following conditions:
"
"         The above copyright notice and this permission notice shall be included in all
"         copies or substantial portions of the Software.
"
"         THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
"         IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
"         FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
"         AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
"         LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
"         OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
"         SOFTWARE.

if exists("g:clean_path")
    finish
endif

function! s:CleanString(line) abort
    " If line starts with a '/', remove it
    if a:line =~ '^/'
        let a:line = substitute(a:line, '/', '', '')
    endif

    if a:line =~ '/$'
        return  a:line . "*"
    endif
    return a:line
endfunction

function! s:WildignoreString(dirPath) abort
    let gitignore = a:dirPath . "/.gitignore"
    if !filereadable(gitignore)
        return ""
    endif

    let igstring = ""
    for oline in readfile(gitignore)

        let line = substitute(oline, '\s|\n|\r', '', "g")
        if line =~ '^#'   | con | endif
        if line == ''     | con | endif
        if line =~ '^!'   | con | endif
        if line =~ '^\s$' | con | endif

        let igstring .= "," . a:dirPath . "/" . s:CleanString(line)
    endfor

    return substitute(igstring, '^,', '', "g")
endfunction

function! s:AddFilesToPath(findString) abort
    " Finds files
    let l:files = filter(systemlist(a:findString), {_,dir ->
                \ !empty(dir) && empty(filter(split(&wildignore, ','), {_,v -> v =~? dir[0:]}))
                \ })
    if !empty(l:files)
        " Append files to path
        if &path == ""
            let &path = ".,,"
        endif
        let &path .= join(map(l:files, 'v:val[0:]'), ',')
    endif
endfunction

function! s:AddDirectoriesToPath(findString) abort
    " Finds directories
    let l:dirs = filter(systemlist(a:findString), {_,dir ->
                \ !empty(dir) && empty(filter(split(&wildignore, ','), {_,v -> v =~? dir[0:]}))
                \ })

    if !empty(l:dirs)
        " Append directories to path
        if &path == ""
            let &path = ".,,"
        endif
        let &path .= join(map(l:dirs, 'v:val[0:]."/**"'), ',')
    endif
endfunction

function! s:AddIgnoredToWildignore(ignored) abort
    if a:ignored != ""
        if &wildignore != ""
            let &wildignore .= ","
        endif
        let &wildignore .= a:ignored
    endif
endfunction

function! s:SetPath() abort
    let gitDir = system("git rev-parse --show-toplevel")
    let gitDir = substitute(gitDir, "\n", "", "g")

    if gitDir != ""
        " In Git Dir
        let ignored = s:WildignoreString(gitDir)
        call s:AddIgnoredToWildignore(ignored)

        let l:findString = "find " . gitDir . " -maxdepth 1"
        call s:AddFilesToPath(findString . " -type f")
        call s:AddDirectoriesToPath(findString . " -type d -not -path " . gitDir)
        return
    endif
    let curDir = getcwd()

    let ignored = s:WildignoreString(curDir)
    call s:AddIgnoredToWildignore(ignored)

    let l:findString = "find " . curDir . " -maxdepth 1"
    call s:AddFilesToPath(findString . " -type f")
    call s:AddDirectoriesToPath(findString . " -type d -not -path " . curDir)
endfunction

set path=
call s:SetPath()
let g:clean_path = 1
