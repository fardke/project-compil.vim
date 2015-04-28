let s:project_file = ".vproject"

function! s:FindDir()
  let l:dir = fnamemodify(getcwd(), ':p') . '.'
  while dir != fnamemodify(dir, ':h')
    let dir = fnamemodify(dir, ':h')
    if filereadable(dir . '/' . s:project_file)
      return dir . '/' . s:project_file
    endif
  endwhile
  return ''
endfunc

function! s:initVariable(var, value)
  if !exists(a:var)
    exec 'let ' . a:var . ' = ' . "'" . a:value . "'"
      return 1
  endif
  return 0
endfunction

function! s:Init(proj_file)
  if !empty(a:proj_file)
    let l:proj_vars = [ 'g:build_dir', 'g:makeprg', 'g:confprg', 'g:confopts', 'g:makedocprg', 'g:makedocarg']

    let l:proj_dir = fnamemodify(a:proj_file, ':h')

    exec 'source ' . a:proj_file

    call s:initVariable('g:build_dir', '@PROJECT_DIR@/build')
    call s:initVariable('g:makeprg', 'make')
    call s:initVariable('g:confprg', '@PROJECT_DIR@/configure')
    call s:initVariable('g:confopts', '')
    call s:initVariable('g:makedocprg', '')
    call s:initVariable('g:makedocarg', '')
    call s:initVariable('g:include_dir', '/usr/include')

    for var in l:proj_vars
      exec "let " . var . " = substitute(" . var . ", '@PROJECT_DIR@', l:proj_dir, '')"
    endfor

    execute 'set makeprg=' . escape('cd ' . g:build_dir . '; ' . g:makeprg, ' ')
    execute 'com! -nargs=* Configure !' . 'mkdir -p ' . g:build_dir . ';cd ' . g:build_dir . '; ' . g:confprg . ' <args> ' . g:confopts
    execute 'com! -nargs=* MakeDoc !' . g:makedocprg . ' <args> ' . g:makedocarg
    for var in l:proj_vars
      exec "unlet " . var
    endfor
  endif
endfunc

:com! LoadProject :call s:Init(s:FindDir())

" vim:set sts=2 sw=2:
