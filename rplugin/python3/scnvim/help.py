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
            self.nvim.command('syntax match SCNvimConcealResults '
                              + r'/^.*Help\/\|.txt\||.*|\|/ conceal')
            self.nvim.command('setlocal conceallevel=2')
            self.nvim.command('setlocal concealcursor=nvic')
            self.nvim.command('nnoremap <silent> <buffer> <Enter> '
                              + ':call scnvim#help#open_from_quickfix(line("."))<cr>')
        else:
            self.nvim.call('setqflist', [{'text': 'No results for: ' + method}])
