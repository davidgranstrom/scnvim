# scnvim unit tests

## Requirements

* python/pip

## Running the test suite

1. Install deps

This will install a local copy of lua 5.1 and luarocks.

```
pip3 install git+https://github.com/luarocks/hererocks
hererocks .deps/env --lua 5.1.5 --luarocks latest
source .deps/env/bin/activate
luarocks install busted
source .deps/env/bin/activate
```

# Run

```shell
nvim --headless -u vim/init.vim -c "lua require'init'"
```
