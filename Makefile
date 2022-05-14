all: stylua luacheck

format:
	stylua --verify lua ftplugin ftdetect

luacheck:
	luacheck lua ftplugin ftdetect

stylua:
	stylua --check lua ftplugin ftdetect

.PHONY: luacheck stylua
