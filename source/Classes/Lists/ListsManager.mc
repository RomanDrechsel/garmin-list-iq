import Toybox;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Time;
import Toybox.System;
import Helper;
import Controls.Listitems;
import Views;

module Lists {
    typedef ListItemsItem as Dictionary<String, String or Array<String> or Boolean or Number>; /* a list item (with key "i" for item-text, "n" for note-text, "d" for done?) */
    typedef List as Dictionary<String, String or Array<ListItemsItem> or Boolean or Number>; /* a list */
    (:glance)
    typedef ListIndexItem as Dictionary<String, String or Number>; /* data of a list, stored in list index */
    (:glance)
    typedef ListIndex as Dictionary<String, ListIndexItem>; /* the list-index, with list uuid as key, and some list data as value */

    class ListsManager {
        private var onListsChangedListeners as Array<WeakReference> = [];

        function addList(data as Dictionary) as Boolean {
            var keys = data.keys();
            var listuuid = null;
            var listname = null;
            var listorder = null;
            var listitems = {};
            var listdate = null;
            var reset = null;
            var reset_interval = null;
            var reset_hour = null;
            var reset_minute = null;
            var reset_weekday = null;
            var reset_day = null;

            for (var i = 0; i < keys.size(); i++) {
                var key = keys[i];
                var val = data.get(key);
                if (key.equals("uuid")) {
                    listuuid = val.toString();
                } else if (key.equals("name")) {
                    listname = val.toString();
                } else if (key.equals("order")) {
                    listorder = val.toNumber();
                } else if (key.equals("date")) {
                    listdate = val.toLong();
                    if (listdate != null) {
                        if (listdate > 999999999) {
                            // date is in milliseconds
                            listdate /= 1000;
                            listdate = listdate.toNumber();
                        }
                    }
                } else if (key.substring(0, 4).equals("item")) {
                    var split = Helper.StringUtil.split(key.substring(4, key.length()), "_", 2);
                    var index = split[0].toNumber();
                    var prop = split.size() > 1 ? split[1] : null;
                    if (prop != null && index != null) {
                        var item;
                        if (listitems.hasKey(index)) {
                            item = listitems.get(index);
                        } else {
                            item = { "d" => false };
                        }
                        if (prop.equals("item")) {
                            item.put("i", val.toString());
                        } else if (prop.equals("note")) {
                            item.put("n", val.toString());
                        }
                        listitems.put(index, item);
                    }
                } else if (key.substring(0, 5).equals("reset")) {
                    if (key.equals("reset_active")) {
                        val = Helper.StringUtil.StringToBool(val);
                        if (val != null) {
                            reset = val;
                        }
                    } else if (key.equals("reset_interval")) {
                        reset_interval = val.toString(); //no reference
                    } else if (key.equals("reset_hour")) {
                        val = val.toNumber();
                        if (val != null) {
                            reset_hour = val;
                        }
                    } else if (key.equals("reset_minute")) {
                        val = val.toNumber();
                        if (val != null) {
                            reset_minute = val;
                        }
                    } else if (key.equals("reset_weekday")) {
                        val = val.toNumber();
                        if (val != null) {
                            reset_weekday = val;
                        }
                    } else if (key.equals("reset_day")) {
                        val = val.toNumber();
                        if (val != null) {
                            reset_day = val;
                        }
                    }
                }
            }

            //verify data
            if (listname == null || listorder == null || listuuid == null) {
                var missing = [] as Array<String>;
                if (listname == null) {
                    missing.add("name");
                }
                if (listorder == null) {
                    missing.add("order");
                }
                if (listuuid == null) {
                    missing.add("uuid");
                }
                Debug.Log("Could not add list: missing properties - " + missing);
                self.reportError(2, { "data" => data, "missing" => missing });
                return false;
            }

            if (listdate == null) {
                listdate = Time.now().value();
            }

            var list = {};
            list.put("name", listname);

            //reduce items to a simple array, ordered by item-index
            var itemsArr = [];
            if (listitems.size() > 0) {
                var itemKeys = listitems.keys();
                itemKeys = Helper.Quicksort.SortNumbers(itemKeys);
                for (var i = 0; i < itemKeys.size(); i++) {
                    itemsArr.add(listitems.get(itemKeys[i]));
                }
            }
            list.put("items", itemsArr);

            if (reset != null) {
                var missing = [] as Array<String>;
                if (reset_interval != null && reset_hour != null && reset_minute != null) {
                    if (reset_interval == "w" && reset_weekday == null) {
                        missing.add("weekday");
                    } else if (reset_interval == "m" && reset_day == null) {
                        missing.add("day");
                    }
                } else {
                    if (reset_interval == null) {
                        missing.add("interval");
                    }
                    if (reset_hour == null) {
                        missing.add("hour");
                    }
                    if (reset_minute == null) {
                        missing.add("minute");
                    }
                }

                if (missing.size() > 0) {
                    Debug.Log("Could not add list reset: missing properties - " + missing);
                } else {
                    list.put("r_a", reset);
                    list.put("r_i", reset_interval);
                    list.put("r_h", reset_hour);
                    list.put("r_m", reset_minute);
                    if (reset_interval.equals("w")) {
                        list.put("r_wd", reset_weekday);
                    } else if (reset_interval.equals("m")) {
                        list.put("r_d", reset_day);
                    }
                    list.put("r_last", Time.now().value());
                }
            }

            var save = self.saveList(listuuid, list);
            if (save[0] == true) {
                //Store Index...
                var listindex = self.GetLists();
                var indexitem =
                    ({
                        "key" => listuuid,
                        "name" => listname,
                        "order" => listorder,
                        "items" => listitems.size(),
                        "date" => listdate,
                    }) as ListIndexItem;

                listindex.put(listuuid, indexitem);

                var saveIndex = self.StoreIndex(listindex);
                if (saveIndex[0] == false) {
                    Application.Storage.deleteValue(listuuid);
                    self.reportError(4, { "data" => data, "list" => list, "exception" => saveIndex[1].getErrorMessage() });
                    return false;
                }

                Helper.Properties.Store(Helper.Properties.INIT, 1);

                Debug.Log("Added list " + listuuid + " (" + listname + ") with " + itemsArr.size() + " items");
                Helper.ToastUtil.Toast(Rez.Strings.ListRec, Helper.ToastUtil.SUCCESS);

                return true;
            } else {
                self.reportError(3, { "data" => data, "list" => list, "exception" => save[1].getErrorMessage() });
                return false;
            }
        }

        function GetLists() as ListIndex {
            var index = Application.Storage.getValue("listindex") as ListIndex;
            index = self.checkListIndex(index);
            return index;
        }

        function getList(uuid as String) as List? {
            try {
                var list = Application.Storage.getValue(uuid);
                return list;
            } catch (ex instanceof Lang.Exception) {
                Debug.Log("Could not load list " + uuid + ": " + ex.getErrorMessage());
                return null;
            }
        }

        function updateListitem(uuid as String, position as Number, state as Boolean) as Void {
            if (position < 0) {
                return;
            }
            var list = self.getList(uuid);
            if (list != null && list.hasKey("items")) {
                var items = list.get("items");
                if (items.size() > position) {
                    items[position].put("d", state);
                    list.put("items", items);
                    var name = list.get("name");
                    if (name == null) {
                        name = "";
                    }
                    try {
                        Application.Storage.setValue(uuid, list);
                        Debug.Log("Updated list " + uuid);
                    } catch (e instanceof Lang.StorageFullException) {
                        Helper.ToastUtil.Toast(Rez.Strings.EStorageFull, Helper.ToastUtil.ERROR);
                        Debug.Log("Could not update list '" + name + "' (" + uuid + "): storage is full: " + e.getErrorMessage());
                    } catch (e instanceof Lang.Exception) {
                        Helper.ToastUtil.Toast(Rez.Strings.EStorageError, Helper.ToastUtil.ERROR);
                        Debug.Log("Could not update list '" + name + "' (" + uuid + "): " + e.getErrorMessage());
                    }
                }
            }
        }

        function saveList(uuid as String, list as List) as Array<Boolean or Lang.Exception or Null> {
            var listname = list.get("name");
            if (listname == null) {
                listname = "?";
            }
            try {
                Application.Storage.setValue(uuid, list);

                if (Helper.Properties.Get(Helper.Properties.LASTLIST, "").equals(uuid)) {
                    Helper.Properties.Store(Helper.Properties.LASTLISTSCROLL, -1);
                }

                Debug.Log("Stored list " + uuid + "(" + listname + ")");
                return [true, null];
            } catch (e instanceof Lang.StorageFullException) {
                Debug.Log("Could not store list '" + listname + "' (" + uuid + "): storage is full: " + e);
                Helper.ToastUtil.Toast(Rez.Strings.EStorageFull, Helper.ToastUtil.ERROR);
                return [false, e];
            } catch (e) {
                Debug.Log("Could not store list '" + listname + "' (" + uuid + "): " + e);
                Helper.ToastUtil.Toast(Rez.Strings.EStorageError, Helper.ToastUtil.ERROR);
                return [false, e];
            }
        }

        function deleteList(uuid as String, with_toast as Boolean) as Void {
            var index = self.GetLists();
            var index_log = index;
            index.remove(uuid);
            var store = self.StoreIndex(index);
            if (store[0] == true) {
                Application.Storage.deleteValue(uuid);
                if (with_toast == true) {
                    Helper.ToastUtil.Toast(Rez.Strings.ListDel, Helper.ToastUtil.SUCCESS);
                }
                if (Helper.Properties.Get(Helper.Properties.LASTLIST, "").equals(uuid)) {
                    Helper.Properties.Store(Helper.Properties.LASTLISTSCROLL, -1);
                    Helper.Properties.Store(Helper.Properties.LASTLIST, "");
                }
                Debug.Log("Deleted list " + uuid);
            } else {
                self.reportError(5, { "index" => index_log, "delete" => uuid, "exception" => store[1].getErrorMessage() });
            }
        }

        function clearAll() as Void {
            Application.Storage.clearValues();
            Debug.Log("Deleted all lists!");
            Helper.ToastUtil.Toast(Rez.Strings.StDelAllDone, Helper.ToastUtil.SUCCESS);
            self.triggerOnListsChanged(null);
        }

        function addListChangedListener(obj as Object) as Void {
            var del = [];
            for (var i = 0; i < self.onListsChangedListeners.size(); i++) {
                var weak = self.onListsChangedListeners[i];
                if (weak.stillAlive()) {
                    var o = weak.get();
                    if (o == null || !(o has :onListsChanged)) {
                        del.add(weak);
                    }
                } else {
                    del.add(weak);
                }
            }
            if (del.size() > 0) {
                for (var i = 0; i < del.size(); i++) {
                    self.onListsChangedListeners.remove(del[i]);
                }
            }

            if (obj has :onListsChanged) {
                var ref = obj.weak();
                if (self.onListsChangedListeners.indexOf(ref) < 0) {
                    self.onListsChangedListeners.add(ref);
                }
            }
        }

        private function checkListIndex(index as ListIndex?) as ListIndex {
            if (index != null && index.size() > 0) {
                var delete = [] as Array<String>;
                for (var i = 0; i < index.keys().size(); i++) {
                    var key = index.keys()[i] as String;
                    var dict = index.get(key);
                    if (dict != null && dict instanceof Dictionary) {
                        //check of all keys are present
                        if (!dict.hasKey("key") || !(dict.get("key") instanceof String) || !dict.hasKey("name") || !(dict.get("name") instanceof String)) {
                            delete.add(key);
                            continue;
                        }

                        //check if the list still exists in storage
                        var storage_key = dict.get("key") as String;
                        if (Application.Storage.getValue(storage_key) == null) {
                            delete.add(key);
                        }
                    } else {
                        delete.add(key);
                    }
                }

                if (delete.size() > 0) {
                    for (var i = 0; i < delete.size(); i++) {
                        index.remove(delete[i]);
                    }

                    Debug.Log("Deleted " + delete.size() + " lists from index: " + delete);
                    self.StoreIndex(index);
                }

                return index;
            }

            return ({}) as ListIndex;
        }

        private function StoreIndex(index as ListIndex) as Array<Boolean or Lang.Exception or Null> {
            try {
                Application.Storage.setValue("listindex", index);
                Debug.Log("Stored list index with " + index.size() + " items");
            } catch (e instanceof Lang.StorageFullException) {
                Helper.ToastUtil.Toast(Rez.Strings.EStorageFull, Helper.ToastUtil.ERROR);
                Debug.Log("Could not store list index, storage is full: " + e.getErrorMessage());
                return [false, e];
            } catch (e instanceof Lang.Exception) {
                Debug.Log("Could not store list index: " + e.getErrorMessage());
                Helper.ToastUtil.Toast(Rez.Strings.EStorageError, Helper.ToastUtil.ERROR);
                return [false, e];
            }
            self.triggerOnListsChanged(index);

            return [true, null];
        }

        private function reportError(code as Number, payload as Dictionary<String, Object>?) as Void {
            var msg = null as Lang.ResourceId?;
            switch (code) {
                case 1:
                case 2:
                case 3:
                case 4:
                    msg = Rez.Strings.ErrListRec;
                    break;
                case 5:
                    msg = Rez.Strings.ErrListDel;
                    break;
            }
            var errorView = new Views.ErrorView(msg, code, payload);
            WatchUi.pushView(errorView, new Views.ItemViewDelegate(errorView), WatchUi.SLIDE_BLINK);
        }

        private function triggerOnListsChanged(index as ListIndex?) as Void {
            for (var i = 0; i < self.onListsChangedListeners.size(); i++) {
                var listener = self.onListsChangedListeners[i];
                if (listener.stillAlive()) {
                    var obj = listener.get();
                    if (obj != null && obj has :onListsChanged) {
                        obj.onListsChanged(index);
                    }
                }
            }
        }
    }
}
