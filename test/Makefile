lint:
	luacheck ../lua --globals vim

deps:
	git clone --depth=1 https://github.com/nvim-lua/plenary.nvim.git lib/plenary.nvim

test:
	nvim --headless -u init.vim -c 'PlenaryBustedDirectory spec'

clean:
	rm -rf lib
