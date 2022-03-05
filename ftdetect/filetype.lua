if vim.fn.has "nvim-0.7" then
  vim.filetype.add {
    extension = {
      sc = "supercollider",
      scd = "supercollider",
      schelp = "scdoc",
    },
  }
end
