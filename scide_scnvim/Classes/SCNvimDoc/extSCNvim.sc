+ SCNvim {
    *methodArgs {|method|
        try {
            var args = Help.methodArgs(method);
            // TODO
            // this is just a quick fix.
            // how should we handle polymorphic methods?
            args = args.split(Char.nl);
            if (args.size == 1) {
                ^args[0]
            }
        }
        ^"";
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

    *getHelpUri {arg subject;
        var uri = SCNvim.prepareHelpFor(subject);
        if (uri.notNil) {
            ^uri.asLocalPath;
        };
        ^nil;
    }

    *getFileNameFromUri {arg uri;
        ^PathName(uri).fileNameWithoutExtension;
    }
}
