import Toybox.Lang;

module Lists {
    typedef ListModel as Dictionary<Number or String, String or Number or Boolean or Array<ListitemModel> >;

    class List {
        (:glance)
        enum EKey {
            UUID = 0,
            TITLE = 1,
            ORDER = 2,
            DATE = 3,
            ITEMS = 4,
            RESET = 5,
            RESET_INTERVAL = 6,
            RESET_HOUR = 7,
            RESET_MINUTE = 8,
            RESET_WEEKDAY = 9,
            RESET_DAY = 10,
            RESET_LAST = 11,
            REVISION = 999,
        }

        public const CurrentRevision = 1;

        public var Uuid as String or Number or Null;
        public var Title as String?;
        public var Order as Number?;
        public var Date as Number?;
        public var Items as Array<Listitem> = [];
        public var Reset as Boolean?;
        public var ResetInterval as String?;
        public var ResetHour as Number?;
        public var ResetMinute as Number?;
        public var ResetWeekday as Number?;
        public var ResetDay as Number?;
        public var ResetLast as Number?;
        public var Revision as Number?;

        function initialize(data as ListModel?) {
            if (data != null) {
                self.Revision = data.get(REVISION) as Number?;

                if (self.Revision == null || self.Revision != self.CurrentRevision) {
                    throw new Exceptions.LegacyNotSupportedException();
                }

                self.Uuid = data.get(UUID) as String or Number or Null;
                self.Title = data.get(TITLE) as String?;
                self.Order = data.get(ORDER) as Number?;
                self.Date = data.get(DATE) as Number?;
                var items = data.get(ITEMS) as Array<ListitemModel>?;
                if (items != null) {
                    while (items.size() > 0) {
                        var item = new Listitem(items[0] as ListitemModel);
                        items = items.slice(1, null);
                        self.Items.add(item);
                    }
                    self.Items = self.sortItems(self.Items);
                } else {
                    self.Items = [];
                }

                self.Reset = data.get(RESET) as Boolean?;
                self.ResetInterval = data.get(RESET_INTERVAL);
                self.ResetHour = data.get(RESET_HOUR) as Number?;
                self.ResetMinute = data.get(RESET_MINUTE) as Number?;
                self.ResetWeekday = data.get(RESET_WEEKDAY) as Number?;
                self.ResetDay = data.get(RESET_DAY) as Number?;
                self.ResetLast = data.get(RESET_LAST) as Number?;

                if (self.Date == null) {
                    self.Date = Time.now().value();
                }
                if (self.Reset != null && self.ResetLast == null) {
                    self.ResetLast = Time.now().value();
                }
            }
        }

        public function IsValid() {
            return self.Uuid != null && self.Title != null && self.Order != null;
        }

        public function GetItem(order as Number) as Listitem? {
            for (var i = 0; i < self.Items.size(); i++) {
                if (self.Items[i].Order == order) {
                    return self.Items[i];
                }
            }
            return null;
        }

        public function ReduceItem() as Listitem? {
            var item = null;

            if (self.Items.size() > 0) {
                item = self.Items[0];
                self.Items = self.Items.slice(1, null);
            }
            return item;
        }

        public function ToBackend() as ListModel? {
            if (self.IsValid()) {
                var model =
                    ({
                        UUID => self.Uuid,
                        TITLE => self.Title,
                        ORDER => self.Order,
                        DATE => self.Date,
                        REVISION => self.Revision,
                    }) as ListModel;
                var items = [] as Array<ListitemModel>;
                for (var i = 0; i < self.Items.size(); i++) {
                    var idict = self.Items[i].toBackend();
                    if (idict != null) {
                        items.add(idict);
                    }
                }
                if (items.size() > 0) {
                    model.put(ITEMS, items);
                }
                items = null;

                if (self.Reset != null) {
                    model.put(RESET, self.Reset);
                    if (self.ResetInterval != null) {
                        model.put(RESET_INTERVAL, self.ResetInterval);
                    }
                    if (self.ResetHour != null) {
                        model.put(RESET_HOUR, self.ResetHour);
                    }
                    if (self.ResetMinute != null) {
                        model.put(RESET_MINUTE, self.ResetMinute);
                    }
                    if (self.ResetWeekday != null) {
                        model.put(RESET_WEEKDAY, self.ResetWeekday);
                    }
                    if (self.ResetDay != null) {
                        model.put(RESET_DAY, self.ResetDay);
                    }
                    if (self.ResetLast != null) {
                        model.put(RESET_LAST, self.ResetLast);
                    }
                }
                return model;
            } else {
                return null;
            }
        }

        public function RemoveReset() as Void {
            self.Reset = null;
            self.ResetInterval = null;
            self.ResetHour = null;
            self.ResetMinute = null;
            self.ResetWeekday = null;
            self.ResetDay = null;
            self.ResetLast = null;
        }

        public function toString() as String {
            if (self.IsValid()) {
                return "'" + self.Title + "' (" + self.Uuid.toString() + "/" + self.Revision + ")";
            }
            return "invalid list";
        }

        public function equals(other as Object?) as Boolean {
            if (other == null || !(other instanceof List)) {
                if (other instanceof Number && self.Uuid instanceof Number) {
                    return self.Uuid == other;
                }
                if (other instanceof String && self.Uuid instanceof String) {
                    return self.Uuid.equals(other);
                }
                return false;
            }

            other = other as List;
            if (self.Uuid instanceof Number && other.Uuid instanceof Number) {
                return self.Uuid == other.Uuid;
            }
            if (self.Uuid instanceof String && other.Uuid instanceof String) {
                return self.Uuid.equals(other.Uuid);
            }
            return false;
        }

        public function ToIndex() as ListIndexItem {
            return {
                UUID => self.Uuid,
                TITLE => self.Title,
                ORDER => self.Order,
                ITEMS => self.Items.size(),
                DATE => self.Date,
            };
        }

        public function sortItems(items as Array<Listitem>?) as Array<Listitem>? {
            if (items == null || items.size() <= 1) {
                return items;
            }

            var mid = (items.size() / 2).toNumber();

            var subarray1 = self.sortItems(items.slice(0, mid));
            var subarray2 = self.sortItems(items.slice(mid, null));
            items = null;

            return self.MergeSort(subarray1, subarray2);
        }

        private function MergeSort(array1 as Array<Listitem>, array2 as Array<Listitem>) as Array<Listitem> {
            var result = [];

            while (array1.size() > 0 && array2.size() > 0) {
                var val1 = array1[0].Order;
                var val2 = array2[0].Order;

                if (val1 > val2) {
                    result.add(array2[0]);
                    array2 = array2.slice(1, null);
                } else {
                    result.add(array1[0]);
                    array1 = array1.slice(1, null);
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

        public static function IsValidIndex(index as ListIndexItem?) as Boolean {
            if (index == null) {
                return false;
            }
            var uuid = index.get(UUID);
            if ((!(uuid instanceof Lang.Number) && !(uuid instanceof Lang.String)) || !(index.get(TITLE) instanceof Lang.String) || !(index.get(ORDER) instanceof Lang.Number) || !(index.get(ITEMS) instanceof Lang.Number)) {
                return false;
            }
            return true;
        }
    }
}
