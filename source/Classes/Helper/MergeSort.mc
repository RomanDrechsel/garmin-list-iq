import Toybox.Lang;

module Helper {
    class MergeSort {
        static function Sort(array as Array<Object>, propertykey as String or Number or Null) as Array? {
            if (array.size() <= 1) {
                return array;
            }

            var mid = (array.size() / 2).toNumber();

            var subarray1 = self.Sort(array.slice(0, mid), propertykey);
            var subarray2 = self.Sort(array.slice(mid, null), propertykey);
            array = null;

            return self.Merge(subarray1, subarray2, propertykey);
        }

        private static function Merge(array1 as Array, array2 as Array, propertykey as String or Number or Null) as Array {
            var result = [];

            var val1, val2;

            while (array1.size() > 0 && array2.size() > 0) {
                if (propertykey != null && array1[0] instanceof Lang.Dictionary) {
                    val1 = array1[0].get(propertykey);
                    val2 = array2[0].get(propertykey);
                } else {
                    val1 = array1[0];
                    val2 = array2[0];
                }

                if (val1 instanceof Lang.Number && val2 instanceof Lang.Number) {
                    if (val1 > val2) {
                        result.add(array2[0]);
                        array2 = array2.slice(1, null);
                    } else {
                        result.add(array1[0]);
                        array1 = array1.slice(1, null);
                    }
                } else {
                    if (val1 != null && (val2 == null || Helper.StringUtil.compareStrings(val1.toString(), val2.toString()) > 0)) {
                        result.add(array2[0]);
                        array2 = array2.slice(1, null);
                    } else {
                        result.add(array1[0]);
                        array1 = array1.slice(1, null);
                    }
                }
            }

            while (array1.size() > 0) {
                result.add(array1[0]);
                array1 = array1.slice(1, null);
            }

            while (array2.size() > 0) {
                result.add(array2[0]);
                array2 = array2.slice(1, null);
            }

            return result;
        }
    }
}
