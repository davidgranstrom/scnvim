/*
 * Helper class to convert between Dictionary types and JSON.
 * Note: Array types are not implemented yet.
 */
SCNvimJSON {
    classvar <stream;
    classvar <list;

    *initClass {
        stream = CollStream.new;
    }

    *stringify {arg object;
        stream.reset;
        if (object.isKindOf(Dictionary)) {
            stream << "{";
            SCNvimJSON.prParseRecursive(object);
            stream << "}";
        };
        if (object.isKindOf(Array)) {
            "Array is not implemented yet".warn;
            stream << "[";
            stream << "]";
        };
        if (stream.contents.isEmpty.not) {
            ^stream.contents;
        }
        ^nil;
    }

    *parse {arg string;
        ^string.parseYAML;
    }

    *prParseRecursive {arg object;
        var size = object.size;
        var count = size;
        object.keysValuesDo {|key, val|
            count = count - 1;
            if (val.isKindOf(Dictionary)) {
                stream << "\"" << key << "\":";
                stream << "{";
                SCNvimJSON.prParseRecursive(val);
                stream << "}%".format((count == 0).if("",","));
            } {
                SCNvimJSON.prAddAssoc(key, val, count == 0);
            };
        };
    }

    *prAddAssoc {|key, value, isLastItem|
        if (value.isNil) { value = "" };
        if (value.isString) {
            value = value.escapeChar(92.asAscii); // backslash
            value = value.escapeChar(34.asAscii); // double quote
        };
        stream << "\"" << key;
        if (value.isNumber) {
            stream << "\":" << value << "%".format(isLastItem.if("",","));
        } {
            stream << "\":\"" << value << "\"%".format(isLastItem.if("",","));
        }
    }
}
