"""
SCNvim help system.
"""
import os
import re
import json

from scnvim.message import SCNvimMessage

class SCNvimHelp():
    """
    SCNvim help system.
    """
    def __init__(self, nvim):
        self.nvim = nvim
        self.docmap = {}
        self.msg = SCNvimMessage(nvim)

    def open(self, uri, pattern):
        """open a vim buffer for uri with an optional regex pattern"""
        self.nvim.call('scnvim#help#open', uri, pattern)

    def prepare_doc_map(self, path):
        """prepare a json document for all (SuperCollider) classes and methods"""
        try:
            if not self.docmap:
                with open(os.path.join(path, 'docmap.json')) as file:
                    self.docmap = json.load(file)
        except BaseException as err:
            self.msg.echo_err('error parsing docmap ' + str(err))

    def handle_method(self, method, target_dir):
        """handle a method query"""
        self.prepare_doc_map(target_dir)
        if not self.docmap:
            return
        result = []
        for value in self.docmap.values():
            for k in value.items():
                if k[0] == 'methods':
                    for meth in k[1]:
                        match = re.match('.{}'.format(method), meth)
                        if match:
                            path = os.path.join(target_dir, value['path'] + '.txt')
                            result.append({
                                'filename': path,
                                'text': match.group(0),
                                'pattern': '^.*{}'.format(method)
                            })
        if result:
            self.nvim.call('setqflist', result)
            self.nvim.command('copen')
            self.nvim.command('nnoremap <silent> <buffer> <Enter> '
                              + ':call scnvim#help#open_from_quickfix(line("."))<cr>')
        else:
            self.msg.echo_err('No results for: ' + method)

    def open_arghints_float(self, method_args):
        """Open a floating window to display argument hints."""
        if not method_args:
            return
        args = method_args
        # extract function args
        args = args[args.find("(") + 1:args.find(")")]
        buf = self.nvim.api.create_buf(False, True)
        self.nvim.api.buf_set_lines(buf, 0, -1, True, [args])
        options = {
            'relative': 'cursor',
            'width': len(args),
            'height': 1,
            'col': 0,
            'row': 0,
            'anchor': 'SW'
        }
        win = self.nvim.api.open_win(buf, 0, options)
        self.nvim.api.set_var('scnvim_arghints_float_id', win)
