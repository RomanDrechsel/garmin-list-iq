import Toybox;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Time;
import Toybox.System;
import Helper;
import Controls.Listitems;
import Views;

module Lists {
    typedef ListItemsItem as String or Dictionary<String, String>;
    typedef List as Dictionary<String, String or Array<Dictionary<String, String or Boolean or Number or ListItemsItem> > >;
    typedef ListIndexItemType as Dictionary<String, String or Number>;
    typedef ListIndexType as Dictionary<String, ListIndexItemType>;

    class ListsManager {
        var OnListsChanged as Array<Object> = [];
        private var _lastAddedUuid as String? = null;

        function addList(data as Application.PropertyValueType) as Boolean {
            /* check, if all nessesary data is available... */
            var listuuid = null;
            var listname = null;
            var listorder = null;
            var listitems = null;
            if (data instanceof Dictionary) {
                listname = data.get("name") as String?;
                listorder = data.get("order") as Number?;
                listuuid = data.get("uuid") as String?;
                listitems = data.get("items") as ListIndexType?;
                if (listname == null || listorder == null || listuuid == null || listitems == null) {
                    Debug.Log("Could not add list: missing property, " + data);
                    return false;
                }
            } else {
                Debug.Log("Could not add list: invalid data, " + data);
                return false;
            }

            //Store list
            var list = {};
            list.put("name", listname);
            var items = [];
            for (var i = 0; i < listitems.size(); i++) {
                var listitem = listitems[i];
                if (listitem.hasKey("item")) {
                    if (!listitem.hasKey("note") || listitem["note"] == null) {
                        //only an item
                        items.add({ "i" => listitem["item"], "d" => false });
                    } else {
                        //item with note
                        var item = [] as Array<String>;
                        item.add(listitem["item"].toString());
                        item.add(listitem["note"].toString());
                        items.add({ "i" => item, "d" => false });
                    }
                }
            }
            list.put("items", items);

            try {
                Application.Storage.setValue(listuuid, list);
            } catch (e instanceof Lang.StorageFullException) {
                Debug.Log("Could not update list " + listuuid + ": storage is full: " + e);
                Helper.ToastUtil.Toast(Rez.Strings.EStorageFull, Helper.ToastUtil.ERROR);
                return false;
            } catch (e) {
                Debug.Log("Could not update list " + listuuid + ": " + e);
                Helper.ToastUtil.Toast(Rez.Strings.EStorageError, Helper.ToastUtil.ERROR);
                return false;
            }

            //Store Index...
            var listindex = self.GetLists();
            var indexitem =
                ({
                    "key" => listuuid,
                    "name" => listname,
                    "order" => listorder,
                    "items" => listitems.size(),
                    "date" => Time.now().value(),
                }) as ListIndexItemType;

            listindex.put(listuuid, indexitem);

            if (self.StoreIndex(listindex) == false) {
                Application.Storage.deleteValue(listuuid);
                return false;
            }

            Application.Properties.setValue("Init", 1);

            Debug.Log("Added list " + listuuid);
            Helper.ToastUtil.Toast(Rez.Strings.ListRec, Helper.ToastUtil.SUCCESS);
            self._lastAddedUuid = listuuid;
            self.checkLowMemory();

            return true;
        }

        function GetLists() as ListIndexType {
            var index = Application.Storage.getValue("listindex") as ListIndexType;
            index = self.checkListIndex(index);
            return index;
        }

        function getList(uuid as String) as List? {
            var list = Application.Storage.getValue(uuid) as List;
            return list;
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
                    try {
                        Application.Storage.setValue(uuid, list);
                        Debug.Log("Updated list " + uuid);
                    } catch (e instanceof Lang.StorageFullException) {
                        Helper.ToastUtil.Toast(Rez.Strings.EStorageFull, Helper.ToastUtil.ERROR);
                        Debug.Log("Could not update list " + uuid + ": storage is full: " + e);
                    } catch (e) {
                        Helper.ToastUtil.Toast(Rez.Strings.EStorageError, Helper.ToastUtil.ERROR);
                        Debug.Log("Could not update list " + uuid + ": " + e);
                    }
                }
            }
        }

        function deleteList(uuid as String) as Void {
            Application.Storage.deleteValue(uuid);
            var index = self.GetLists();
            index.remove(uuid);
            if (self.StoreIndex(index)) {
                Helper.ToastUtil.Toast(Rez.Strings.ListDel, Helper.ToastUtil.SUCCESS);
                Debug.Log("Deleted list " + uuid + "!");
            }
        }

        function clearAll() as Void {
            Application.Storage.clearValues();
            Debug.Log("Deleted all lists!");
            Helper.ToastUtil.Toast(Rez.Strings.StDelAllDone, Helper.ToastUtil.SUCCESS);
        }

        public function deleteOldestList() as Void {
            var index = self.GetLists();
            var keys = index.keys();
            var oldest as String = "";
            var oldest_ts as Number = 0;
            for (var i = 0; i < keys.size(); i++) {
                var key = keys[i];
                if (key == self._lastAddedUuid) {
                    continue;
                }

                var list = index.get(key);
                var date = list.get("date");
                if (oldest_ts <= 0 || oldest_ts > date) {
                    oldest_ts = date;
                    oldest = key;
                }
            }

            if (oldest.length() > 0) {
                self.deleteList(oldest);
            }

            WatchUi.popView(WatchUi.SLIDE_BLINK);
        }

        public function deleteOtherLists() as Void {
            Debug.Log("Delete all other lists");
            WatchUi.popView(WatchUi.SLIDE_BLINK);
        }

        private function checkListIndex(index as ListIndexType?) as ListIndexType {
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

                    Debug.Log("Deleted " + delete.size() + " lists from index doe to invalid data: " + delete);
                    self.StoreIndex(index);
                }

                return index;
            }

            return ({}) as ListIndexType;
        }

        private function StoreIndex(index as ListIndexType) as Boolean {
            try {
                Application.Storage.setValue("listindex", index);
                Debug.Log("Stored list index with " + index.size() + " items in it");
            } catch (e instanceof Lang.StorageFullException) {
                Helper.ToastUtil.Toast(Rez.Strings.EStorageFull, Helper.ToastUtil.ERROR);
                Debug.Log("Could not store list index, storage is full: " + e);
                return false;
            } catch (e) {
                Debug.Log("Could not store list index: " + e);
                Helper.ToastUtil.Toast(Rez.Strings.EStorageError, Helper.ToastUtil.ERROR);
                return false;
            }
            if (self.OnListsChanged.size() > 0) {
                for (var i = 0; i < self.OnListsChanged.size(); i++) {
                    if (self.OnListsChanged[i] has :onListsChanged) {
                        self.OnListsChanged[i].onListsChanged(index);
                    }
                }
            }

            return true;
        }

        private function checkLowMemory() as Void {
            var stats = System.getSystemStats();
            var occupied = stats.freeMemory.toFloat() / stats.totalMemory.toFloat();
            if (occupied > 0.1) {
                Debug.Log("LOW MEMORY: " + (occupied * 100).format("%.2f") + "% -" + stats.freeMemory + " bytes / " + stats.totalMemory + " bytes");

                var str = Application.loadResource(Rez.Strings.lowmem);
                str = Helper.StringUtil.stringReplace(str, "{{r}}", Helper.StringUtil.formatBytes(stats.freeMemory));

                var margin = (System.getDeviceSettings().screenHeight * 0.05).toNumber();

                var btn_del = new Listitems.Button(null, Application.loadResource(Rez.Strings.lowmem_del), "del", margin, true);
                var btn_delall = new Listitems.Button(null, Application.loadResource(Rez.Strings.lowmem_delall), "delall", margin, false);

                var view = new Views.StatusView(str, null, [btn_del, btn_delall], { "del" => method(:deleteOldestList), "delall" => method(:deleteOtherLists) });
                var delegate = new Views.StatusViewDelegate(view);
                WatchUi.pushView(view, delegate, WatchUi.SLIDE_BLINK);
            }
        }
    }
}
