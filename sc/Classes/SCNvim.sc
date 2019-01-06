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
        var message = cmd.quote.interpret;
        SCNvim.send(message, type);
    }

    // borrowed from SCVim.sc
    // GPLv3 license
    *generateTags {arg outputPath;
        var tagPath, tagFile;
        var tags = [];

        tagPath = outputPath ? "~/.sctags";
        tagPath = tagPath.standardizePath;

        tagFile = File.open(tagPath, "w");

        tagFile.write('!_TAG_FILE_FORMAT	2	/extended format; --format=1 will not append ;" to lines/'.asString ++ Char.nl);
        tagFile.write("!_TAG_FILE_SORTED	1	/0=unsorted, 1=sorted, 2=foldcase/" ++ Char.nl);
        tagFile.write("!_TAG_PROGRAM_AUTHOR Stephen Lumenta /stephen.lumenta@gmail.com/" ++ Char.nl);
        tagFile.write("!_TAG_PROGRAM_AUTHOR David Granström /info@davidgranstrom.com/" ++ Char.nl);
        tagFile.write("!_TAG_PROGRAM_NAME   SCNVim.sc//" ++ Char.nl);
        tagFile.write("!_TAG_PROGRAM_URL	https://github.com/davidgranstrom/scnvim" ++ Char.nl);
        tagFile.write("!_TAG_PROGRAM_VERSION	2.0//" ++ Char.nl);

        Class.allClasses.do {arg klass;
            var klassName, klassFilename, klassSearchString;
            var result;

            klassName = klass.asString;
            klassFilename = klass.filenameSymbol;
            // use a symbol and convert to string to avoid the "open ended
            // string" error on class lib compiliation
            klassSearchString = '/^%/;"%%'.asString.format(klassName, Char.tab, "c");

            result = klassName ++ Char.tab ++ klassFilename ++ Char.tab ++ klassSearchString ++ Char.nl;
            tags = tags.add(result);

            klass.methods.do {arg meth;
                var methName, methFilename, methSearchString;
                methName = meth.name;
                methFilename = meth.filenameSymbol;
                methSearchString = '/% {/;"%%'.asString.format(methName, Char.tab, "m");
                result = methName ++ Char.tab ++ methFilename ++ Char.tab ++ methSearchString ++ Char.nl;
                tags = tags.add(result);
            }
        };

        tags = tags.sort;
        tagFile.putAll(tags);
        tagFile.close;
        "Generated tags file: %".format(tagPath).postln;
    }

    *generateSnippets {arg outputPath;
        var file, path;
        var snippets = [];

        path = outputPath ? "~/.scsnippets";
        path = path.standardizePath;
        file = File.open(path, "w");

        Class.allClasses.do {arg klass;
            var className, argList, signature;
            if (klass.asString.beginsWith("Meta_").not) {
                // collect all creation methods
                klass.class.methods.do {arg meth;
                    var index, snippet;
                    var snippetName;
                    // classvars with getter/setters produces an error
                    // since we're only interested in creation methods we skip them
                    try {
                        snippetName = "%.%".format(klass, meth.name);
                        signature = Help.methodArgs(snippetName);
                    };

                    if (signature.notNil and:{signature.isEmpty.not}) {
                        index = signature.find("(");
                        className = signature[..index - 1];
                        className = className.replace("*", ".").replace(" ", "");

                        argList = signature[index..];
                        argList = argList.replace("(", "").replace(")", "");
                        argList = argList.split($,);
                        argList = argList.collect {|a, i| "${%:%}".format(i+1, a) };
                        argList = "(" ++ argList.join(", ") ++ ")";

                        snippet = className ++ argList;
                        snippet = "snippet %\n%\nendsnippet\n".format(snippetName, snippet);
                        snippets = snippets.add(snippet ++ Char.nl);
                    };
                };
            };
        };

        file.write("# SuperCollider snippets" ++ Char.nl);
        file.write("# Snippet generator: SCNvim.sc\n" ++ Char.nl);
        file.putAll(snippets);
        file.close;
        "Generated snippets file: %".format(path).postln;
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
