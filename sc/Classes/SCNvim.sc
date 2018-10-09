SCNVim {
    classvar <listenAdress;
    classvar <nvr;

    var cmdType;

    *initClass {
        listenAdress = "/tmp/scvim-socket";
        // nvr = "$NVIM_LISTEN_ADRESS=% nvr".format(listenAdress);
        nvr = "nvr -s --nostart";
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
        cmdType = (
            echo: {|str| ":echom '%'<cr>".format(str) },
        );

        this.send("sc.nvim adapter connected!");
    }

    send {|message, type=\echo|
        var cmd = cmdType[type].(message);
        var msg = "% --remote-send %".format(nvr, cmd.quote);
        msg.unixCmd(postOutput: false);
    }

    receive {|cmd|
        var msg = "% --remote-expr %".format(nvr, cmd.quote);
        ^msg.unixCmdGetStdOut;
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
