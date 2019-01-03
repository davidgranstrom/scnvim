SCNvim {
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
        SCNvim.send(message, type);
    }

    // borrowed from SCVim.sc
    // GPLv3 license
    *generateTags {
        var tagPath, tagFile;
        var tags = [];

        tagPath = "SCVIM_TAGFILE".getenv ? "~/.sctags";
        tagPath = tagPath.standardizePath;

        tagFile = File.open(tagPath, "w");

        tagFile.write('!_TAG_FILE_FORMAT	2	/extended format; --format=1 will not append ;" to lines/'.asString ++ Char.nl);
        tagFile.write("!_TAG_FILE_SORTED	1	/0=unsorted, 1=sorted, 2=foldcase/" ++ Char.nl);
        tagFile.write("!_TAG_PROGRAM_AUTHOR	David Granström /info@davidgranstrom.com/" ++ Char.nl);
        tagFile.write("!_TAG_PROGRAM_NAME	SCNvim.sc//" ++ Char.nl);
        tagFile.write("!_TAG_PROGRAM_URL	https://github.com/davidgranstrom/scnvim" ++ Char.nl);
        tagFile.write("!_TAG_PROGRAM_VERSION	1.0//" ++ Char.nl);

        Class.allClasses.do {arg klass;
            var klassName, klassFilename, klassSearchString;
            var result;

            klassName = klass.asString;
            klassFilename = klass.filenameSymbol;
            // use a symbol and convert to string to avoid the "open ended
            // string" error on class lib compiliation
            klassSearchString = '/^%/;"%'.asString.format(klassName, "c");

            result = klassName ++ Char.tab ++ klassFilename ++ Char.tab ++ klassSearchString ++ Char.nl;
            tags = tags.add(result);

            klass.methods.do {arg meth;
                var methName, methFilename, methSearchString;
                methName = meth.name;
                methFilename = meth.filenameSymbol;
                methSearchString = '/^%/;"%'.asString.format(klassName, "m");
                result = methName ++ Char.tab ++ methFilename ++ Char.tab ++ methSearchString ++ Char.nl;
                tags = tags.add(result);
            }
        };

        tags = tags.sort;
        tagFile.putAll(tags);
        tagFile.close;
        "Generated tags file: %".format(tagPath);
    }
}

Document {
    // needed for thisProcess.nowExecutingPath to work.. see Kernel::interpretCmdLine
    var <path, <dataptr;

    *new {|path, dataptr|
        ^super.newCopyArgs(path, dataptr);
    }

    *current {
        var path = SCNvim.currentPath;
        ^Document(path, true);
    }
}
