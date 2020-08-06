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

function! s:BuildString(line) abort
    " If line starts with a '/', remove it
    if a:line =~ '^/'
        let a:line = substitute(a:line, '/', '', '')
    endif

    if a:line =~ '/$'
        return  a:line . "*"
    endif
    return a:line
endfunction

function! s:WildignoreString(gitPath) abort
    let gitignore = a:gitPath . "/.gitignore"
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

        let igstring .= "," . a:gitPath . "/" . s:BuildString(line)
    endfor

    return substitute(igstring, '^,', '', "g")
endfunction

function! s:SetPathFromGit() abort
    let gitDir = system("git rev-parse --show-toplevel")
    let gitDir = substitute(gitDir, "\n", "", "g")

    let ignored = ""
    if stridx(gitDir, "fatal") == -1
        " In Git Dir
        let ignored .= s:WildignoreString(gitDir)
    endif

    let l:findString = "find " . gitDir . " -maxdepth 1"

    " Finds directories
    let l:dirs = filter(systemlist(l:findString . " -type d"), {_,dir ->
                \ !empty(dir) && empty(filter(split(ignored, ','), {_,v -> v =~? dir[2:]}))
                \ })

    " Finds files
    let l:files = filter(systemlist(l:findString . " -type f"), {_,dir ->
                \ !empty(dir) && empty(filter(split(ignored, ','), {_,v -> v =~? dir[2:]}))
                \ })

    if !empty(l:dirs)
        " Append directories to path
        let &path = &path.','.join(map(l:dirs, 'v:val[0:]."/**"'), ',')
    endif
    if !empty(l:files)
        " Append files to path
        let &path = &path.','.join(map(l:files, 'v:val[0:]'), ',')
    endif

endfunction

if exists("g:clean_path")
    finish
endif
call s:SetPathFromGit()
let g:clean_path = 1
