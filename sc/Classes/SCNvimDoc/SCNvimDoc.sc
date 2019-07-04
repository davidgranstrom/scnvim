SCNvimDoc : SCDoc {
	*exportDocMapJson {|path|
        var f, numItems;
        f = File.open(path,"w");
        numItems = this.documents.size - 1;
        f << "{\n";
        this.documents.do {|doc, i|
            doc.toJSON(f, i >= numItems);
        };
        f << "}\n";
        f.close;
    }

	*parseFileMetaData {|dir,path|
		var fullPath = dir +/+ path;
		var subpath = path.drop(-7);
		var entry, x = this.prParseFile(fullPath, 2);
		if(x.isNil) {^nil};
		entry = SCNvimDocEntry(x, subpath);
		entry.isExtension = (dir != this.helpSourceDir);
		entry.fullPath = fullPath;
		entry.mtime = File.mtime(fullPath);

		if(dir.beginsWith(Platform.userExtensionDir +/+ "quarks")) {
			entry.categories = entry.categories ++ ["Quarks>"++dir.dirname.basename];
		};

		^entry;
	}

 	*indexAllDocuments { |clearCache=false|
		var now = Main.elapsedTime;
		var key, doc;
		var nonHelpFiles;
		var undocClasses = Class.allClasses.reject(_.isMetaClass).collectAs({|c|c.name},IdentitySet);
		var additions = Dictionary();
		this.checkVersion(clearCache);
		this.postMsg("Indexing help-files...",0);
		documents = Dictionary(); // or use IdDict and symbols as keys?
		helpSourceDirs = nil; // force re-scan of HelpSource folders
		this.helpSourceDirs.do {|dir|
			PathName(dir).filesDo {|f|
				case
				{f.fullPath.endsWith(".ext.schelp")} {
					f = f.fullPath;
					key = f[dir.size+1 ..].drop(-11).replace("\\","/");
					additions[key] = additions[key].add(f);
				}
				{f.extension=="schelp"} {
					doc = this.parseFileMetaData(dir, f.fullPath.drop(dir.size+1));
					doc !? {
						documents[doc.path] = doc;
						if(doc.isClassDoc) {
							undocClasses.remove(doc.title.asSymbol);
						}
					}
				}
				{
					f = f.fullPath;
					nonHelpFiles = nonHelpFiles.add([f,f.drop(dir.size+1)]);
				};
			}
		};
		this.postMsg("Handling"+additions.size+"document additions...",1);
		additions.pairsDo {|key, val|
			doc = documents[key];
			if(doc.notNil) {
				doc.setAdditions(val);
			} {
				warn("SCDoc: Additions % for non-existent help file".format(val));
			}
		};
		this.postMsg("Indexing undocumented methods...",1);
		documents.do {|d|
			if(d.isClassDoc) { d.indexUndocumentedMethods };
		};
		this.postMsg("Adding entries for"+undocClasses.size+"undocumented classes...",1);
		undocClasses.do {|x|
			doc = SCNvimDocEntry.newUndocClass(x);
			documents[doc.path] = doc;
		};
		this.postMsg("Copying"+nonHelpFiles.size+"non-help files...",1);
		nonHelpFiles.do {|x|
			var dest = SCDoc.helpTargetDir+/+x[1];
			var folder = dest.dirname;
			File.mkdir(folder);
			if(File.exists(dest).not or: {File.mtime(x[0]) > File.mtime(dest)}) {
				File.delete(dest);
				File.copy(x[0],dest);
			};
		};
		if(Help.respondsTo('tree')) {
			this.postMsg("Indexing old helpfiles...");
			this.indexOldHelp;
		};
		this.postMsg("Exporting docmap.js...",1);
		this.exportDocMapJson(this.helpTargetDir +/+ "docmap.json");
		this.postMsg("Indexed % documents in % seconds".format(documents.size,round(Main.elapsedTime-now,0.01)),0);
		NotificationCenter.notify(SCDoc, \didIndexAllDocs);
	}

	*findHelpFile {|str|
		var old, sym, pfx = SCDoc.helpTargetUrl;

		if(str.isNil or: {str.isEmpty}) { ^pfx ++ "/Help.txt" };
		if(this.documents[str].notNil) { ^pfx ++ "/" ++ str ++ ".html.scnvim" };

		sym = str.asSymbol;
		if(sym.asClass.notNil) {
			^pfx ++ (if(this.documents["Classes/"++str].isUndocumentedClass) {
				(old = if(Help.respondsTo('findHelpFile'),{Help.findHelpFile(str)})) !? {
					"/OldHelpWrapper.html#"++old++"?"++SCDoc.helpTargetUrl ++ "/Classes/" ++ str ++ ".html.scnvim"
				}
			} ?? { "/Classes/" ++ str ++ ".html.scnvim" });
		};

		if(str.last == $_) { str = str.drop(-1) };
        ^str;
	}

    *prepareHelpForURL {|url|
        var path, targetBasePath, pathIsCaseInsensitive;
        var subtarget, src, c, cmd, doc, destExist, destMtime;
        var verpath = this.helpTargetDir +/+ "version";
        path = url.asLocalPath;

        // detect old helpfiles and wrap them in OldHelpWrapper
        if(url.scheme == "sc") { ^URI(SCNvimDoc.findHelpFile(path)); };

        // just pass through remote url's
        if(url.scheme != "file") {^url};

        targetBasePath = SCDoc.helpTargetDir;
        if (thisProcess.platform.name === \windows)
        { targetBasePath = targetBasePath.replace("/","\\") };
        pathIsCaseInsensitive = thisProcess.platform.name === \windows;

        // detect old helpfiles and wrap them in OldHelpWrapper
        if(
            /*
            // this didn't work for quarks due to difference between registered old help path and the quarks symlink in Extensions.
            // we could use File.realpath(path) below but that would double the execution time,
            // so let's just assume any local file outside helpTargetDir is an old helpfile.
            block{|break|
                Help.do {|key, path|
                    if(url.endsWith(path)) {
                        break.value(true)
                    }
                }; false
            }*/
            compare(
                path [..(targetBasePath.size-1)],
                targetBasePath,
                pathIsCaseInsensitive
            ) != 0
        ) {
            ^SCDoc.getOldWrapUrl(url)
        };

        if(destExist = File.exists(path))
        {
            destMtime = File.mtime(path);
        };

        if(path.endsWith(".html.scnvim")) {
            subtarget = path.drop(this.helpTargetDir.size+1).drop(-12).replace("\\","/");
            doc = this.documents[subtarget];
            doc !? {
                if(doc.isUndocumentedClass) {
                    if(doc.mtime == 0) {
                        this.renderUndocClass(doc);
                        doc.mtime = 1;
                    };
                    ^url;
                };
                if(File.mtime(doc.fullPath)>doc.mtime) { // src changed after indexing
                    this.postMsg("% changed, re-indexing documents".format(doc.path),2);
                    this.indexAllDocuments;
                    ^this.prepareHelpForURL(url);
                };
                if(destExist.not
                    or: {doc.mtime>destMtime}
                    or: {doc.additions.detect {|f| File.mtime(f)>destMtime}.notNil}
                    or: {File.mtime(this.helpTargetDir +/+ "scdoc_version")>destMtime}
                    or: {doc.klass.notNil and: {File.mtime(doc.klass.filenameSymbol.asString)>destMtime}}
                ) {
                    this.parseAndRender(doc);
                };
                ^url;
            };
        };

        if(destExist) {
            ^url;
        };

        warn("SCDoc: Broken link:" + url.asString);
        ^nil;
    }

}

SCNvimDocEntry : SCDocEntry {
	destPath {
        ^SCDoc.helpTargetDir +/+ path ++ ".html.scnvim";
	}

	makeMethodList {
		var list;
		docimethods.do {|name|
			list = list.add("-"++name.asString);
		};
		doccmethods.do {|name|
			list = list.add("*"++name.asString);
		};
		undocimethods.do {|name|
			list = list.add("?-"++name.asString);
		};
		undoccmethods.do {|name|
			list = list.add("?*"++name.asString);
		};
		docmethods.do {|name|
			list = list.add("."++name.asString);
		};
		^list;
	}

	// overriden to output valid json
	prJSONString {|stream, key, x|
		if (x.isNil) { x = "" };
		stream << "\"" << key << "\": \"" << x.escapeChar(34.asAscii) << "\",\n";
	}

	// overriden to output valid json
	prJSONList {|stream, key, v, lastItem|
		var delimiter = if(lastItem.notNil and:{lastItem}, "", ",");
		if (v.isNil) { v = "" };
		stream << "\"" << key << "\": [ " << v.collect{|x|"\""++x.escapeChar(34.asAscii)++"\""}.join(",") << " ]%\n".format(delimiter);
	}

	toJSON {|stream, lastItem|
		var delimiter = if(lastItem.notNil and:{lastItem}, "", ",");
		var inheritance = [];
		var numItems;

		stream << "\"" << path.escapeChar(34.asAscii) << "\": {\n";

		this.prJSONString(stream, "title", title);
		this.prJSONString(stream, "path", path);
		this.prJSONString(stream, "summary", summary);
		this.prJSONString(stream, "installed", if(isExtension,"extension","standard")); //FIXME: also 'missing'.. better to have separate extension and missing booleans..
		this.prJSONString(stream, "categories", if(categories.notNil) {categories.join(", ")} {""}); // FIXME: export list instead
		this.prJSONList(stream, "keywords", keywords);
		this.prJSONList(stream, "related", related);

		this.prJSONList(stream, "methods", this.makeMethodList, klass.isNil);

		if (oldHelp.notNil) {
			this.prJSONString(stream, "oldhelp", oldHelp);
		};

		if (klass.notNil) {
			var keys = #[ "superclasses", "subclasses", "implementor" ];
			klass.superclasses !? {
				inheritance = inheritance.add(klass.superclasses.collect {|c|
					c.name.asString
				});
			};
			klass.subclasses !? {
				inheritance = inheritance.add(klass.subclasses.collect {|c|
					c.name.asString
				});
			};
			implKlass !? {
				inheritance = inheritance.add(implKlass.name.asString);
			};

			numItems = inheritance.size - 1;
			inheritance.do {|item, i|
				this.prJSONList(stream, keys[i], item, i >= numItems);
			};
		};

		stream << "}%\n".format(delimiter);
	}
}
