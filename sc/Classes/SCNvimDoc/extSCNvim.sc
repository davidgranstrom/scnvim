+ SCNvim {
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

    *openHelpFor {|text, vimPort, pattern, pandocPath|
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

        SCNvim.sendJSON(msg, vimPort);
    }

    *renderMethod {|uri, vimPort, pattern, pandocPath|
        var name = PathName(uri).fileNameWithoutExtension;
        SCNvim.openHelpFor(name, vimPort, pattern, pandocPath);
    }
}
