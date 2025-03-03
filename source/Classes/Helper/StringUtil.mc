import Toybox.Lang;
import Toybox.Graphics;

module Helper {
    (:glance,:background)
    class StringUtil {
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

        static function StringToBool(str as String?) as Boolean? {
            if (str == null) {
                return null;
            }
            if (str.equals("true")) {
                return true;
            } else if (str.equals("false")) {
                return false;
            } else {
                return null;
            }
        }

        static function StringToNumber(str as String?) as Number? {
            if (str == null) {
                return null;
            }

            try {
                var num = str.toNumber();
                if (num != null && num.toString().equals(str)) {
                    return num;
                }
                return null;
            } catch (e) {
                return null;
            }
        }

        static function getSize(obj as Object) as Number {
            var size = 0;
            if (obj instanceof Lang.Array) {
                for (var i = 0; i < obj.size(); i++) {
                    size += self.getSize(obj[i]);
                }
            } else {
                size = obj.toString().length() * 2;
            }
            return size;
        }

        static function compareStrings(str1 as String, str2 as String) as Number {
            if (str1 has :compareTo) {
                return str1.compareTo(str2);
            }

            var len1 = str1.length();
            var len2 = str2.length();
            var minLength = len1 < len2 ? len1 : len2;

            var chars1 = str1.toCharArray();
            var chars2 = str2.toCharArray();

            for (var i = 0; i < minLength; i++) {
                var char1 = chars1[i];
                var char2 = chars2[i];

                if (char1 != char2) {
                    return char1 < char2 ? -1 : 1;
                }
            }

            if (len1 == len2) {
                return 0;
            }
            return len1 < len2 ? -1 : 1;
        }
    }
}
