"""
Helpers to send messages to nvim.
"""

class SCNvimMessage():
    """Echo messages to nvim"""
    def __init__(self, nvim):
        self.nvim = nvim

    def echo(self, message):
        """echo to command-line area"""
        self.nvim.out_write(message + '\n')

    def echo_err(self, message):
        """echoerr to command-line area"""
        self.nvim.err_write('[scnvim]: {}'.format(message) + '\n')
