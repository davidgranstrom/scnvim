if vim.fn.has "nvim-0.7" == 1 and vim.g.do_filetype_lua == 1 then
  vim.filetype.add {
    extension = {
      sc = "supercollider",
      scd = "supercollider",
      schelp = "scdoc",
    },
  }
end
