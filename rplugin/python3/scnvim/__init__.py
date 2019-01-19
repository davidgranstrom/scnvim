import pynvim
import socket

ADDR = '127.0.0.1' # loopback
PORT = 9670

@pynvim.plugin
class SCNvim(object):
    def __init__(self, nvim):
        self.nvim = nvim

    @pynvim.function('__scnvim_server_start')
    def server_start(self, args):
        self.server = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
        self.server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server.bind((ADDR, PORT))
        self.nvim.command('echo "Server started"')
        while(True):
            data, addr = self.server.recvfrom(1024)
            self.nvim.command('echo ' + data.decode('utf-8'))


    @pynvim.function('__scnvim_current_dir', sync=True)
    def get_current_dir(self, args):
        return self.nvim.eval('expand("%:p")')
