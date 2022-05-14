source = lua ftdetect

all: stylua luacheck

format:
	stylua --verify $(source)

luacheck:
	luacheck $(source)

stylua:
	stylua --color always --check $(source)

.PHONY: luacheck stylua
