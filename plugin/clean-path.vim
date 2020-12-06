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
    let l:output = a:line
    if l:output =~ '^/'
        let l:output = substitute(a:line, '/', '', '')
    endif

    if l:output =~ '/$'
        return l:output . "*"
    endif
    return l:output
endfunction

function! s:IgnoreString(dirPath) abort
    let l:gitignore = a:dirPath . "/.gitignore"
    if !filereadable(l:gitignore)
        return ""
    endif

    let l:igstring = ""
    for oline in readfile(l:gitignore)

        let l:line = substitute(oline, '\s|\n|\r', '', "g")
        if line =~ '^#'   | con | endif
        if line == ''     | con | endif
        if line =~ '^!'   | con | endif
        if line =~ '^\s$' | con | endif

        let l:igstring .= "," . a:dirPath . "/" . s:CleanString(l:line)
    endfor

    return substitute(l:igstring, '^,', '', "g")
endfunction

function! s:AddDirectoriesToPath(findString) abort
    " Finds directories
    let l:dirs = filter(systemlist(a:findString), {_,dir ->
                \ !empty(dir) && empty(filter(split(&wildignore, ','), {_,v -> v =~? dir[0:]}))
                \ })

    if empty(l:dirs)
        return ""
    endif
    " Append directories to path
    let &path .= join(map(l:dirs, 'v:val[0:]."/**"'), ',')
endfunction

function! s:AddIgnoredToWildignore(ignored) abort
    if a:ignored != ""
        if &wildignore != ""
            let &wildignore .= ","
        endif
        let &wildignore .= a:ignored
    endif
endfunction

function! s:RemoveIgnoredFromWildignore(originalWildignore) abort
    let &wildignore = a:originalWildignore
endfunction


function! s:SetPath() abort
    let l:gitDir = system("git rev-parse --show-toplevel")
    let l:gitDir = substitute(l:gitDir, "\n", "", "g")
    let l:originalWildignore = &wildignore

    if (l:gitDir != "")
        let l:ignored = s:IgnoreString(l:gitDir)
        call s:AddIgnoredToWildignore(l:ignored)

        let l:findString = "find " . l:gitDir . " -maxdepth 1 -type d -not -path " . l:gitDir
        call s:AddDirectoriesToPath(l:findString)
    else
        let l:curDir = getcwd()
        let l:ignored = s:IgnoreString(l:curDir)
        call s:AddIgnoredToWildignore(l:ignored)

        let l:findString = "find " . l:curDir . " -maxdepth 1 -type d -not -path " . l:curDir
        call s:AddDirectoriesToPath(l:findString)
    endif
    if (!exists("g:clean_path_wildignore"))
        call s:RemoveIgnoredFromWildignore(l:originalWildignore)
    endif
endfunction

call s:SetPath()
let g:clean_path = 1
