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
                var comp = item.toString().compareTo(pivot);

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
    }
}
