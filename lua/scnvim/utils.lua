--- Utility functions.
-- @module scnvim/utils
-- @author David Granström
-- @license GPLv3

local M = {}

------------------
--- Compat
------------------

--- vim.call is not present in nvim 0.4.4 or earlier
function M.vimcall(fn, args)
  if args and type(args) ~= 'table' then
    args = {args}
  end
  args = args or {}
  return vim.api.nvim_call_function(fn, args)
end

function M.get_var(name)
  local result, value = pcall(vim.api.nvim_get_var, name)
  if result then
    return value
  end
  return nil
end

------------------
--- Various
------------------

function M.json_encode(data)
  -- uncomment for nvim 0.5.x
  -- return pcall(vim.fn.json_encode, data)
  return M.vimcall('json_encode', data)
end

function M.json_decode(data)
  -- uncomment for nvim 0.5.x
  -- return pcall(vim.fn.json_decode, data)
  return M.vimcall('json_decode', data)
end

------------------
--- String
------------------

--- Match an exact occurence of word
-- (replacement for \b word boundary)
function M.str_match_exact(input, word)
  return string.find(input, "%f[%a]" .. word .. "%f[%A]") ~= nil
end

-- modified version of vim.endswith (runtime/lua/vim/shared.lua)
-- needed for nvim versions < 0.5
function M.str_endswidth(s, suffix)
  return #suffix == 0 or s:sub(-#suffix) == suffix
end

--- Get the system path separator
M.is_windows = vim.loop.os_uname().sysname:match('Windows')
M.path_sep = M.is_windows and '\\' or '/'

------------------
--- Table
------------------

--- Get table length
function M.tbl_len(T)
  local count = 0
  for _ in pairs(T) do
    count = count + 1
  end
  return count
end

------------------
--- Floating args
------------------

-- TODO: @salkin-mada -> add g var
-- for automatically closing floating arg buffer/win on CursorMoved
-- and BufLeave on "parent" buffer
-- also go over vars/tables and the local usage... uzi local.. local local
function string.split(s,re,plain,n)
    local find,sub,append = string.find, string.sub, table.insert
    local i1,ls = 1,{}
    if not re then re = '%s+' end
    if re == '' then return {s} end
    while true do
        local i2,i3 = find(s,re,i1,plain)
        if not i2 then
            local last = sub(s,i1)
            if last ~= '' then append(ls,last) end
            if #ls == 1 and ls[1] == '' then
                return {}
            else
                return ls
            end
        end
        append(ls,sub(s,i1,i2-1))
        if n and #ls == n then
            ls[#ls] = sub(s,i1)
            return ls
        end
        i1 = i3+1
    end
end

function M.floating_args(input)
  -- input = input or ""
  local name = '[scnvim-method-args]_'
  local current_buffer = vim.api.nvim_get_current_buf()
  local identifier = name .. current_buffer
  local identified_bufnr = vim.api.nvim_exec(string.format("silent echo bufnr('%s')", identifier), true)
  -- open/close buffer and win (toggle behavior)
  if vim.api.nvim_buf_is_loaded(identified_bufnr) then
    vim.api.nvim_buf_delete(identified_bufnr, {})
  else
    -- dont create buffer and window if input string len is 0 aka no return string
    if string.len(input) > 0 then
      local args_string
      local len
      local function callback(result)
        if result ~= nil then
          if string.len(result) > 0 then
            if not vim.g.scnvim_floating_args_full then
              args_string = string.match(result, "*(.*)") -- remove classname
              args_string = string.match(args_string, " (.*)") -- remove method
              -- NOTE: @salkin-mada
              -- %bxy	matches substring between two distinct characters (balanced pair of x and y)
              -- could be used instead of the two following lines?
              args_string = string.gsub(args_string, "%(", "") -- only get what's inside (..)
              args_string = string.gsub(args_string, "%)", "")
              len = string.len(args_string)
            else
              args_string = result
              len = string.len(result)
            end

            -- dont use callback inner if result len is empty
            if len > 0 then
              local w = len
              local h = 1
              local max_width = vim.g.scnvim_floating_args_max_width or 40
              -- TODO: @salkin-mada -> add minimum width check, could be 10
	            local win_width = vim.api.nvim_get_option("columns")

              if win_width < max_width then
                max_width = win_width
              end

              -- local linebreak_on = vim.g.scnvim_floating_args_linebreak
              if vim.g.scnvim_floating_args_linebreak ~= false then
                  vim.g.scnvim_floating_args_linebreak = true
              end
              if w > max_width then
                if vim.g.scnvim_floating_args_linebreak then
                  w = max_width
                  local worker_string = args_string
                  local chars_in_line = 0
                  -- often used sc args value chars that can break a line: %s, %. and -
                  -- general vim-o-breakat -> " ^I!@*-+;:,./?"
                  -- here only taking %s, %. and - into account
                  -- prob. some very nice and tighty way of doing this... here is the long and messy
                  local splitted = {}
                  local space_split = string.split(worker_string,"%s+")
                  for k, v in pairs(space_split) do
                    punkt_split = string.split(v,"%.+")
                    if #punkt_split > 1 then
                      for k, v in pairs(punkt_split) do
                        minus_split = string.split(v,"-+")
                        if #minus_split > 1 then
                          for k, v in pairs(minus_split) do
                            if k ~= #minus_split then
                              table.insert(splitted, v.."-")
                            else
                              table.insert(splitted, v..".")
                            end
                          end
                        else
                          if k ~= #punkt_split then
                            table.insert(splitted, v..".")
                          else
                            table.insert(splitted, v.." ")
                          end
                        end
                      end
                    else
                      minus_split = string.split(v,"-+")
                      if #minus_split > 1 then
                          for k, v in pairs(minus_split) do
                              if k ~= #minus_split then
                                  table.insert(splitted, v.."-")
                              else
                                  if v ~= #space_split then
                                  table.insert(splitted, v.." ")
                                  end
                              end
                          end
                      else
                      table.insert(splitted, v.." ")
                      end
                    end
                  end

                  local first_line = true
                  -- local max_encountered_line_len = 0
                  local showbreak_size = 0 --[[
                                    showbreak char(s) does not occupy the first window line
                                    init to zero (pre first line break)
                                           --]]

                  for k, v in pairs(splitted) do
                    local element_len

                    if k ~= #splitted then
                      element_len = string.len(v)
                    else
                      element_len = string.len(string.gsub(v, "%s", "")) -- remove end space on last element
                    end

                    if not first_line then
                      --[[
                      get the showbreak size if any.
                      showbreak_size = string.len(vim.o.showbreak or '')
                      count the char not the bytes (string.len will not work, maybe showbreak contains ↳ or similar)
                      NOTE: @salkin-mada ->
                      print(utf8.len("wtf_↳↳↳")) -- not working here ??? why is the utf8 module not in LuaJIT
                      Here follows a pure LuaJIT routine. which should be moved out of the for loop..
                      ]]--
                      local ffi = require("ffi")
                      local bit = require("bit")
                      local UTF8_ACCEPT = 0
                      local UTF8_REJECT = 12

                      local utf8d = ffi.new("const uint8_t[364]", {
                        -- https://bjoern.hoehrmann.de/utf-8/decoder/dfa/
                        -- The first part of the table maps bytes to character classes that
                        -- to reduce the size of the transition table and create bitmasks.
                         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                         1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,
                         7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,  7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
                         8,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,  2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
                        10,3,3,3,3,3,3,3,3,3,3,3,3,4,3,3, 11,6,6,6,5,8,8,8,8,8,8,8,8,8,8,8,

                        -- The second part is a transition table that maps a combination
                        -- of a state of the automaton and a character class to a state.
                         0,12,24,36,60,96,84,12,12,12,48,72, 12,12,12,12,12,12,12,12,12,12,12,12,
                        12, 0,12,12,12,12,12, 0,12, 0,12,12, 12,24,12,12,12,12,12,24,12,24,12,12,
                        12,12,12,12,12,12,12,24,12,12,12,12, 12,24,12,12,12,12,12,12,12,24,12,12,
                        12,12,12,12,12,12,12,36,12,36,12,12, 12,36,12,12,12,12,12,36,12,36,12,12,
                        12,36,12,12,12,12,12,12,12,12,12,12,
                      });

                      function decode_utf8_byte(state, codep, byte)
                        local ctype = utf8d[byte];
                        if (state ~= UTF8_ACCEPT) then
                          codep = bit.bor(bit.band(byte, 0x3f), bit.lshift(codep, 6))
                        else
                          codep = bit.band(bit.rshift(0xff, ctype), byte);
                        end
                        state = utf8d[256 + state + ctype];
                        return state, codep;
                      end

                      function utf8_str_iter(utf8string, len)
                        len = len or #utf8string
                        local state = UTF8_ACCEPT
                        local codep =0;
                        local offset = 0;
                        local ptr = ffi.cast("uint8_t *", utf8string)
                        local bufflen = len;

                        return function()
                          while offset < bufflen do
                            state, codep = decode_utf8_byte(state, codep, ptr[offset])
                            offset = offset + 1
                            if state == UTF8_ACCEPT then
                              return codep
                            elseif state == UTF8_REJECT then
                              return nil, state
                            end
                          end
                          return nil, state;
                        end
                      end

                      function utf8_str_len(utf8string, len)
                        local count = 0;
                        for codepoint, err in utf8_str_iter(utf8string,len) do
                          count = count + 1
                        end
                        return count
                      end

                      showbreak_size = utf8_str_len(vim.o.showbreak or '')

                      -- utf8 mayhem end
                    end

                    chars_in_line = chars_in_line + element_len

                    if chars_in_line >= max_width then -- notice the =
                      chars_in_line = chars_in_line + showbreak_size
                      -- if (chars_in_line-element_len) > max_encountered_line_len then
                      --   max_encountered_line_len = (chars_in_line-element_len)
                      -- end
                      h = h + 1
                      first_line = false
                      chars_in_line = element_len + showbreak_size -- use last element for next iteration
                    end
                  end
                  -- print("highest encountered line char count ->"..max_encountered_line_len)
                else
                  -- no linebreak
                  h = math.ceil((w+((w/max_width)*showbreak_size)-showbreak_size)/max_width)
                  w = max_width
                end
              end

	            local bufnr = vim.api.nvim_create_buf(true, true)
	            vim.api.nvim_buf_set_name(bufnr, name .. current_buffer)
	            vim.bo[bufnr].buftype = 'nowrite'
		          vim.api.nvim_buf_set_option(bufnr, 'filetype', "scnvim-floating-args")
	            vim.bo[bufnr].buflisted = false
              win_handle = vim.api.nvim_open_win(bufnr, false, {relative='cursor', row=1, col=0, width=w, height=h, style='minimal'})
              -- win_num = vim.api.nvim_win_get_number(win_handle) -- get the window # if ever needed
              vim.wo[win_handle].breakindentopt = '' -- remove any breakindentopt for this window
              vim.wo[win_handle].linebreak = vim.g.scnvim_floating_args_linebreak
              -- NOTE: @salkin-mada -> showbreak is not a window option???
              -- vim.wo[win_handle].showbreak = '' -- fails, invalid option..
              -- if it did work though life would be so much easier. no need for showbreak string len utf8 encoded mayhem
              -- NOTE: @salkin-mada -> nvim_buf_set_text() ..
              vim.cmd(string.format('silent call setbufline(%i, 1, "%s")', bufnr, args_string))
              -- add arguments and default values to "s for convenience
              if vim.g.scnvim_floating_args_register then
                -- TODO: @salkin-mada -> check that assigned register is usable ie. a-z lowercase
                vim.cmd(string.format('let @%s = "%s"', vim.g.scnvim_floating_args_register, args_string))
                -- NOTE: @salkin-mada -> other approach (always on, defaults to @s)
                -- vim.cmd(string.format('let @%s = "%s"', vim.g.scnvim_floating_args_register or "s", args_string))
              end
            end
          end
        end
      end
      input = string.gsub(input, "%\"", "") -- remove double quotes from nvim input
      -- escape bonanza (escaping the lua escape for escaping the escape of " in sclang .. escape)
      require'scnvim'.eval(
        string.format(
        "try{"
        .."var input = \\\"%s\\\";"
        .."var args=Help.methodArgs(input);"
        .."args=args.split(Char.nl);"
        .."if(args.size > 1){\\\"SCNvim:: method used by many classes -> not able to parse, sorry\\\".postln};"
        .."if(args.size==1){args[0]}{\\\"\\\"};"
        .."}", input),
      callback
      )
    end
  end
end

return M
