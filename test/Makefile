all: deps
	nvim --headless --noplugin -u test_init.vim -c "PlenaryBustedDirectory spec { minimal_init = './test_init.vim' }"

deps:
	mkdir -p .deps/pack/ci/opt
	[ ! -d .deps/pack/ci/opt/plenary.nvim ] && git clone --depth 1 https://github.com/nvim-lua/plenary.nvim.git .deps/pack/ci/opt/plenary.nvim ; true

.PHONY: deps unit_tests
