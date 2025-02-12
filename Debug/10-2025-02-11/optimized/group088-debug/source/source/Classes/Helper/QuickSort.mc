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
                    var comp = item.toString().compareTo(pivot);

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
    }
}
