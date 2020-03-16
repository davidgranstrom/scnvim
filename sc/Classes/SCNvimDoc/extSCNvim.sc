+ SCNvim {
    *methodArgs {|method|
        var args, message;
        try {
            args = Help.methodArgs(method);
            message = "{\"action\": \"method_args\", \"args\": \"%\"}".format(args);
            SCNvim.sendJSON(message);
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
            "% \"%\" --from html --to plain -o \"%\"".format(pandocPath, path, outputPath).unixCmdGetStdOut;
            msg = "{\"action\":{\"help\":{\"uri\":\"%\",\"pattern\":\"%\"}}}".format(outputPath, pattern);
        } {
            // search for method
            msg = "{\"action\":{\"help\":{\"method\":\"%\",\"helpTargetDir\":\"%\"}}}".format(uri.asString, SCDoc.helpTargetDir);
        };

        SCNvim.sendJSON(msg);
    }

    *renderMethod {|uri, pattern, pandocPath|
        var name = PathName(uri).fileNameWithoutExtension;
        SCNvim.openHelpFor(name, pattern, pandocPath);
    }
}
