SCNVim {
    classvar <listenAdress;
    classvar <nvr;

    var nvrSend, nvrReceive;
    var cmdType;

    *initClass {
        listenAdress = "/tmp/scvim-socket";
        // nvr = "$NVIM_LISTEN_ADRESS=% nvr".format(listenAdress);
        nvr = "nvr -s";
    }

    *new {
        ^super.new.init;
    }

    *currentPath {
        var cmd = "expand(\"%:p\")";
        var path = "% --remote-expr '%'".format(nvr, cmd).unixCmdGetStdOut;
        if (PathName(path).isAbsolutePath) {
            ^path;
        }
        ^nil;
    }

    init {
        nvrSend = {|cmd|
            var cmdString = "% --remote-send %".format(nvr, cmd.quote);
            cmdString.unixCmd(postOutput: false);
        };

        nvrReceive = {|cmd|
            var cmdString = "% --remote-expr %".format(nvr, cmd.quote);
            cmdString.unixCmdGetStdOut;
        };

        cmdType = (
            echo: {|str| ":echom '%'<cr>".format(str) },
        );

        this.send("sc.nvim adapter connected!");
    }

    send {|cmd, type=\echo|
        var message = cmdType[type].(cmd);
        nvrSend.(message);
    }

    receive {|cmd|
        ^nvrReceive.(cmd);
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
