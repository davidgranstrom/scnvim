+ SCNvim {
    *methodArgs {|method|
        var args, message;
        try {
            args = Help.methodArgs(method);
            // TODO;
            // this is just a quick fix.
            // how should we handle methods implemented by many classes?
            args = args.split(Char.nl);
            if (args.size == 1) {
                message = (action: "method_args", args: args[0]);
                SCNvim.sendJSON(message);
            }
        } {
            ^"[scnvim] Could not find args for %".format(method);
        }
    }

    *prepareHelpFor {|text|
        var urlString, url, brokenAction;
        var result, tmp;

        tmp = SCDoc.renderer.asClass;
        SCDoc.renderer = SCNvimDocRenderer;

        urlString = SCNvimDoc.findHelpFile(text);
		url = URI(urlString);
        brokenAction = {
            "Sorry no help for %".format(text).postln;
            ^nil;
        };

        result = SCNvimDoc.prepareHelpForURL(url) ?? brokenAction;
        SCDoc.renderer = tmp;
        ^result;
    }

    *openHelpFor {|text, pattern, pandocPath|
        var msg, uri, path;
        var outputPath;

        uri = SCNvim.prepareHelpFor(text);
        if (uri.isNil) {
            ^nil;
        };

        path = uri.asLocalPath;
        // optional regex for placing cursor on a method name
        pattern ?? {
            pattern = "";
        };

        if (path.notNil) {
            // help file
            // removes .html.scnvim
            outputPath = path.drop(-12) ++ ".txt";
            // convert to plain text with pandoc
            "% \"%\" --from html --to plain -o \"%\"".format(pandocPath, path, outputPath).unixCmdGetStdOut;
            msg = (action: "help_open_file", args: (uri: outputPath, pattern: pattern));
        } {
            // search for method
            msg = (action: "help_find_method", args: (method_name: uri.asString, helpTargetDir: SCDoc.helpTargetDir));
        };

        SCNvim.sendJSON(msg);
    }

    *renderMethod {|uri, pattern, pandocPath|
        var name = PathName(uri).fileNameWithoutExtension;
        SCNvim.openHelpFor(name, pattern, pandocPath);
    }
}
