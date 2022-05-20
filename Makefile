source = lua ftdetect test/spec

all: stylua luacheck

format:
	stylua --verify $(source)

luacheck:
	luacheck $(source)

stylua:
	stylua --color always --check $(source)

doc:
	ldoc lua -c .ldoc .

test:
	make --directory test

unit_tests:
	make --directory test automated

.PHONY: luacheck stylua doc test
