SCNvim {
    classvar <>netAddr;
    classvar <>currentPath;

    *sendJSON {|object, vimPort|
        if (netAddr.isNil) {
            netAddr = NetAddr("127.0.0.1", vimPort);
        };
        netAddr.sendRaw(object);
    }

    *methodArgs {|method, vimPort|
        var args, message;
        try {
            args = Help.methodArgs(method);
            message = "{\"method_args\":\"%\"}".format(args);
            SCNvim.sendJSON(message, vimPort);
        } {
            ^"[scnvim] Could not find args for %".format(method);
        }
    }

    *updateStatusLine {arg interval=1, vimPort;
        var stlFunc = {
            var serverStatus, levelMeter, data;
            var peakCPU, avgCPU, numUGens, numSynths;
            var server = Server.default;

            if (server.serverRunning) {
                peakCPU = server.peakCPU.trunc(0.01);
                avgCPU = server.avgCPU.trunc(0.01);
                numUGens = "%u".format(server.numUGens);
                numSynths = "%s".format(server.numSynths);

                serverStatus = "%\\% %\\% % %".format(
                    peakCPU, avgCPU, numUGens, numSynths
                );
                levelMeter = "-inf dB";

                serverStatus = "\"server_status\":\"%\"".format(serverStatus);
                levelMeter = "\"level_meter\":\"%\"".format(levelMeter);
                data = "{\"status_line\":{%,%}}".format(serverStatus, levelMeter);
                SCNvim.sendJSON(data, vimPort);
            }
        };

        SkipJack(stlFunc, interval, name: "scnvim_statusline");
    }

    *generateAssets {|rootDir|
        var tagsPath = rootDir +/+ "scnvim-data/tags";
        var syntaxPath = rootDir +/+ "syntax/classes.vim";
        var snippetPath = rootDir +/+ "scnvim-data/supercollider.snippets";
        Routine.run {
            SCNvim.generateTags(tagsPath);
            SCNvim.generateSyntax(syntaxPath);
            SCNvim.generateSnippets(snippetPath);
        };
    }

    *generateSyntax {arg outputPath;
        var path, file, classes;
        classes = Class.allClasses.collect {|class|
            class.asString ++ " ";
        };
        path = outputPath.standardizePath;
        file = File.open(path, "w");
        file.write("syn keyword scObject ");
        file.putAll(classes);
        file.close;
        "Generated syntax file: %".format(path).postln;
    }

    // copied from SCVim.sc
    // modified to produce a sorted tags file
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
