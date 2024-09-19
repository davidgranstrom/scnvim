// The following code was copied from the LanguageServer.quark implementation
// and adjusted to handle thisProcess.nowExecutingPath for scnvim

Document {
    classvar <dir="", <allDocuments, >current;
    classvar <globalKeyDownAction, <globalKeyUpAction, <>initAction;
    classvar <>autoRun = true;
    classvar <asyncActions;
    classvar <>implementingClass;

    var <>quuid, <title, <isEdited = false;
    var <>toFrontAction, <>endFrontAction, <>onClose, <>textChangedAction;

    var <envir, <savedEnvir;
    var <>path, <>dataptr;
    // var <editable = true, <promptToSave = true;

    //path            { ^this.subclassResponsibility(thisMethod) }
    keyDownAction   { ^this.subclassResponsibility(thisMethod) }
    keyDownAction_  { ^this.subclassResponsibility(thisMethod) }
    keyUpAction     { ^this.subclassResponsibility(thisMethod) }
    keyUpAction_    { ^this.subclassResponsibility(thisMethod) }
    mouseUpAction   { ^this.subclassResponsibility(thisMethod) }
    mouseUpAction_  { ^this.subclassResponsibility(thisMethod) }
    mouseDownAction { ^this.subclassResponsibility(thisMethod) }
    mouseDownAction_{ ^this.subclassResponsibility(thisMethod) }

    *newFromPath {|path, dataptr|
        ^super.new.path_(path).dataptr_(dataptr);
    }

    *current {
        var path = SCNvim.currentPath;
        ^Document.newFromPath(path, true);
    }

    *dir_ {|path|
        path = path.standardizePath;
        if (path == "") { dir = path } {
            if(pathMatch(path).isEmpty) { ("there is no such path:" + path).postln } {
                dir = path ++ "/"
            }
        }
    }

    dir {
        var path = this.path;
        ^path !? { path.dirname }
    }

    *open {
        |path, selectionStart=0, selectionLength=0, envir|
        ^implementingClass.open(path, selectionStart=0, selectionLength=0, envir)
    }

    open {
        |path, selectionStart=0, selectionLength=0, envir|
        ^implementingClass.open(path, selectionStart=0, selectionLength=0, envir)
    }

    *implementationClass { ^LSPDocument }
}
