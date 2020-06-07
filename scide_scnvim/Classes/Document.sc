// nvim Document implementation
//
// The following code is copied/adapted from the Document implementation found in ScIDE.sc
// License GPLv3

Document {
    classvar <dir="";

    // needed for thisProcess.nowExecutingPath to work.. see Kernel::interpretCmdLine
    var <path, <dataptr;

    *new {|path, dataptr|
        ^super.newCopyArgs(path, dataptr);
    }

    *current {
        var path = SCNvim.currentPath;
        ^Document(path, true);
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
}
