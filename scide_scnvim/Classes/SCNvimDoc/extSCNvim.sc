+ SCNvim {
    // copy of `Help.methodArgs` with an additional bugfix
    // remove this later if merged upstream
    *getMethodArgs {|string|
        var class, meth, f, m;
        f = string.findRegexp("(\\w*)\\.(\\w+)").flop[1];
        if(f.notNil) {#class, meth = f[1..]} {
            if(string[0].isUpper) {
                class = string;
                meth = \new;
            } {
                meth = string;
            }
        };
        f = {|m,c|
            class = (c ?? {m.ownerClass}).name;
            class = if(class.isMetaClassName) {class.asString[5..]++" *"} {class.asString++" -"};
            if (m.argNames.notNil) { // argNames can be nil in rare cases such as `Done.freeSelf`
                class++m.name++" ("++m.argNames[1..].collect {|n,i|
                    n.asString++":"+m.prototypeFrame[i+1];
                }.join(", ")++")";
            } { "" }
        };
        class = class.asSymbol.asClass;
        if(class.notNil) {
            m = class.class.findRespondingMethodFor(meth.asSymbol);
            ^if(m.notNil) {f.value(m,class.class)} {""};
        } {
            ^Class.allClasses.reject{|c|c.isMetaClass}.collect {|c|
                c.findMethod(meth.asSymbol);
            }.reject{|m|m.isNil}.collect {|m|
                f.value(m);
            }.join($\n);
        }
    }

    // This function will be replaced by LSP in the future
    *methodArgs {|method|
        var args = this.getMethodArgs(method);
        args = args.split(Char.nl);
        if (args.size == 1) {
            ^args[0]
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
