if vim.g.do_filetype_lua == 1 then
  vim.filetype.add {
    extension = {
      schelp = 'scdoc',
    },
  }
end
