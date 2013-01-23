" File:    shellcommand.vim
" Author:  kmnk <kmnknmk+vim@gmail.com>
" Version: 0.1.0
" Last Modified: Jan 11, 2013
" Copyright: Copyright (C) 2013- kmnk
" License: MIT Licence {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"     The above copyright notice and this permission notice shall be
"     included in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
"     EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}

let s:save_cpo = &cpo
set cpo&vim

" variables {{{
if exists('g:unite_shellcommand_list_file')
  let s:list_file = fnamemodify(g:unite_shellcommand_list_file, ':p')
else
  let s:list_file = fnamemodify('~/.vim_unite_shellcommand_list', ':p')
endif

let s:list = []
" }}}

function! shellcommand#list()"{{{
  return s:list
endfunction"}}}

function! shellcommand#commands()"{{{
  if !exists('s:command_of')
    call s:load()
  endif
  return map(keys(s:command_of), '{
\   "name" : v:val,
\   "command" : s:command_of[v:val],
\ }')
endfunction"}}}

function! shellcommand#system(command)"{{{
  return system(a:command)
endfunction"}}}

function! shellcommand#execute(command)"{{{
  execute a:command
endfunction"}}}

function! shellcommand#add(name, command)"{{{
  let s:command_of[a:name] = a:command
  call s:write()
endfunction"}}}

function! shellcommand#remove(name)"{{{
  call remove(s:command_of, a:name)
  call s:write()
endfunction"}}}

function! shellcommand#get(name)"{{{
  if !has_key(s:command_of, a:old_name)
    echoerr printf('no command is registered of "%s"', a:old_name)
  else
    return s:command_of[a:name]
  endif
endfunction"}}}

function! shellcommand#rename(old_name, new_name)"{{{
  if !has_key(s:command_of, a:old_name)
    echoerr printf('no command is registered of "%s"', a:old_name)
  else
    let s:command_of[a:new_name] = remove(s:command_of, a:old_name)
  endif
  call s:write()
endfunction"}}}

function! shellcommand#update(name, command)"{{{
  if !has_key(s:command_of, a:name)
    echoerr printf('no command is registered of "%s"', a:name)
  else
    let s:command_of[a:name] = a:command
  endif
  call s:write()
endfunction"}}}

function! shellcommand#push(name, command)"{{{
  return add(s:list, { "name" : a:name, "command" : a:command })
endfunction"}}}

function! shellcommand#pop()"{{{
  return remove(s:list, -1)
endfunction"}}}

function! shellcommand#shift()"{{{
  return remove(s:list, 0)
endfunction"}}}}}

function! shellcommand#clear()"{{{
  let s:list = []
endfunction"}}}

function! shellcommand#output(data, path)"{{{
  let lines = split(a:data, '\n')
  call writefile(lines, a:path)
endfunction"}}}

function! shellcommand#yank(data)"{{{
  let @" = a:data
endfunction"}}}

function! shellcommand#view(data)"{{{
  call shellcommand#execute('new')
  put!=a:data
  keepjumps normal gg
  call shellcommand#execute('delete')
  call shellcommand#execute('setlocal buftype=nofile')
endfunction"}}}

function! shellcommand#pipe()"{{{
  return join(map(copy(s:list), 'v:val.command'), ' | ')
endfunction"}}}

function! shellcommand#run()"{{{
  let command = shellcommand#pipe()
  return shellcommand#system(command)
endfunction"}}}

" local functions {{{
function! s:serialize(name, command)"{{{
  return printf("%s\t%s", a:name, a:command)
endfunction"}}}

function! s:deserialize(line)"{{{
  let matches = matchlist(a:line, '\(.\+\)\t\(.\+\)')
  return { 'name' : matches[1], 'command' : matches[2] }
endfunction"}}}

function! s:write()"{{{
  let lines = []
  for name in keys(s:command_of)
    call add(lines, s:serialize(name, s:command_of[name]))
  endfor
  call writefile(lines, s:list_file)
endfunction"}}}

function! s:load()"{{{
  let s:command_of = {}

  let lines = []

  try
    let lines = readfile(s:list_file)
  catch /E484/
    call writefile([], s:list_file)
    let lines = []
  endtry

  for line in lines
    let line = substitute(line, '\n$', '', '')
    let deserialized = s:deserialize(line)
    let s:command_of[deserialized.name] = deserialized.command
  endfor
endfunction"}}}
" }}}

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
