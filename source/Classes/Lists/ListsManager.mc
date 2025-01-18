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
        var OnListsChanged as Array<Object> = [];

        function addList(data as Application.PropertyValueType) as Boolean {
            /* check, if all nessesary data is available... */
            var listuuid = null;
            var listname = null;
            var listorder = null;
            var listitems = null;
            if (data instanceof Dictionary) {
                listname = data.get("name");
                listorder = data.get("order");
                listuuid = data.get("uuid");
                listitems = data.get("items");
                if (listitems instanceof Array == false) {
                    listitems = null;
                }
                if (listname == null || listorder == null || listuuid == null || listitems == null) {
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
                    if (listitems == null) {
                        missing.add("items");
                    }
                    Debug.Log("Could not add list: missing properties - " + missing);
                    self.reportError(2, { "data" => data, "missing" => missing });
                    return false;
                }
            } else {
                Debug.Log("Could not add list: invalid data, " + data);
                self.reportError(1, data);
                return false;
            }

            //Store list
            var list = {};
            list.put("name", listname);

            //items
            var items = [];
            for (var i = 0; i < listitems.size(); i++) {
                var listitem = listitems[i] as ListItemsItem;
                if (listitem.hasKey("item")) {
                    if (!listitem.hasKey("note") || listitem["note"] == null) {
                        //only an item
                        items.add({ "i" => listitem["item"].toString(), "d" => false });
                    } else {
                        //item with note
                        items.add({ "i" => listitem["item"].toString(), "n" => listitem["note"].toString(), "d" => false });
                    }
                }
            }
            list.put("items", items);

            //reset list automatically
            var reset = data.get("reset") as Dictionary<String, String or Number or Boolean>?;
            if (reset instanceof Dictionary) {
                var active = reset.get("active") as Boolean?;
                var interval = reset.get("interval") as String?;
                var hour = reset.get("hour") as Number?;
                var minute = reset.get("minute") as Number?;
                var weekday = reset.get("weekday") as Number?;
                var day = reset.get("day") as Number?;
                var missing = [] as Array<String>;
                if (active != null && interval != null && hour != null && minute != null) {
                    if (interval == "w" && weekday == null) {
                        missing.add("weekday");
                    } else if (interval == "m" && day == null) {
                        missing.add("day");
                    }
                } else {
                    if (active == null) {
                        missing.add("active");
                    }
                    if (interval == null) {
                        missing.add("interval");
                    }
                    if (hour == null) {
                        missing.add("hour");
                    }
                    if (minute == null) {
                        missing.add("minute");
                    }
                }

                if (missing.size() > 0) {
                    Debug.Log("Could not add list reset: missing properties - " + missing);
                } else {
                    list.put("r_a", active);
                    list.put("r_i", interval);
                    list.put("r_h", hour);
                    list.put("r_m", minute);
                    if (interval.equals("w")) {
                        list.put("r_wd", weekday);
                    } else if (interval.equals("m")) {
                        list.put("r_d", day);
                    }
                    list.put("r_last", Time.now().value());
                }
            } else if (reset != null) {
                Debug.Log("Could not add list reset: invalid type - " + reset);
            }

            var date = data.get("date") as Number?;
            if (date != null) {
                if (date > 999999999) {
                    // date is in milliseconds
                    date /= 1000;
                    date = date.toNumber();
                }
            } else {
                date = Time.now().value();
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
                        "date" => date,
                    }) as ListIndexItem;

                listindex.put(listuuid, indexitem);

                var saveIndex = self.StoreIndex(listindex);
                if (saveIndex[0] == false) {
                    Application.Storage.deleteValue(listuuid);
                    self.reportError(4, { "data" => data, "list" => list, "exception" => saveIndex[1].getErrorMessage() });
                    return false;
                }

                Helper.Properties.Store(Helper.Properties.INIT, 1);

                Debug.Log("Added list " + listuuid + "(" + listname + ")");
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

        function updateList(uuid as String, position as Number, state as Boolean) as Void {
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

                Debug.Log("Saved list " + uuid + "(" + listname + ")");
                return [true, null];
            } catch (e instanceof Lang.StorageFullException) {
                Debug.Log("Could not update list '" + listname + "' (" + uuid + "): storage is full: " + e);
                Helper.ToastUtil.Toast(Rez.Strings.EStorageFull, Helper.ToastUtil.ERROR);
                return [false, e];
            } catch (e) {
                Debug.Log("Could not update list '" + listname + "' (" + uuid + "): " + e);
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
        }

        function Optimize(uuid as String, titles as Dictionary<Number, Array<String> >, notes as Dictionary<Number, Array<String> >) {
            var list = self.getList(uuid);
            if (list != null) {
                var items = list.get("items");
                if (items != null && items instanceof Array) {
                    for (var i = 0; i < items.size(); i++) {
                        var text = titles.hasKey(i) ? titles.get(i) : null;
                        var note = notes.hasKey(i) ? notes.get(i) : null;
                        if (text != null) {
                            var item = list["items"][i];
                            item.put("i", text);
                            if (note != null) {
                                item.put("n", note);
                            }
                            list["items"][i] = item;
                        }
                    }
                }
                var listname = list.get("name");
                if (listname == null) {
                    listname = "?";
                }
                list.put("opt", true);
                Debug.Log("Optimized list '" + listname + "' (" + uuid + ")");
                Application.Storage.setValue(uuid, list);
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
            if (self.OnListsChanged.size() > 0) {
                for (var i = 0; i < self.OnListsChanged.size(); i++) {
                    if (self.OnListsChanged[i] has :onListsChanged) {
                        self.OnListsChanged[i].onListsChanged(index);
                    }
                }
            }

            return [true, null];
        }

        private function reportError(code as Number, payload as Application.PersistableType) as Void {
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
    }
}
