import Toybox.Lang;
import Toybox.Graphics;

module Helper {
    (:glance)
    class StringUtil {
        private static const lineBreaks = [0x0a /*New Line*/, 0x0b /*Line tabulation*/, 0x0d /*CR*/, 0x85 /*Next Line*/, 0xad /*Soft-Hyphen*/] as Array<Number>;

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

        static function split(str as String, split as String, maxCount as Number) as Array<String> {
            var ret = [];
            if (maxCount < 2) {
                return [str];
            }

            var last_index = 0;
            var index = str.find(split);
            while (index != null && ret.size() < maxCount - 1) {
                if (index <= last_index) {
                    ret.add("");
                } else {
                    ret.add(str.substring(last_index, index));
                }
                last_index = index + split.length();
            }

            if (last_index < str.length()) {
                ret.add(str.substring(last_index, str.length()));
            }

            return ret;
        }

        static function splitLines(str as String) as Array<String> {
            var ret = [];

            var chars = str.toUtf8Array();
            var br = -1;
            for (var i = 0; i < chars.size(); i++) {
                var char = chars[i];
                if (self.lineBreaks.indexOf(char) >= 0) {
                    if (br < 0) {
                        br = 0;
                    }
                    if (br == i) {
                        //empty line
                        ret.add("");
                    } else {
                        var line = str.substring(br, i);
                        ret.add(line);
                    }
                    br = i + 1;
                }
            }

            if (br < 0) {
                br = 0;
            }

            if (br < str.length()) {
                var line = str.substring(br, str.length());
                line = self.trim(line);
                ret.add(line);
            }

            return ret;
        }

        static function isWhitespace(str as Char or Number) as Boolean {
            if (str instanceof Lang.Char) {
                str = str.toNumber();
            }

            if (str == 0x20 || self.lineBreaks.indexOf(str) >= 0) {
                return true;
            }
            return false;
        }

        static function trim(str as String) as String {
            if (str.length() > 0) {
                var chars = str.toUtf8Array();
                var start = 0;
                var end = str.length() - 1;
                for (var i = 0; i < chars.size(); i++) {
                    if (chars[i] != 0x20 && !self.isWhitespace(chars[i])) {
                        start = i;
                        break;
                    }
                }
                for (var i = chars.size() - 1; i >= 0; i--) {
                    if (chars[i] != 0x20 && !self.isWhitespace(chars[i])) {
                        end = i;
                        break;
                    }
                }
                if (start > 0 || end < str.length() - 1) {
                    str = str.substring(start, end + 1);
                }
            }

            return str;
        }

        static function join(strs as Array<String>, sep as String?) as String {
            var ret = "";
            for (var i = 0; i < strs.size(); i++) {
                ret += strs[i];
                if (sep != null && i < strs.size() - 1) {
                    ret += sep;
                }
            }
            return ret;
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

        static function StringToBool(str as String) as Boolean? {
            if (str.equals("true")) {
                return true;
            } else if (str.equals("false")) {
                return false;
            } else {
                return null;
            }
        }
    }
}
