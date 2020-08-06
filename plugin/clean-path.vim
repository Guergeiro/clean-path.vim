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
