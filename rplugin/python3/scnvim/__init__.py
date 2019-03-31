from threading import Thread
import json
import pynvim
import socket

@pynvim.plugin
class SCNvim(object):
    def __init__(self, nvim):
        self.nvim = nvim
        self.server = None
        self.port = 0
        self.vim_leaving = False
        self.server_started = False

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

    def dispatch(self, object):
        help = object.get('help', '')
        if help:
            uri = help.get('open', '')
            if uri:
                self.nvim.command('split')
                self.nvim.command('edit ' + uri)

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
