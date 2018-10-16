SCNVim {
    classvar <listenAdress;
    classvar <nvr;

    classvar cmdType;

    *initClass {
        listenAdress = "/tmp/scvim-socket";
        nvr = "nvr -s --nostart";
        cmdType = (
            echo: {|str| ":echom '%'<cr>".format(str) },
            print_args: {|str| "<c-o>:echo '%'<cr>".format(str) },
        );
    }

    *currentPath {
        var cmd = "expand(\"%:p\")";
        var path = "% --remote-expr '%'".format(nvr, cmd).unixCmdGetStdOut;
        if (PathName(path).isAbsolutePath) {
            ^path;
        }
        ^nil;
    }

    *send {|message, type=\echo|
        var cmd = cmdType[type].(message);
        var msg = "% --remote-send %".format(nvr, cmd.quote);
        msg.unixCmd(postOutput: false);
    }

    *receive {|cmd|
        var msg = "% --remote-expr %".format(nvr, cmd.quote);
        ^msg.unixCmdGetStdOut;
    }

    *exec {|cmd, type=\print_args|
        var message = cmd.interpret;
        SCNVim.send(message, type);
    }
}

Document {
    // needed for thisProcess.nowExecutingPath to work.. see Kernel::interpretCmdLine
    var <path, <dataptr;

    *new {|path, dataptr|
        ^super.newCopyArgs(path, dataptr);
    }

    *current {
        var path = SCNVim.currentPath;
        ^Document(path, true);
    }
}
