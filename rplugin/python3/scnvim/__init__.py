import pynvim
import socket
import json

ADDR = '127.0.0.1' # loopback
PORT = 9670

@pynvim.plugin
class SCNvim(object):
    def __init__(self, nvim):
        self.nvim = nvim
        self.server_started = False

    def _echo(self, message):
        try:
            self.nvim.command('echo "{}"'.format(message))
        except ValueError as e:
            self.nvim.err_write('[scnvim]: ' + e)

    def _stl_update(self, object):
        try:
            json_str = json.dumps(object)
            # self.nvim.async_call('scnvim#statusline#update', [json_str])
            self.nvim.call('scnvim#statusline#update', json_str)
        except ValueError as e:
            self.nvim.err_write('[scnvim]: ' + e)

    @pynvim.function('__scnvim_server_start', sync=False)
    def server_start(self, args):
        if self.server_started:
            return

        self.server_started = True
        self.server = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
        self.server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server.bind((ADDR, PORT))
        while(True):
            data, addr = self.server.recvfrom(1024)
            data = data.decode('utf-8')
            try:
                data = json.loads(data)
                status_line = data.get('status_line', '')
                method_args = data.get('method_args', '')
                if method_args:
                    self._echo(method_args)
                if status_line:
                    self._stl_update(status_line)
            except ValueError as e:
                self.nvim.err_write('[scnvim]: json decode error')

    @pynvim.function('__scnvim_current_dir', sync=True)
    def get_current_dir(self, args):
        return self.nvim.eval('expand("%:p")')
