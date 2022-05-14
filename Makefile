source = lua ftdetect

all: stylua luacheck

format:
	stylua --verify $(source)

luacheck:
	luacheck $(source)

stylua:
	stylua --color always --check $(source)

doc:
	ldoc lua -c .ldoc .

.PHONY: luacheck stylua doc
