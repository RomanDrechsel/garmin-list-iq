using Rez;
using Toybox.Application.Storage;
using Debug;
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
            var pre__data_, list, save, pre__name_, pre__order_, pre_0, pre_1, pre_4, pre_5;
            pre_0 = 0;
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

            pre_5 = 5;
            pre_4 = 4;
            pre_1 = 1;
            pre__order_ = "order";
            pre__name_ = "name";
            {
                pre__data_ /*>i<*/ = pre_0;
                for (; pre__data_ /*>i<*/ < keys.size(); pre__data_ /*>i<*/ += pre_1) {
                    save /*>key<*/ = keys[pre__data_ /*>i<*/];
                    var val = data.get(save /*>key<*/);
                    if (save /*>key<*/.equals("uuid")) {
                        listuuid = val.toString();
                    } else if (save /*>key<*/.equals(pre__name_)) {
                        listname = val.toString();
                    } else if (save /*>key<*/.equals(pre__order_)) {
                        listorder = val.toNumber();
                    } else if (save /*>key<*/.equals("date")) {
                        listdate = val.toLong();
                        if (listdate != null) {
                            if (listdate > 999999999) {
                                // date is in milliseconds
                                listdate = (listdate / 1000).toNumber();
                            }
                        }
                    } else if (save /*>key<*/.substring(pre_0, pre_4).equals("item")) {
                        var index = save /*>key<*/.substring(pre_4, pre_5).toNumber();
                        save /*>split<*/ = Helper.StringUtil.split(save /*>key<*/.substring(pre_5, save /*>key<*/.length()), "_", 2);
                        list /*>prop<*/ = save /*>split<*/.size() > pre_1 ? save /*>split<*/[pre_1] : null;
                        if (list /*>prop<*/ != null) {
                            if (listitems.hasKey(index)) {
                                save /*>item<*/ = listitems.get(index);
                            } else {
                                save /*>item<*/ = { "d" => false };
                            }
                            if (list /*>prop<*/.equals("item")) {
                                save /*>item<*/.put("i", val.toString());
                            } else if (list /*>prop<*/.equals("note")) {
                                save /*>item<*/.put("n", val.toString());
                            }
                            listitems.put(index, save /*>item<*/);
                        }
                    } else if (save /*>key<*/.substring(pre_0, pre_5).equals("reset")) {
                        if (save /*>key<*/.equals("reset_active")) {
                            val = Helper.StringUtil.StringToBool(val);
                            if (val != null) {
                                reset = val;
                            }
                        } else if (save /*>key<*/.equals("reset_interval")) {
                            reset_interval = val.toString(); //no reference
                        } else if (save /*>key<*/.equals("reset_hour")) {
                            val = val.toNumber();
                            if (val != null) {
                                reset_hour = val;
                            }
                        } else if (save /*>key<*/.equals("reset_minute")) {
                            val = val.toNumber();
                            if (val != null) {
                                reset_minute = val;
                            }
                        } else if (save /*>key<*/.equals("reset_weekday")) {
                            val = val.toNumber();
                            if (val != null) {
                                reset_weekday = val;
                            }
                        } else if (save /*>key<*/.equals("reset_day")) {
                            val = val.toNumber();
                            if (val != null) {
                                reset_day = val;
                            }
                        }
                    }
                }
            }

            //verify data
            pre__data_ = "data";
            if (listname == null || listorder == null || listuuid == null) {
                save /*>missing<*/ = [] as Array<String>;
                if (listname == null) {
                    save /*>missing<*/.add(pre__name_);
                }
                if (listorder == null) {
                    save /*>missing<*/.add(pre__order_);
                }
                if (listuuid == null) {
                    save /*>missing<*/.add("uuid");
                }
                Debug.Log("Could not add list: missing properties - " + save /*>missing<*/);
                self.reportError(2, { pre__data_ => data, "missing" => save /*>missing<*/ });
                return false;
            }

            if (listdate == null) {
                listdate = Time.now().value();
            }

            list = {};
            list.put(pre__name_, listname);
            list.put("items", listitems);

            if (reset != null) {
                save /*>missing<*/ = [] as Array<String>;
                if (reset_interval != null && reset_hour != null && reset_minute != null) {
                    if (reset_interval == "w" && reset_weekday == null) {
                        save /*>missing<*/.add("weekday");
                    } else if (reset_interval == "m" && reset_day == null) {
                        save /*>missing<*/.add("day");
                    }
                } else {
                    if (reset_interval == null) {
                        save /*>missing<*/.add("interval");
                    }
                    if (reset_hour == null) {
                        save /*>missing<*/.add("hour");
                    }
                    if (reset_minute == null) {
                        save /*>missing<*/.add("minute");
                    }
                }

                if (save /*>missing<*/.size() > pre_0) {
                    Debug.Log("Could not add list reset: missing properties - " + save /*>missing<*/);
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

            save = self.saveList(listuuid, list);
            if (save[pre_0] == true) {
                //Store Index...
                save /*>listindex<*/ = self.GetLists();
                save /*>listindex<*/.put(listuuid, ({ "key" => listuuid, pre__name_ => listname, pre__order_ => listorder, "items" => listitems.size(), "date" => listdate }) as ListIndexItem);

                save /*>saveIndex<*/ = self.StoreIndex(save /*>listindex<*/);
                if (save /*>saveIndex<*/[pre_0] == false) {
                    Storage /*>Application.Storage<*/.deleteValue(listuuid);
                    self.reportError(pre_4, { pre__data_ => data, "list" => list, "exception" => save /*>saveIndex<*/[pre_1].getErrorMessage() });
                    return false;
                }

                Helper.Properties.Store("Init", pre_1);

                Debug.Log("Added list " + listuuid + "(" + listname + ")");
                Helper.ToastUtil.Toast(Rez.Strings.ListRec, pre_0);

                return true;
            } else {
                self.reportError(3, { pre__data_ => data, "list" => list, "exception" => save[pre_1].getErrorMessage() });
                return false;
            }
        }

        function GetLists() as ListIndex {
            return self.checkListIndex(Storage /*>Application.Storage<*/.getValue("listindex") as ListIndex);
        }

        function getList(uuid as String) as List? {
            try {
                return Storage /*>Application.Storage<*/.getValue(uuid);
            } catch (ex instanceof Lang.Exception) {
                Debug.Log("Could not load list " + uuid + ": " + ex.getErrorMessage());
                return null;
            }
        }

        function updateListitem(uuid as String, position as Number, state as Boolean) as Void {
            var pre__items_;
            if (position < 0) {
                return;
            }
            var list = self.getList(uuid);
            pre__items_ = "items";
            if (list != null && list.hasKey(pre__items_)) {
                var items;
                items = list.get(pre__items_);
                if (items.size() > position) {
                    items[position].put("d", state);
                    list.put(pre__items_, items);
                    items /*>name<*/ = list.get("name");
                    if (items /*>name<*/ == null) {
                        items /*>name<*/ = "";
                    }
                    try {
                        Storage /*>Application.Storage<*/.setValue(uuid, list);
                        Debug.Log("Updated list " + uuid);
                    } catch (e instanceof Lang.StorageFullException) {
                        Helper.ToastUtil.Toast(Rez.Strings.EStorageFull, 1);
                        Debug.Log("Could not update list '" + items /*>name<*/ + "' (" + uuid + "): storage is full: " + e.getErrorMessage());
                    } catch (e instanceof Lang.Exception) {
                        Helper.ToastUtil.Toast(Rez.Strings.EStorageError, 1);
                        Debug.Log("Could not update list '" + items /*>name<*/ + "' (" + uuid + "): " + e.getErrorMessage());
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
                Storage /*>Application.Storage<*/.setValue(uuid, list);

                if (Helper.Properties.Get("LastList", "").equals(uuid)) {
                    Helper.Properties.Store("LastListScroll", -1);
                }

                Debug.Log("Stored list " + uuid + "(" + listname + ")");
                return [true, null];
            } catch (e instanceof Lang.StorageFullException) {
                Debug.Log("Could not store list '" + listname + "' (" + uuid + "): storage is full: " + e);
                Helper.ToastUtil.Toast(Rez.Strings.EStorageFull, 1);
                return [false, e];
            } catch (e) {
                Debug.Log("Could not store list '" + listname + "' (" + uuid + "): " + e);
                Helper.ToastUtil.Toast(Rez.Strings.EStorageError, 1);
                return [false, e];
            }
        }

        function deleteList(uuid as String, with_toast as Boolean) as Void {
            var index = self.GetLists();
            index.remove(uuid);
            var store = self.StoreIndex(index);
            if (store[0] == true) {
                Storage /*>Application.Storage<*/.deleteValue(uuid);
                if (with_toast == true) {
                    Helper.ToastUtil.Toast(Rez.Strings.ListDel, 0);
                }
                if (Helper.Properties.Get("LastList", "").equals(uuid)) {
                    Helper.Properties.Store("LastListScroll", -1);
                    Helper.Properties.Store("LastList", "");
                }
                Debug.Log("Deleted list " + uuid);
            } else {
                self.reportError(5, { "index" => index, "delete" => uuid, "exception" => store[1].getErrorMessage() });
            }
        }

        function clearAll() as Void {
            Storage /*>Application.Storage<*/.clearValues();
            Debug.Log("Deleted all lists!");
            Helper.ToastUtil.Toast(Rez.Strings.StDelAllDone, 0);
            self.triggerOnListsChanged(null);
        }

        function addListChangedListener(obj as Object) as Void {
            var ref, pre_onListsChangedListeners, pre_0;
            pre_0 = 0;
            var del = [];
            pre_onListsChangedListeners = self.onListsChangedListeners;
            {
                ref /*>i<*/ = pre_0;
                for (; ref /*>i<*/ < pre_onListsChangedListeners.size(); ref /*>i<*/ += 1) {
                    var weak = self.onListsChangedListeners[ref /*>i<*/];
                    if (weak.stillAlive()) {
                        var o = weak.get();
                        if (o == null || !(o has :onListsChanged)) {
                            del.add(weak);
                        }
                    } else {
                        del.add(weak);
                    }
                }
            }
            if (del.size() > pre_0) {
                {
                    ref /*>i<*/ = pre_0;
                    for (; ref /*>i<*/ < del.size(); ref /*>i<*/ += 1) {
                        self.onListsChangedListeners.remove(del[ref /*>i<*/]);
                    }
                }
            }

            if (obj has :onListsChanged) {
                ref = obj.weak();
                if (pre_onListsChangedListeners.indexOf(ref) < pre_0) {
                    self.onListsChangedListeners.add(ref);
                }
            }
        }

        private function checkListIndex(index as ListIndex?) as ListIndex {
            var pre__key_, pre_0;
            pre_0 = 0;
            if (index != null && index.size() > pre_0) {
                var i_0,
                    delete = [] as Array<String>;
                pre__key_ = "key";
                {
                    i_0 /*>i<*/ = pre_0;
                    for (; i_0 /*>i<*/ < index.keys().size(); i_0 /*>i<*/ += 1) {
                        var key = index.keys()[i_0 /*>i<*/] as String;
                        var dict = index.get(key);
                        if (dict != null) {
                            //check of all keys are present
                            if (!dict.hasKey(pre__key_) || !(dict.get(pre__key_) instanceof String) || !dict.hasKey("name") || !(dict.get("name") instanceof String)) {
                                delete.add(key);
                                continue;
                            }

                            //check if the list still exists in storage
                            if (Storage /*>Application.Storage<*/.getValue(dict.get(pre__key_) as String) == null) {
                                delete.add(key);
                            }
                        } else {
                            delete.add(key);
                        }
                    }
                }

                if (delete.size() > pre_0) {
                    {
                        i_0 /*>i<*/ = pre_0;
                        for (; i_0 /*>i<*/ < delete.size(); i_0 /*>i<*/ += 1) {
                            index.remove(delete[i_0 /*>i<*/]);
                        }
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
                Storage /*>Application.Storage<*/.setValue("listindex", index);
                Debug.Log("Stored list index with " + index.size() + " items");
            } catch (e instanceof Lang.StorageFullException) {
                Helper.ToastUtil.Toast(Rez.Strings.EStorageFull, 1);
                Debug.Log("Could not store list index, storage is full: " + e.getErrorMessage());
                return [false, e];
            } catch (e instanceof Lang.Exception) {
                Debug.Log("Could not store list index: " + e.getErrorMessage());
                Helper.ToastUtil.Toast(Rez.Strings.EStorageError, 1);
                return [false, e];
            }
            self.triggerOnListsChanged(index);

            return [true, null];
        }

        private function reportError(code as Number, payload as Dictionary<String, Object>?) as Void {
            var errorView;
            errorView /*>msg<*/ = null;
            switch (code) {
                case 1:
                case 2:
                case 3:
                case 4:
                    errorView /*>msg<*/ = Rez.Strings.ErrListRec;
                    break;
                case 5:
                    errorView /*>msg<*/ = Rez.Strings.ErrListDel;
                    break;
            }
            errorView = new Views.ErrorView(errorView /*>msg<*/, code, payload);
            WatchUi.pushView(errorView, new Views.ItemViewDelegate(errorView), 5 as Toybox.WatchUi.SlideType);
        }

        private function triggerOnListsChanged(index as ListIndex?) as Void {
            for (var i = 0; i < self.onListsChangedListeners.size(); i += 1) {
                var listener;
                listener = self.onListsChangedListeners[i];
                if (listener.stillAlive()) {
                    listener /*>obj<*/ = listener.get();
                    if (listener /*>obj<*/ != null && listener /*>obj<*/ has :onListsChanged) {
                        listener /*>obj<*/.onListsChanged(index);
                    }
                }
            }
        }
    }
}
