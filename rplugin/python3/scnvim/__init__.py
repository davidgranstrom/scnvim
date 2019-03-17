from threading import Thread
import json
import os
import re
import socket

import pynvim

@pynvim.plugin
class SCNvim(object):
    def __init__(self, nvim):
        self.nvim = nvim
        self.server = None
        self.port = 0
        self.vim_leaving = False
        self.server_started = False
        self.docmap = {}
        self.port = 0

    def echo(self, message):
        self.nvim.out_write(message + '\n')

    def echo_err(self, message):
        self.nvim.err_write('[scnvim]: {}'.format(message) + '\n')

    def stl_update(self, object):
        try:
            json_str = json.dumps(object)
            self.nvim.call('scnvim#statusline#update', json_str)
        except BaseException as e:
            self.echo_err(str(e))

    def prepare_doc_map(self, path):
        try:
            if not self.docmap:
                with open(os.path.join(path, 'docmap.json')) as f:
                    self.docmap = json.load(f)
        except BaseException as e:
            self.echo_err('error parsing docmap ' + str(e))

    def handle_method(self, method, target_dir):
        self.prepare_doc_map(target_dir)
        if not self.docmap:
            return
        result = []
        for value in self.docmap.values():
            for k in value.items():
                if k[0] == 'methods':
                    for m in k[1]:
                        match = re.match('.{}'.format(method), m)
                        if match:
                            path = os.path.join(target_dir, value['path'] + '.txt')
                            result.append({
                                'filename': path,
                                'text': match.group(0),
                                'pattern': '^.*' + method
                            })
        if result:
            self.nvim.call('setqflist', result)
            self.nvim.command('copen')
            # self.nvim.win_set_var('let w:quickfix_title="supercollider"')
            self.nvim.command('syntax match SCNvimConcealResults /^.*Help\/\|.txt\||.*|\|/ conceal')
            self.nvim.command('setlocal conceallevel=2')
            self.nvim.command('setlocal concealcursor=nvic')
            self.nvim.command('nnoremap <buffer> <Enter> :call scnvim#help#open_from_quickfix(line("."))<cr>')
        else:
            self.nvim.call('setqflist', [{'text': 'No results for: ' + method}])

    def dispatch(self, object):
        data = object.get('help')
        if not data:
            return
        uri = data.get('open')
        method = data.get('method')
        if method:
            target_dir = data.get('helpTargetDir')
            self.handle_method(method, target_dir)
        if uri:
            self.nvim.call('scnvim#help#open', uri)

    def server_loop(self):
        while not self.vim_leaving:
            data, addr = self.server.recvfrom(1024)
            data = data.decode('utf-8')
            try:
                data = json.loads(data)
                status_line = data.get('status_line')
                method_args = data.get('method_args')
                action = data.get('action')
                if method_args:
                    self.nvim.async_call(self.echo, method_args)
                if status_line:
                    self.nvim.async_call(self.stl_update, status_line)
                if action:
                    self.nvim.async_call(self.dispatch, action)
            except BaseException as e:
                self.echo_err('json decode error: ' + str(e))

    @pynvim.function('__scnvim_server_start', sync=True)
    def server_start(self, args):
        """Main entry point"""
        if self.server:
            return self.port

        self.server = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
        self.server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

        port = args[0]
        max_attempts = 10
        # try to connect until a port is found or max_attempts is reached
        for attempt in range(max_attempts):
            try:
                self.server.bind(('127.0.0.1', port))
                break
            except BaseException as err:
                port += 1
                if attempt == max_attempts - 1:
                    self.echo_err('could not open UDP port: ' + str(err))
                    return 0

        self.port = port
        thread = Thread(target=self.server_loop)
        thread.start()
        return port

    @pynvim.autocmd('VimLeavePre', pattern='*', sync=True)
    def on_vim_leave_pre(self):
        self.vim_leaving = True
        if self.server:
            self.server.close()
