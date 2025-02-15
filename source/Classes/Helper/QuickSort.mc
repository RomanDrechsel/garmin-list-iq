import Toybox.Lang;

module Helper {
    class Quicksort {
        static function Sort(arr as Array<Object>) as Array<Object> {
            if (arr.size() <= 1) {
                return arr;
            }

            var pivot = arr[arr.size() / 2].toString();
            var left = [];
            var right = [];
            var equal = [];

            for (var i = 0; i < arr.size(); i++) {
                var item = arr[i];
                var comp = self.compareStrings(item.toString(), pivot);

                if (comp < 0) {
                    left.add(item);
                } else if (comp > 0) {
                    right.add(item);
                } else {
                    equal.add(item);
                }
            }
            var ret = [];
            ret.addAll(self.Sort(left));
            ret.addAll(equal);
            ret.addAll(self.Sort(right));

            return ret;
        }

        static function compareStrings(str1, str2) as Number {
            if (Lang.String has :compareTo) {
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
