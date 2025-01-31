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
    }
}
