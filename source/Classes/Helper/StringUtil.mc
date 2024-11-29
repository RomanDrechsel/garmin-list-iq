import Toybox.Lang;

module Helper {
    class StringUtil {
        static const Whitespaces = [(10).toChar(), (11).toChar(), (12).toChar(), (13).toChar(), (32).toChar(), (133).toChar(), (173).toChar(), (8232).toChar(), (8233).toChar()] as Array<Char>;

        static function stringReplace(str as String, oldString as String, newString as String) as String {
            var result = str;
            while (true) {
                var index = result.find(oldString);
                if (index != null) {
                    var index2 = index + oldString.length();
                    result = result.substring(0, index) + newString + result.substring(index2, result.length());
                } else {
                    return result;
                }
            }

            return "";
        }

        static function split(str as String, additional_separator as Null or Char or Array<Char>) as Array<String> {
            var ret = new Array<String>[0];

            var separators = self.Whitespaces;
            if (additional_separator != null) {
                if (additional_separator instanceof Lang.Char) {
                    separators.add(additional_separator);
                } else {
                    separators.addAll(additional_separator);
                }
            }

            var curr = "" as String;
            var chars = str.toCharArray();
            for (var i = 0; i < chars.size(); i++) {
                if (separators.indexOf(chars[i]) >= 0) {
                    if (curr.length() > 0) {
                        ret.add(curr);
                    }
                    ret.add(chars[i].toString());
                    curr = "";
                } else {
                    curr += chars[i].toString();
                }
            }
            if (curr.length() > 0) {
                ret.add(curr);
            }

            return ret;
        }

        static function splitLines(str as String) as Array<String> {
            var ret = [];
            var pos = str.find("\n");
            while (pos != null) {
                var line = str.substring(0, pos);
                ret.add(line);
                str = str.substring(pos + 1, str.length());
                pos = str.find("\n");
            }

            if (str.length() > 0) {
                ret.add(str);
            }

            return ret;
        }

        static function isWhitespace(str as String or Char or Number) as Boolean {
            if (str instanceof Lang.String) {
                var chars = str.toCharArray();
                for (var i = 0; i < chars.size(); i++) {
                    if (self.isWhitespace(chars[i])) {
                        return true;
                    }
                }
                return false;
            } else if (str instanceof Lang.Char) {
                if (self.Whitespaces.indexOf(str) >= 0) {
                    return true;
                }
                return false;
            } else if (str instanceof Lang.Number) {
                return self.isWhitespace(str.toChar());
            }

            return false;
        }

        static function trim(str as String) as String {
            if (str.length() > 0) {
                var chars = str.toCharArray();
                var start = 0;
                var end = str.length() - 1;
                for (var i = 0; i < chars.size(); i++) {
                    if (!self.isWhitespace(chars[i])) {
                        start = i;
                        break;
                    }
                }
                for (var i = chars.size() - 1; i >= 0; i--) {
                    if (!self.isWhitespace(chars[i])) {
                        end = i;
                        break;
                    }
                }
                str = str.substring(start, end + 1);
            }

            return str;
        }

        static function formatBytes(bytes as Number) as String {
            if (bytes >= 1048576) {
                return (bytes / 1048576).format("%.1f") + "Mb";
            } else if (bytes >= 1024) {
                return (bytes / 1024).format("%.1f") + "kB";
            } else {
                return bytes + "B";
            }
        }
    }
}
