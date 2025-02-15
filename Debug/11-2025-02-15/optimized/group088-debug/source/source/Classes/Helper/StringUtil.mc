import Toybox.Lang;
import Toybox.Graphics;

module Helper {
    (:glance)
    class StringUtil {
        static function stringReplace(str as String, oldString as String, newString as String) as String {
            var result = str;
            while (true) {
                var index = result.find(oldString);
                if (index != null) {
                    str /*>index2<*/ = index + oldString.length();
                    result = result.substring(0, index) + newString + result.substring(str /*>index2<*/, result.length());
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
            for (var i = 0; i < strs.size(); i += 1) {
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
