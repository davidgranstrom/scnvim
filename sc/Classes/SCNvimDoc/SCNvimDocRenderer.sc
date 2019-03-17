// This class produces html help files but modified with some vim markup. The
// idea is to use `pandoc <help-file>.html -t plain -o <help-file>.txt` in
// order to convert html to vim help on the fly.
//
// TODO:
//
// * See if we can add markup for class methods (this will enable "outline"/gO)
// * Check that html is still valid (html/head/body tags properly closed)
//
SCNvimDocRenderer : SCDocHTMLRenderer {
    *renderTOC {
        ^nil;
    }

	*renderHeader {|stream, doc, body|
		var x, cats, m, z;
		var thisIsTheMainHelpFile;
		var folder = doc.path.dirname;
		var undocumented = false;
		var displayedTitle;
		if(folder==".",{folder=""});

		// FIXME: use SCDoc.helpTargetDir relative to baseDir
		baseDir = ".";
		doc.path.occurrencesOf($/).do {
			baseDir = baseDir ++ "/..";
		};

		thisIsTheMainHelpFile = (doc.title == "Help") and: {
			(folder == "") or:
			{ (thisProcess.platform.name === \windows) and: { folder == "Help" } }
		};

		stream
		<< "<!doctype html>"
		<< "<html lang='en'>"
        << "<head></head>";

        stream << "<div>";
		stream << "*%* ".format(doc.title);
		if(thisIsTheMainHelpFile) {
			stream << "SuperCollider " << Main.version << " Help";
		} {
			stream << "| SuperCollider " << Main.version << " | Help";
		};
        stream << "</div>";

		// stream << "Version: " << Main.version;

		doc.related !? {
            stream << "<div>See also: "
			<< (doc.related.collect {|r| this.htmlForLink(r)}.join(" "))
            << "</div>";
		};

        stream << "<body>";
	}

	*renderFooter {|stream, doc|
		stream << "<div class='doclink'>";
		doc.fullPath !? {
			stream << "helpfile source: <a href='" << URI.fromLocalPath(doc.fullPath).asString << "'>"
			<< doc.fullPath << "</a><br>"
		};
		stream << "link::" << doc.path << "::<br>";
        stream << "</body></html>";
		stream << "\n\n vim:tw=78:et:ft=help.supercollider:norl:\n";
	}

    *renderMethod {|stream, node, methodType, cls, icls|
		var methodTypeIndicator;
		var methodCodePrefix;
		var args = node.text ?? ""; // only outside class/instance methods
		var names = node.children[0].children.collect(_.text);
		var mstat, sym, m, m2, mname2;
		var lastargs, args2;
		var x, maxargs = -1;
		var methArgsMismatch = false;

		methodTypeIndicator = switch(
			methodType,
			\classMethod, { "*" },
			\instanceMethod, { "-" },
			\genericMethod, { "" }
		);

		minArgs = inf;
		currentMethod = nil;
		names.do {|mname|
			methodCodePrefix = switch(
				methodType,
				\classMethod, { if(cls.notNil) { cls.name.asString[5..] } { "" } ++ "." },
				\instanceMethod, {
					// If the method name contains any valid binary operator character, remove the
					// "." to reduce confusion.
					if(mname.asString.any(this.binaryOperatorCharacters.contains(_)), { "" }, { "." })
				},
				\genericMethod, { "" }
			);

			mname2 = this.escapeSpecialChars(mname);
			if(cls.notNil) {
				mstat = 0;
				sym = mname.asSymbol;
				//check for normal method or getter
				m = icls !? {icls.findRespondingMethodFor(sym.asGetter)};
				m = m ?? {cls.findRespondingMethodFor(sym.asGetter)};
				m !? {
					mstat = mstat | 1;
					args = this.makeArgString(m);
					args2 = m.argNames !? {m.argNames[1..]};
				};
				//check for setter
				m2 = icls !? {icls.findRespondingMethodFor(sym.asSetter)};
				m2 = m2 ?? {cls.findRespondingMethodFor(sym.asSetter)};
				m2 !? {
					mstat = mstat | 2;
					args = m2.argNames !? {this.makeArgString(m2,false)} ?? {"value"};
					args2 = m2.argNames !? {m2.argNames[1..]};
				};
				maxargs.do {|i|
					var a = args2 !? args2[i];
					var b = lastargs[i];
					if(a!=b and: {a!=nil} and: {b!=nil}) {
						methArgsMismatch = true;
					}
				};
				lastargs = args2;
				case
					{args2.size>maxargs} {
						maxargs = args2.size;
						currentMethod = m2 ?? m;
					}
					{args2.size<minArgs} {
						minArgs = args2.size;
					};
			} {
				m = nil;
				m2 = nil;
				mstat = 1;
			};

			x = {
				stream << "<h3 class='method-code'>"
				<< "<span class='method-prefix'>" << methodCodePrefix << "</span>"
				<< "<a class='method-name' name='" << methodTypeIndicator << mname << "' href='"
				<< baseDir << "/Overviews/Methods.html#"
				<< mname2 << "'>" << mname2 << "</a>"
			};

			switch (mstat,
				// getter only
				1, { x.value; stream << args; },
				// getter and setter
				3, { x.value; },
				// method not found
				0, {
					"SCDoc: In %\n"
					"  Method %% not found.".format(currDoc.fullPath, methodTypeIndicator, mname2).warn;
					x.value;
					stream << ": METHOD NOT FOUND!";
				}
			);

			stream << "</h3>\n";

			// has setter
			if(mstat & 2 > 0) {
				x.value;
				if(args2.size<2) {
					stream << " = " << args << "</h3>\n";
				} {
					stream << "_(" << args << ")</h3>\n";
				}
			};

			m = m ?? m2;
			m !? {
				if(m.isExtensionOf(cls) and: {icls.isNil or: {m.isExtensionOf(icls)}}) {
					stream << "<div class='extmethod'>From extension in <a href='"
					<< URI.fromLocalPath(m.filenameSymbol.asString).asString << "'>"
					<< m.filenameSymbol << "</a></div>\n";
				} {
					if(m.ownerClass == icls) {
						stream << "<div class='supmethod'>From implementing class</div>\n";
					} {
						if(m.ownerClass != cls) {
							m = m.ownerClass.name;
							m = if(m.isMetaClassName) {m.asString.drop(5)} {m};
							stream << "<div class='supmethod'>From superclass: <a href='"
							<< baseDir << "/Classes/" << m << ".html'>" << m << "</a></div>\n";
						}
					}
				};
			};
		};

		if(methArgsMismatch) {
			"SCDoc: In %\n"
			"  Grouped methods % do not have the same argument signature."
			.format(currDoc.fullPath, names).warn;
		};

		// ignore trailing mul add arguments
		if(currentMethod.notNil) {
			currentNArgs = currentMethod.argNames.size;
			if(currentNArgs > 2
			and: {currentMethod.argNames[currentNArgs-1] == \add}
			and: {currentMethod.argNames[currentNArgs-2] == \mul}) {
				currentNArgs = currentNArgs - 2;
			}
		} {
			currentNArgs = 0;
		};

		if(node.children.size > 1) {
			stream << "<div class='method'>";
			this.renderChildren(stream, node.children[1]);
			stream << "</div>";
		};
		currentMethod = nil;
	}

	*renderSubTree {|stream, node|
		var f, z, img;
		switch(node.id,
			\PROSE, {
				if(noParBreak) {
					noParBreak = false;
				} {
					stream << "\n<p>";
				};
				this.renderChildren(stream, node);
			},
			\NL, { }, // these shouldn't be here..
// Plain text and modal tags
			\TEXT, {
				stream << this.escapeSpecialChars(node.text);
			},
			\LINK, {
				stream << this.htmlForLink(node.text);
			},
			\CODEBLOCK, {
                stream << "<pre><code>"
				<< this.escapeSpecialChars(node.text)
                << "</code></pre>";
			},
			\CODE, {
                stream << "<code>"
				<< this.escapeSpecialChars(node.text)
                << "</code>";
			},
			\EMPHASIS, {
				stream << "<em>" << this.escapeSpecialChars(node.text) << "</em>";
			},
			\TELETYPEBLOCK, {
				stream << "<pre>" << this.escapeSpecialChars(node.text) << "</pre>";
			},
			\TELETYPE, {
				stream << "<code>" << this.escapeSpecialChars(node.text) << "</code>";
			},
			\STRONG, {
				stream << "<strong>" << this.escapeSpecialChars(node.text) << "</strong>";
			},
			\SOFT, {
				stream << "<span class='soft'>" << this.escapeSpecialChars(node.text) << "</span>";
			},
			\ANCHOR, {
				stream << "<a class='anchor' name='" << this.escapeSpacesInAnchor(node.text) << "'>&nbsp;</a>";
			},
			\KEYWORD, {
				node.children.do {|child|
					stream << "<a class='anchor' name='kw_" << this.escapeSpacesInAnchor(child.text) << "'>&nbsp;</a>";
				}
			},
			\IMAGE, {
				f = node.text.split($#);
				stream << "<div class='image'>";
				img = "<img src='" ++ f[0] ++ "'/>";
				if(f[2].isNil) {
					stream << img;
				} {
					stream << this.htmlForLink(f[2]++"#"++(f[3]?"")++"#"++img,false);
				};
				f[1] !? { stream << "<br><b>" << f[1] << "</b>" }; // ugly..
				stream << "</div>\n";
			},
// Other stuff
			\NOTE, {
				stream << "<div class='note'><span class='notelabel'>NOTE:</span> ";
				noParBreak = true;
				this.renderChildren(stream, node);
				stream << "</div>";
			},
			\WARNING, {
				stream << "<div class='warning'><span class='warninglabel'>WARNING:</span> ";
				noParBreak = true;
				this.renderChildren(stream, node);
				stream << "</div>";
			},
			\FOOTNOTE, {
				footNotes = footNotes.add(node);
				stream << "<a class='footnote anchor' name='footnote_org_"
				<< footNotes.size
				<< "' href='#footnote_"
				<< footNotes.size
				<< "'><sup>"
				<< footNotes.size
				<< "</sup></a> ";
			},
			\CLASSTREE, {
				stream << "<ul class='tree'>";
				this.renderClassTree(stream, node.text.asSymbol.asClass);
				stream << "</ul>";
			},
// Lists and tree
			\LIST, {
				stream << "<ul>\n";
				this.renderChildren(stream, node);
				stream << "</ul>\n";
			},
			\TREE, {
				stream << "<ul class='tree'>\n";
				this.renderChildren(stream, node);
				stream << "</ul>\n";
			},
			\NUMBEREDLIST, {
				stream << "<ol>\n";
				this.renderChildren(stream, node);
				stream << "</ol>\n";
			},
			\ITEM, { // for LIST, TREE and NUMBEREDLIST
				stream << "<li>";
				noParBreak = true;
				this.renderChildren(stream, node);
			},
// Definitionlist
			\DEFINITIONLIST, {
				stream << "<dl>\n";
				this.renderChildren(stream, node);
				stream << "</dl>\n";
			},
			\DEFLISTITEM, {
				this.renderChildren(stream, node);
			},
			\TERM, {
				stream << "<dt>";
				noParBreak = true;
				this.renderChildren(stream, node);
			},
			\DEFINITION, {
				stream << "<dd>";
				noParBreak = true;
				this.renderChildren(stream, node);
			},
// Tables
			\TABLE, {
				stream << "<table>\n";
				this.renderChildren(stream, node);
				stream << "</table>\n";
			},
			\TABROW, {
				stream << "<tr>";
				this.renderChildren(stream, node);
			},
			\TABCOL, {
				stream << "<td>";
				noParBreak = true;
				this.renderChildren(stream, node);
			},
// Methods
			\CMETHOD, {
				this.renderMethod(
					stream, node,
					\classMethod,
					currentClass !? {currentClass.class},
					currentImplClass !? {currentImplClass.class}
				);
			},
			\IMETHOD, {
				this.renderMethod(
					stream, node,
					\instanceMethod,
					currentClass,
					currentImplClass
				);
			},
			\METHOD, {
				this.renderMethod(
					stream, node,
					\genericMethod,
					nil, nil
				);
			},
			\CPRIVATE, {},
			\IPRIVATE, {},
			\COPYMETHOD, {},
			\CCOPYMETHOD, {},
			\ICOPYMETHOD, {},
			\ARGUMENTS, {
				stream << "<h4>Arguments:</h4>\n<table class='arguments'>\n";
				currArg = 0;
				if(currentMethod.notNil and: {node.children.size < (currentNArgs-1)}) {
					"SCDoc: In %\n"
					"  Method %% has % args, but doc has % argument:: tags.".format(
						currDoc.fullPath,
						if(currentMethod.ownerClass.isMetaClass) {"*"} {"-"},
						currentMethod.name,
						currentNArgs-1,
						node.children.size,
					).warn;
				};
				this.renderChildren(stream, node);
				stream << "</table>";
			},
			\ARGUMENT, {
				currArg = currArg + 1;
				stream << "<tr><td class='argumentname'>";
				if(node.text.isNil) {
					currentMethod !? {
						if(currentMethod.varArgs and: {currArg==(currentMethod.argNames.size-1)}) {
							stream << "... ";
						};
						stream << if(currArg < currentMethod.argNames.size) {
							if(currArg > minArgs) {
								"("++currentMethod.argNames[currArg]++")";
							} {
								currentMethod.argNames[currArg];
							}
						} {
							"(arg"++currArg++")" // excessive arg
						};
					};
				} {
					stream << if(currentMethod.isNil or: {currArg < currentMethod.argNames.size}) {
						currentMethod !? {
							f = currentMethod.argNames[currArg].asString;
							if(
								(z = if(currentMethod.varArgs and: {currArg==(currentMethod.argNames.size-1)})
										{"... "++f} {f}
								) != node.text;
							) {
								"SCDoc: In %\n"
								"  Method %% has arg named '%', but doc has 'argument:: %'.".format(
									currDoc.fullPath,
									if(currentMethod.ownerClass.isMetaClass) {"*"} {"-"},
									currentMethod.name,
									z,
									node.text,
								).warn;
							};
						};
						if(currArg > minArgs) {
							"("++node.text++")";
						} {
							node.text;
						};
					} {
						"("++node.text++")" // excessive arg
					};
				};
				stream << "<td class='argumentdesc'>";
				this.renderChildren(stream, node);
			},
			\RETURNS, {
				stream << "<h4>Returns:</h4>\n<div class='returnvalue'>";
				this.renderChildren(stream, node);
				stream << "</div>";

			},
			\DISCUSSION, {
				stream << "<h4>Discussion:</h4>\n";
				this.renderChildren(stream, node);
			},
// Sections
			\CLASSMETHODS, {
				if(node.notPrivOnly) {
					stream << "<h2><a class='anchor' name='classmethods'>Class Methods ~</a></h2>\n";
				};
				this.renderChildren(stream, node);
			},
			\INSTANCEMETHODS, {
				if(node.notPrivOnly) {
					stream << "<h2><a class='anchor' name='instancemethods'>Instance Methods ~</a></h2>\n";
				};
				this.renderChildren(stream, node);
			},
			\DESCRIPTION, {
				stream << "<h2><a class='anchor' name='description'>Description ~</a></h2>\n";
				this.renderChildren(stream, node);
			},
			\EXAMPLES, {
				stream << "<h2><a class='anchor' name='examples'>Examples ~</a></h2>\n";
				this.renderChildren(stream, node);
			},
			\SECTION, {
				stream << "<h2><a class='anchor' name='" << this.escapeSpacesInAnchor(node.text)
				<< "'>" << this.escapeSpecialChars(node.text) << "</a></h2>\n";
				if(node.makeDiv.isNil) {
					this.renderChildren(stream, node);
				} {
					stream << "<div id='" << node.makeDiv << "'>";
					this.renderChildren(stream, node);
					stream << "</div>";
				};
			},
			\SUBSECTION, {
				stream << "<h3><a class='anchor' name='" << this.escapeSpacesInAnchor(node.text)
				<< "'>" << this.escapeSpecialChars(node.text) << "</a></h3>\n";
				if(node.makeDiv.isNil) {
					this.renderChildren(stream, node);
				} {
					stream << "<div id='" << node.makeDiv << "'>";
					this.renderChildren(stream, node);
					stream << "</div>";
				};
			},
			{
				"SCDoc: In %\n"
				"  Unknown SCDocNode id: %".format(currDoc.fullPath, node.id).warn;
				this.renderChildren(stream, node);
			}
		);
	}
}
