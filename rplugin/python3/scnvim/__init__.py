from threading import Thread
import json
import pynvim
import socket

PORT = 9670

@pynvim.plugin
class SCNvim(object):
    def __init__(self, nvim):
        self.nvim = nvim
        self.server = None
        self.vim_leaving = False
        self.server_started = False

    def echo(self, message):
        try:
            self.nvim.out_write(message + '\n')
        except BaseException as e:
            self.nvim.err_write('[scnvim]: ' + str(e))

    def echo_err(self, message):
        try:
            self.nvim.err_write(message + '\n')
        except BaseException as e:
            self.nvim.err_write('[scnvim]: ' + str(e))

    def stl_update(self, object):
        try:
            json_str = json.dumps(object)
            self.nvim.call('scnvim#statusline#update', json_str)
        except BaseException as e:
            self.nvim.err_write('[scnvim]: ' + str(e))

    def server_loop(self):
        while not self.vim_leaving:
            data, addr = self.server.recvfrom(1024)
            data = data.decode('utf-8')
            try:
                data = json.loads(data)
                status_line = data.get('status_line', '')
                method_args = data.get('method_args', '')
                if method_args:
                    self.nvim.async_call(self.echo, method_args)
                if status_line:
                    self.nvim.async_call(self.stl_update, status_line)
            except BaseException:
                self.nvim.err_write('[scnvim]: json decode error')

    @pynvim.function('__scnvim_server_start', sync=True)
    def server_start(self, args):
        if self.server:
            return

        self.server = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
        self.server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

        port = PORT
        found_port = False
        max_attempts = 20
        # retry to connect until a port is found
        while not found_port and max_attempts > 0:
            try:
                self.server.bind(('127.0.0.1', port))
                found_port = True
            except BaseException as e:
                port += 1
                max_attempts -= 1

        if max_attempts == 0:
            self.echo_err('[scnvim] UDP server: ' + e.strerror)
            return

        self.thread = Thread(target=self.server_loop)
        self.thread.start()
        return port

    @pynvim.autocmd('VimLeave', pattern='*', sync=True)
    def on_vim_leave(self, args):
        self.vim_leaving = True
        if self.server:
            self.server.shutdown()
            self.server.close()
