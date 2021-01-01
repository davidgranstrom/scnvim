package.path = package.path .. ';./.deps/env/share/lua/5.1/?.lua'
package.path = package.path .. ';./.deps/env/share/lua/5.1/?/init.lua'
package.cpath = package.cpath .. ';./.deps/env/lib/lua/5.1/?.so'
package.cpath = package.cpath .. ';./.deps/env/lib/lua/5.1/loadall.so'

return {
  output = 'plainTerminal'
  -- output = 'tap'
}

