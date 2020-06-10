" File: autoload/health/scnvim.vim
" Author: David Granström
" Description: Health check

scriptencoding utf-8

function! s:check_minimum_nvim_version() abort
  if !has('nvim-0.4.3')
    call health#report_error(
          \ 'has(nvim-0.4.3)',
          \ 'scnvim requires nvim 0.4.3 or later'
          \ )
  endif
endfunction

function! s:check_linkage() abort
  let path = luaeval("require('scnvim/install').check()")
  if path != v:null
    call health#report_ok('SCNvim classes installed: ' . path)
  else
    call health#report_error(
          \ 'SCNvim SuperCollider classes are not installed',
          \ ':call scnvim#install()'
          \ )
  end
endfunction

function! s:check_timers() abort
  if has('timers')
    call health#report_ok('has("timers") - success')
  else
    call health#report_warn(
          \ 'has("timers" - error)',
          \ 'scnvim needs "+timers" for eval flash'
          \ )
  endif
endfunction

function! s:check_sclang_executable() abort
  let user_sclang = get(g:, 'scnvim_sclang_executable')
  if !empty(user_sclang)
    call health#report_info('using g:scnvim_sclang_executable = ' . user_sclang)
  endif

  try
    let sclang = scnvim#util#find_sclang_executable()
    call health#report_info('sclang executable: ' . sclang)
  catch
    call health#report_error(
          \ 'could not find sclang executable',
          \ 'set g:scnvim_sclang_executable or add sclang to your $PATH'
          \ )
  endtry
endfunction

function! s:check_scdoc_render_prg() abort
  let scdoc_prg = get(g:, 'scnvim_scdoc_render_prg')
  if !empty(scdoc_prg)
    call health#report_info('using g:scnvim_scdoc_render_prg = ' . scdoc_prg)
  endif
  let scdoc_args = scnvim#util#get_scdoc_render_args()
  if !empty(scdoc_args)
    call health#report_info('using g:scnvim_scdoc_render_args = ' . scdoc_args)
  endif
  " default
  try
    let exe = scnvim#util#find_scdoc_render_prg()
    call health#report_info('scdoc render program: ' . exe)
  catch
    call health#report_info(
          \ 'Could not find scdoc render program. See :h scnvim-help-system for more information.
          \  This is an optional dependency and only needed for SCDoc integration.'
          \ )
  endtry
endfunction

function! health#scnvim#check() abort
  call health#report_start('scnvim')
  call s:check_minimum_nvim_version()
  call s:check_linkage()
  call s:check_timers()
  call s:check_sclang_executable()
  call s:check_scdoc_render_prg()
endfunction
