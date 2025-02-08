import Toybox.Lang;

module Helper {
    class MergeSort {
        static function Sort(array as Array<Object>, propertykey as String?) as Array? {
            if (array.size() <= 1) {
                return array;
            }

            var mid = (array.size() / 2).toNumber();
            return self.Merge(self.Sort(array.slice(0, mid), propertykey), self.Sort(array.slice(mid, null), propertykey), propertykey);
        }

        private static function Merge(array1 as Array, array2 as Array, propertykey as String?) as Array {
            var pre_0, pre_1;
            var result = [];

            var val1, val2;

            pre_1 = 1;
            pre_0 = 0;
            while (array1.size() > pre_0 && array2.size() > pre_0) {
                if (propertykey != null && array1[pre_0] instanceof Lang.Dictionary) {
                    val1 = array1[pre_0].get(propertykey);
                    val2 = array2[pre_0].get(propertykey);
                } else {
                    val1 = array1[pre_0];
                    val2 = array2[pre_0];
                }

                if (val1 != null && (val2 == null || val1 > val2)) {
                    result.add(array2[pre_0]);
                    array2 = array2.slice(pre_1, null);
                } else {
                    result.add(array1[pre_0]);
                    array1 = array1.slice(pre_1, null);
                }
            }

            while (array1.size() > pre_0) {
                result.add(array1[pre_0]);
                array1 = array1.slice(pre_1, null);
            }

            while (array2.size() > pre_0) {
                result.add(array2[pre_0]);
                array2 = array2.slice(pre_1, null);
            }

            return result;
        }
    }
}
