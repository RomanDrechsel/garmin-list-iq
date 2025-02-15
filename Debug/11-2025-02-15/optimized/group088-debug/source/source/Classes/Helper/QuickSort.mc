import Toybox.Lang;

module Helper {
    class Quicksort {
        static function Sort(arr as Array<Object>) as Array<Object> {
            var ret, pre_0;
            if (arr.size() <= 1) {
                return arr;
            }

            pre_0 = 0;
            var pivot = arr[arr.size() / 2].toString();
            var left = [];
            var right = [];
            var equal = [];

            {
                ret /*>i<*/ = pre_0;
                for (; ret /*>i<*/ < arr.size(); ret /*>i<*/ += 1) {
                    var item = arr[ret /*>i<*/];
                    var comp = self.compareStrings(item.toString(), pivot);

                    if (comp < pre_0) {
                        left.add(item);
                    } else if (comp > pre_0) {
                        right.add(item);
                    } else {
                        equal.add(item);
                    }
                }
            }
            ret = [];
            ret.addAll(self.Sort(left));
            ret.addAll(equal);
            ret.addAll(self.Sort(right));

            return ret;
        }

        static function compareStrings(str1, str2) as Number {
            var pre_1;
            if (Lang.String has :compareTo) {
                return str1.compareTo(str2);
            }

            var len1 = str1.length();
            var len2 = str2.length();
            var minLength = len1 < len2 ? len1 : len2;

            var chars1 = str1.toCharArray();
            var chars2 = str2.toCharArray();

            pre_1 = 1;
            {
                str1 /*>i<*/ = 0;
                for (; str1 /*>i<*/ < minLength; str1 /*>i<*/ += pre_1) {
                    str2 /*>char1<*/ = chars1[str1 /*>i<*/];
                    var char2 = chars2[str1 /*>i<*/];

                    if (str2 /*>char1<*/ != char2) {
                        return str2 /*>char1<*/ < char2 ? -1 : pre_1;
                    }
                }
            }

            if (len1 == len2) {
                return 0;
            }
            return len1 < len2 ? -1 : pre_1;
        }
    }
}
