import Toybox.Lang;
import Toybox.Graphics;

module Helper {
    (:glance)
    class StringUtil {
        private static const lineBreaks = [0x0a /*New Line*/, 0x0b /*Line tabulation*/, 0x0d /*CR*/, 0x85 /*Next Line*/, 0xad /*Soft-Hyphen*/] as Array<Number>;
        private static const nBsp = [0xa0 /*nbsp*/, 0x202f /*nnbsp*/];
        private static const wordBreaks = [
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
                //TODO: rtrim()
                ret.add(line);
            }

            return ret;
        }

        static function isWhitespace(str as String or Char or Number) as Boolean {
            //TODO: is String needed?
            if (str instanceof Lang.Number) {
                if (str == 0x20) {
                    return true;
                }
                return false;
            } else if (str instanceof Lang.String) {
                var chars = str.toUtf8Array();
                for (var i = 0; i < chars.size(); i++) {
                    if (!self.isWhitespace(chars[i])) {
                        return false;
                    }
                }
                return true;
            } else if (str instanceof Lang.Char) {
                return self.isWhitespace(str.toNumber());
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
    }
}
