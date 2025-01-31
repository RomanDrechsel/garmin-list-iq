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

        function addList(data as Application.PropertyValueType) as Boolean {
            var pre__item_, pre__note_, items, date, save, pre__data_, pre__items_, pre__name_, pre__order_, pre_0, pre_1;
            pre_1 = 1;
            /* check, if all nessesary data is available... */
            var listuuid;
            var listname;
            var listorder;
            var listitems;
            if (data instanceof Dictionary) {
                pre__order_ = "order";
                pre__name_ = "name";
                pre__items_ = "items";
                listname = data.get(pre__name_);
                listorder = data.get(pre__order_);
                listuuid = data.get("uuid");
                listitems = data.get(pre__items_);
                if (listitems instanceof Array == false) {
                    listitems = null;
                }
                pre__data_ = "data";
                if (listname == null || listorder == null || listuuid == null || listitems == null) {
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
                    if (listitems == null) {
                        save /*>missing<*/.add(pre__items_);
                    }
                    Debug.Log("Could not add list: missing properties - " + save /*>missing<*/);
                    self.reportError(2, { pre__data_ => data, "missing" => save /*>missing<*/ });
                    return false;
                }
            } else {
                Debug.Log("Could not add list: invalid data, " + data);
                self.reportError(pre_1, data);
                return false;
            }

            //Store list
            pre_0 = 0;
            var list = {};
            list.put(pre__name_, listname);

            //items
            items = [];
            pre__note_ = "note";
            pre__item_ = "item";
            {
                save /*>i<*/ = pre_0;
                for (; save /*>i<*/ < listitems.size(); save /*>i<*/ += pre_1) {
                    date /*>listitem<*/ = listitems[save /*>i<*/] as ListItemsItem;
                    if (date /*>listitem<*/.hasKey(pre__item_)) {
                        if (!date /*>listitem<*/.hasKey(pre__note_) || date /*>listitem<*/[pre__note_] == null) {
                            //only an item
                            items.add({ "i" => date /*>listitem<*/[pre__item_].toString(), "d" => false });
                        } else {
                            //item with note
                            items.add({ "i" => date /*>listitem<*/[pre__item_].toString(), "n" => date /*>listitem<*/[pre__note_].toString(), "d" => false });
                        }
                    }
                }
            }
            list.put(pre__items_, items);

            //reset list automatically
            save /*>reset<*/ = data.get("reset") as Dictionary<String, String or Number or Boolean>?;
            if (save /*>reset<*/ instanceof Dictionary) {
                items /*>active<*/ = save /*>reset<*/.get("active") as Boolean?;
                pre__note_ /*>interval<*/ = save /*>reset<*/.get("interval") as String?;
                pre__item_ /*>hour<*/ = save /*>reset<*/.get("hour") as Number?;
                var minute = save /*>reset<*/.get("minute") as Number?;
                var weekday = save /*>reset<*/.get("weekday") as Number?;
                save /*>day<*/ = save /*>reset<*/.get("day") as Number?;
                date /*>missing<*/ = [] as Array<String>;
                if (items /*>active<*/ != null && pre__note_ /*>interval<*/ != null && pre__item_ /*>hour<*/ != null && minute != null) {
                    if (pre__note_ /*>interval<*/ == "w" && weekday == null) {
                        date /*>missing<*/.add("weekday");
                    } else if (pre__note_ /*>interval<*/ == "m" && save /*>day<*/ == null) {
                        date /*>missing<*/.add("day");
                    }
                } else {
                    if (items /*>active<*/ == null) {
                        date /*>missing<*/.add("active");
                    }
                    if (pre__note_ /*>interval<*/ == null) {
                        date /*>missing<*/.add("interval");
                    }
                    if (pre__item_ /*>hour<*/ == null) {
                        date /*>missing<*/.add("hour");
                    }
                    if (minute == null) {
                        date /*>missing<*/.add("minute");
                    }
                }

                if (date /*>missing<*/.size() > pre_0) {
                    Debug.Log("Could not add list reset: missing properties - " + date /*>missing<*/);
                } else {
                    list.put("r_a", items /*>active<*/);
                    list.put("r_i", pre__note_ /*>interval<*/);
                    list.put("r_h", pre__item_ /*>hour<*/);
                    list.put("r_m", minute);
                    if (pre__note_ /*>interval<*/.equals("w")) {
                        list.put("r_wd", weekday);
                    } else if (pre__note_ /*>interval<*/.equals("m")) {
                        list.put("r_d", save /*>day<*/);
                    }
                    list.put("r_last", Time.now().value());
                }
            }

            date = data.get("date") as Number?;
            if (date != null) {
                if (date > 999999999) {
                    // date is in milliseconds
                    date = (date / 1000).toNumber();
                }
            } else {
                date = Time.now().value();
            }

            save = self.saveList(listuuid, list);
            if (save[pre_0] == true) {
                //Store Index...
                save /*>listindex<*/ = self.GetLists();
                save /*>listindex<*/.put(listuuid, ({ "key" => listuuid, pre__name_ => listname, pre__order_ => listorder, pre__items_ => listitems.size(), "date" => date }) as ListIndexItem);

                save /*>saveIndex<*/ = self.StoreIndex(save /*>listindex<*/);
                if (save /*>saveIndex<*/[pre_0] == false) {
                    Storage /*>Application.Storage<*/.deleteValue(listuuid);
                    self.reportError(4, { pre__data_ => data, "list" => list, "exception" => save /*>saveIndex<*/[pre_1].getErrorMessage() });
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

        private function reportError(code as Number, payload as Application.PersistableType) as Void {
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
