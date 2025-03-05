import Toybox.Lang;

module Lists {
    typedef ListModel as Dictionary<Number, String or Number or Boolean or Array<ListitemModel> >;

    (:glance,:background)
    class List {
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
        }

        public var Uuid as String or Number or Null;
        public var Title as String?;
        public var Order as Number?;
        public var Date as Number?;
        public var Items as Array<Listitem>? = [];
        public var Reset as Boolean?;
        public var ResetInterval as String?;
        public var ResetHour as Number?;
        public var ResetMinute as Number?;
        public var ResetWeekday as Number?;
        public var ResetDay as Number?;
        public var ResetLast as Number?;

        function initialize(data as Dictionary<String or Number, Object>?) {
            if (data != null) {
                self.Uuid = data.get(UUID) as String or Number or Null;

                if (self.Uuid == null && data.get("uuid") != null) {
                    throw new Exceptions.LegacyNotSupportedException();
                }

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

        public function ProcessBatch(data as Array, memoryChecker as Helper.MemoryChecker?) {
            while (data.size() > 0) {
                var rowsplit = Helper.StringUtil.split(data[0].toString(), "=", 2);
                data = data.slice(1, null);
                if (rowsplit.size() <= 1 || rowsplit[0].length == 0) {
                    Debug.Log("No key value pair in list data " + rowsplit);
                    continue;
                }
                var key = rowsplit[0];
                var val = rowsplit[1];
                rowsplit = null;
                if (key.equals("uuid")) {
                    self.Uuid = val.toString();
                    var num = Helper.StringUtil.StringToNumber(self.Uuid);
                    if (num != null) {
                        self.Uuid = num;
                    }
                } else if (key.equals("t")) {
                    self.Title = val.toString();
                } else if (key.equals("o")) {
                    self.Order = val.toNumber();
                } else if (key.equals("d")) {
                    var date = val.toLong();
                    if (date != null) {
                        if (date > 999999999) {
                            // date is in milliseconds
                            date /= 1000;
                        }
                        self.Date = date.toNumber();
                    }
                } else if (key.substring(0, 2).equals("it")) {
                    var split = Helper.StringUtil.split(key.substring(2, key.length()), "_", 2);
                    key = null;
                    var index = split[0].toNumber();
                    var prop = split.size() > 1 ? split[1] : null;
                    split = null;
                    if (prop != null && index != null) {
                        var item = self.GetItem(index);
                        if (item == null) {
                            item = new Listitem(null);
                            item.Order = index;
                            self.Items.add(item);
                        }
                        if (prop.equals("i")) {
                            item.Text = val.toString();
                        } else if (prop.equals("n")) {
                            item.Note = val.toString();
                        } else if (prop.equals("d")) {
                            item.Done = Helper.StringUtil.StringToBool(val);
                        } else if (prop.equals("uuid")) {
                            var num = Helper.StringUtil.StringToNumber(val);
                            item.Uuid = num != null ? num : val;
                        }
                    }
                } else if (key.substring(0, 2).equals("r_")) {
                    if (key.equals("r_a")) {
                        val = Helper.StringUtil.StringToBool(val);
                        if (val != null) {
                            self.Reset = val;
                        }
                    } else if (key.equals("r_i")) {
                        self.ResetInterval = val.toString(); //no reference
                    } else if (key.equals("r_h")) {
                        val = val.toNumber();
                        if (val != null) {
                            self.ResetHour = val;
                        }
                    } else if (key.equals("r_m")) {
                        val = val.toNumber();
                        if (val != null) {
                            self.ResetMinute = val;
                        }
                    } else if (key.equals("r_w")) {
                        val = val.toNumber();
                        if (val != null) {
                            self.ResetWeekday = val;
                        }
                    } else if (key.equals("r_d")) {
                        val = val.toNumber();
                        if (val != null) {
                            self.ResetDay = val;
                        }
                    }
                } else if (key.equals("r_l")) {
                    var num = val.toNumber();
                    if (num != null) {
                        self.ResetLast = num;
                    }
                }
                key = null;
                val = null;
                if (memoryChecker != null) {
                    memoryChecker.Check();
                }
            }
        }

        public function FinishBatch() as Boolean {
            if (self.IsValid()) {
                if (self.Reset != null) {
                    var missing = [];
                    if (self.ResetInterval != null && self.ResetHour != null && self.ResetMinute != null) {
                        if (self.ResetInterval == "w" && self.ResetWeekday == null) {
                            missing.add("weekday");
                        } else if (self.ResetInterval == "m" && self.ResetDay == null) {
                            missing.add("day");
                        }
                    } else {
                        if (self.ResetInterval == null) {
                            missing.add("interval");
                        }
                        if (self.ResetHour == null) {
                            missing.add("hour");
                        }
                        if (self.ResetMinute == null) {
                            missing.add("minute");
                        }
                    }
                    if (missing.size() > 0) {
                        Debug.Log("Could not load list: missing properties - " + missing);
                    }
                }
                if (self.Date == null) {
                    self.Date = Time.now().value();
                }
                if (self.Reset != null && self.ResetLast == null) {
                    self.ResetLast = Time.now().value();
                }
                self.Items = self.sortItems(self.Items);
                return true;
            } else {
                var missing = [];
                if (self.Title == null) {
                    missing.add("title");
                }
                if (self.Order == null) {
                    missing.add("order");
                }
                if (self.Uuid == null) {
                    missing.add("uuid");
                }
                if (missing.size() > 0) {
                    Debug.Log("Could not load list: missing properties - " + missing);
                } else {
                    Debug.Log("Could not load list: missing properties");
                }
                return false;
            }
        }

        public function IsValid() {
            return self.Uuid != null && self.Title != null && self.Order != null;
        }

        public function GetItem(index as Number) as Listitem? {
            if (self.Items.size() > index) {
                return self.Items[index];
            }
            return null;
        }

        public function ReduceItem() as Listitem? {
            var item = self.GetItem(0);
            if (item != null) {
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
                return "'" + self.Title + "' (" + self.Uuid.toString() + ")";
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

        private function sortItems(items as Array<Listitem>?) as Array<Listitem>? {
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
