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

    *openHelpFor {|text, pattern, renderPrg, renderArgs|
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
            // convert to plain text
            (renderPrg ++ " " ++ renderArgs).format(path.escapeChar($ ), outputPath.escapeChar($ )).unixCmdGetStdOut;
            msg = (action: "help_open_file", args: (uri: outputPath, pattern: pattern));
        } {
            // search for method
            msg = (action: "help_find_method", args: (method_name: uri.asString, helpTargetDir: SCDoc.helpTargetDir));
        };

        SCNvim.sendJSON(msg);
    }

    *renderMethod {|uri, pattern, renderPrg, renderArgs|
        var name = PathName(uri).fileNameWithoutExtension;
        SCNvim.openHelpFor(name, pattern, renderPrg, renderArgs);
    }

    *createIntrospection {|path|
        var file, size;
        var res = [];
        Class.allClasses.do { |class|
            var classData;
            classData = [
                class.name.asString,
                class.class.name.asString,
                class.superclass !? {class.superclass.name.asString},
                class.filenameSymbol.asString,
                class.charPos,
                class.methods.collect { |m| SCNvim.serializeMethodDetailed(m) };
            ];
            res = res.add(classData);
        };
        size = res.size;
        file = File.open(path, "w");
        file.write("[");
        res.do {|item, i|
            item = item.collect {|x| if (x.isNil) { [] } { x } };
            file.write(item.cs);
            if (i < (size - 1)) {
                file.write(",");
            }
        };
        file.write("]");
        file.close;
    }

    *serializeMethodDetailed { arg method;
        var args, data;
        args = [];
        if (method.argNames.size > 1) {
            args = args ++ [
                method.argNames.as(Array).collect(_.asString),
                method.prototypeFrame.collect { |val|
                    val !? {
                        if (val.class === Float) { val.asString } { val.cs }
                    }
                };
            ].lace [2..];
        };
        args = args.collect {|a|
            if (a.notNil) { a } { [] }
        };
        data = [
            method.ownerClass.name.asString,
            method.name.asString,
            method.filenameSymbol.asString,
            method.charPos,
            args
        ];
        ^data;
    }
}
