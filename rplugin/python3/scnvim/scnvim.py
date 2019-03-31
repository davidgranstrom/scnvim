"""
Main module.
"""
import socket
import json
from threading import Thread

import pynvim
from scnvim.help import SCNvimHelp
from scnvim.message import SCNvimMessage

@pynvim.plugin
class SCNvim():
    """
    SCNvim remote plugin server.
    """
    def __init__(self, nvim):
        self.nvim = nvim
        self.help_system = SCNvimHelp(nvim)
        self.msg = SCNvimMessage(nvim)
        self.server = None
        self.vim_leaving = False
        self.server_started = False
        self.port = 0

    def stl_update(self, obj):
        """Update the statusline"""
        try:
            json_str = json.dumps(obj)
            self.nvim.call('scnvim#statusline#update', json_str)
        except BaseException as err:
            self.msg.echo_err(str(err))

    def dispatch(self, obj):
        """Dispatch incoming actions"""
        data = obj.get('help')
        if not data:
            return
        uri = data.get('uri')
        pattern = data.get('pattern', '')
        method = data.get('method')
        if method:
            target_dir = data.get('helpTargetDir')
            self.help_system.handle_method(method, target_dir)
        if uri:
            self.help_system.open(uri, pattern)

    def server_loop(self):
        """Main server loop"""
        while not self.vim_leaving:
            data, _ = self.server.recvfrom(1024)
            data = data.decode('utf-8')
            try:
                data = json.loads(data)
                status_line = data.get('status_line')
                method_args = data.get('method_args')
                action = data.get('action')
                if method_args:
                    # self.nvim.async_call(self.msg.echo, method_args)
                    self.nvim.async_call(self.help_system.open_arghints_float, method_args)
                if status_line:
                    self.nvim.async_call(self.stl_update, status_line)
                if action:
                    self.nvim.async_call(self.dispatch, action)
            except BaseException as err:
                self.msg.echo_err('json decode error: ' + str(err))

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
                    self.msg.echo_err('could not open UDP port: ' + str(err))
                    return 0

        self.port = port
        thread = Thread(target=self.server_loop)
        thread.start()
        return port

    @pynvim.autocmd('VimLeavePre', pattern='*', sync=True)
    def on_vim_leave_pre(self):
        """Stop server on vim leave"""
        self.vim_leaving = True
        if self.server:
            self.server.close()
