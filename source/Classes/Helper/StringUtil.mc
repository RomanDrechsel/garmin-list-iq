import Toybox.Lang;

module Helper {
    (:glance)
    class StringUtil {
        private static const whitespaces = [(10).toChar() /*New Live*/, (11).toChar() /*Tabulation*/, (13).toChar() /*CR*/, (32).toChar() /*Space*/, (133).toChar() /*Next Line*/, (173).toChar() /*Soft-Hyphen*/] as Array<Char>;
        private static const nBsp = [(8239).toChar(), (160).toChar()];
        private static const lineBreaks = [
            [0x21, 0x2f],
            [0x3a, 0x40],
            [0x5c, 0x60],
            [0x7c, 0x7e],
            [0x2010, 0x2027],
            [0x2030, 0x205e],
            [0x2070, 0x20c0],
            [0x3040, 0x30ff] /* japanese */,
            [0x3000, 0x3002] /* japanese punctuation */,
            [0x4e00, 0x9fff] /*CJK Unified Ideographs*/,
            [0x3400, 0x4dbf] /*CJK Unified Ideographs Extension A*/,
            [0x20000, 0x2a6df] /*CJK Unified Ideographs Extension B*/,
            [0x2a700, 0x2ebef] /*CJK Unified Ideographs Extension C, D, E, ...*/,
            [0xf900, 0xfaff] /*CJK Compatibility Ideographs*/,
        ];

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

        static function split(str as String) as Array<String> {
            var ret = new Array<String>[0];

            var curr = "" as String;
            var chars = str.toCharArray();
            for (var i = 0; i < chars.size(); i++) {
                if (self.nBsp.indexOf(chars[i]) >= 0) {
                    curr += " ";
                } else if (self.whitespaces.indexOf(chars[i]) >= 0) {
                    if (curr.length() > 0) {
                        ret.add(curr);
                    }
                    ret.add(" ");
                    curr = "";
                } else {
                    var linebreak = false;
                    var char_number = chars[i].toNumber();
                    for (var c = 0; c < self.lineBreaks.size(); c++) {
                        var a = self.lineBreaks[c];
                        if (char_number >= a[0] && char_number <= a[1]) {
                            linebreak = true;
                            break;
                        }
                    }
                    curr += chars[i].toString();
                    if (linebreak) {
                        if (curr.length() > 0) {
                            ret.add(curr);
                        }
                        curr = "";
                    }
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
                    if (!self.isWhitespace(chars[i])) {
                        return false;
                    }
                }
                return true;
            } else if (str instanceof Lang.Char) {
                if (self.whitespaces.indexOf(str) >= 0) {
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

        static function cleanString(str as String) as String {
            var curr_str = "" as String;
            var chars = str.toCharArray();
            for (var i = 0; i < chars.size(); i++) {
                if (self.nBsp.indexOf(chars[i]) >= 0) {
                    curr_str += " ";
                } else {
                    curr_str += chars[i].toString();
                }
            }

            return curr_str;
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
