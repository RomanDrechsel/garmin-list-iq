import Toybox;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Time;
import Toybox.System;
import Toybox.Timer;
import Exceptions;
import Controls.Listitems;
import Views;

module Lists {
    typedef ListIndexItem as Dictionary<Number, String or Number>;
    typedef ListIndex as Dictionary<String or Number, ListIndexItem>;

    public enum {
        RECEIVED_LEGACY_LIST = "rec_legacy_list",
    }

    class ListsManager {
        private var onListChangedListeners as Array<WeakReference>?;
        private var onListIndexChangedListeners as Array<WeakReference>?;
        private var _app as ListsApp;

        function initialize(app as ListsApp) {
            self._app = app;
        }

        function addList(data as Array, from_bg as Boolean) as Void {
            var list = null;
            try {
                var importer = new ListFromPhoneImporter();
                list = importer.Import(data);
            } catch (ex instanceof Exceptions.OutOfMemoryException) {
                Debug.Log("Could not add list (OoM): " + ex.toString());
            } catch (ex instanceof Exceptions.LegacyNotSupportedException) {
                Debug.Log("Could not add list, due to legacy format");
                if (self._app.AppType == ListsApp.APP && self._app.Initialized == true) {
                    Views.ErrorView.Show(Views.ErrorView.LEGACY_APP, null);
                    Application.Storage.deleteValue(RECEIVED_LEGACY_LIST);
                } else {
                    Application.Storage.setValue(RECEIVED_LEGACY_LIST, true);
                }
            }
            if (list != null) {
                var save = self.StoreList(list);
                if (save[0] == true) {
                    //Store Index...
                    var listindex = self.GetListsIndex();
                    listindex.put(list.Uuid, list.ToIndex());
                    var saveIndex = self.storeIndex(listindex);
                    if (saveIndex[0] == false) {
                        Application.Storage.deleteValue(list.Uuid);
                        if (self._app.AppType == ListsApp.APP && !(saveIndex[1] instanceof Exceptions.OutOfMemoryException)) {
                            Views.ErrorView.Show(Views.ErrorView.LIST_REC_INDEX_STORE_FAILED, ["list=" + list.ToBackend(), "exception=" + saveIndex[1].getErrorMessage()]);
                        }
                    } else {
                        if (self._app.AppType == ListsApp.APP) {
                            Helper.Properties.Store(Helper.Properties.INIT, 1);

                            if (from_bg == false) {
                                Helper.ToastUtil.Toast(Rez.Strings.ListRec, Helper.ToastUtil.SUCCESS);
                            }
                        }
                    }
                } else if (!(save[1] instanceof Exceptions.OutOfMemoryException)) {
                    if (self._app.AppType == ListsApp.APP) {
                        Views.ErrorView.Show(Views.ErrorView.LIST_REC_STORE_FAILED, ["list=" + list.ToBackend(), "exception=" + save[1].getErrorMessage()]);
                    }
                }
            } else {
                if (self._app.AppType == ListsApp.APP) {
                    Views.ErrorView.Show(Views.ErrorView.LIST_REC_INVALID, null);
                }
            }
        }

        function GetListsIndex() as ListIndex {
            var index = Application.Storage.getValue("listindex") as ListIndex?;
            if (index == null || !(index instanceof Dictionary) || index.size() == 0) {
                return {};
            }
            try {
                Common.MemoryChecker.Check();
            } catch (ex instanceof Exceptions.OutOfMemoryException) {
                Debug.Log("Could not get list index: " + ex.toString());
                return {};
            }
            return index;
        }

        function GetList(uuid as String) as List? {
            try {
                var list = new List(Application.Storage.getValue(uuid));
                Common.MemoryChecker.Check();
                if (list.IsValid()) {
                    return list;
                } else {
                    return null;
                }
            } catch (ex instanceof Exceptions.OutOfMemoryException) {
                Debug.Log("Could not get list " + uuid + ": " + ex.toString());
                return null;
            } catch (ex instanceof Exceptions.LegacyNotSupportedException) {
                self.clearAll(true);
                Debug.Log("Legacy list data found in storage - cleared memory...");
                if (self._app.GlobalStates.indexOf(ListsApp.LEGACYLIST) < 0) {
                    self._app.GlobalStates.add(ListsApp.LEGACYLIST);
                    self._app.GlobalStates.add(ListsApp.STARTPAGE);
                }
                return null;
            } catch (ex instanceof Lang.Exception) {
                Debug.Log("Could not load list " + uuid + ": " + ex.getErrorMessage());
                return null;
            }
        }

        function updateListitem(uuid as String, order as Number, done as Boolean) as Void {
            if (order < 0) {
                return;
            }
            try {
                var list = self.GetList(uuid);
                if (list != null) {
                    var item = list.GetItem(order);
                    Common.MemoryChecker.Check();

                    if (item != null) {
                        item.Done = done;
                        var save = list.ToBackend();
                        if (save != null) {
                            try {
                                Application.Storage.setValue(uuid, save);
                                Debug.Log("Updated list " + list.toString());
                            } catch (e instanceof Lang.StorageFullException) {
                                if (self._app.AppType == ListsApp.APP) {
                                    Helper.ToastUtil.Toast(Rez.Strings.EStorageFull, Helper.ToastUtil.ERROR);
                                }
                                Debug.Log("Could not update list " + list.toString() + ": storage is full: " + e.getErrorMessage());
                            } catch (e instanceof Lang.Exception) {
                                if (self._app.AppType == ListsApp.APP) {
                                    Helper.ToastUtil.Toast(Rez.Strings.EStorageError, Helper.ToastUtil.ERROR);
                                }
                                Debug.Log("Could not update list " + list.toString() + ": " + e.getErrorMessage());
                            }
                        }
                    }
                } else {
                    Debug.Log("Could not update list " + uuid + " - not found");
                }
            } catch (ex instanceof Exceptions.OutOfMemoryException) {
                Debug.Log("Could not set item in list " + uuid + " to " + done.toString() + ": " + ex.toString());
            }
        }

        function ResetList(uuid as String or Number) as Boolean {
            try {
                var list = self.GetList(uuid);
                if (list != null) {
                    var store = false;
                    for (var i = 0; i < list.Items.size(); i++) {
                        if (list.Items[i].Done == true) {
                            list.Items[i].Done = false;
                            store = true;
                        }
                    }
                    if (store) {
                        store = self.StoreList(list);
                        if (store[0] == true) {
                            Debug.Log("Reset list " + list.toString() + " manually");
                        } else {
                            Debug.Log("Could not reset list " + list.toString() + " manually");
                        }

                        return store[0];
                    } else {
                        return true;
                    }
                } else {
                    Debug.Log("Could not reset list " + uuid + " - not found");
                }
            } catch (ex instanceof Exceptions.OutOfMemoryException) {
                Debug.Log("Could not reset list " + uuid + " manually: " + ex.toString());
            }
            return false;
        }

        function StoreList(list as List) as Array<Boolean or Exception or String or Null> {
            if (!list.IsValid()) {
                return [false, "invalid-list"];
            }

            try {
                Common.MemoryChecker.Check();
                Application.Storage.setValue(list.Uuid, list.ToBackend());

                if (self._app.AppType != ListsApp.APP && Helper.Properties.Get(Helper.Properties.LASTLIST, "").equals(list.Uuid)) {
                    Helper.Properties.Store(Helper.Properties.LASTLISTSCROLL, -1);
                }

                Debug.Log("Stored list " + list.toString());
                Common.MemoryChecker.Check();
                self.triggerOnListChanged(list);
                return [true, null];
            } catch (ex instanceof Exceptions.OutOfMemoryException) {
                Debug.Log("Could not store list " + list.toString() + ": OoM: " + ex.toString());
                return [false, ex];
            } catch (ex instanceof Lang.StorageFullException) {
                Debug.Log("Could not store list " + list.toString() + ": storage is full: " + ex.getErrorMessage());
                if (self._app.AppType == ListsApp.APP) {
                    Helper.ToastUtil.Toast(Rez.Strings.EStorageFull, Helper.ToastUtil.ERROR);
                }
                return [false, ex];
            } catch (ex) {
                Debug.Log("Could not store list " + list.toString() + ": " + ex.getErrorMessage());
                if (self._app.AppType == ListsApp.APP) {
                    Helper.ToastUtil.Toast(Rez.Strings.EStorageError, Helper.ToastUtil.ERROR);
                }
                return [false, ex];
            }
        }

        function deleteList(uuid as String or Number, with_toast as Boolean) as Boolean {
            var index = self.GetListsIndex();
            index.remove(uuid);

            var store = self.storeIndex(index);
            if (store[0] == true) {
                Application.Storage.deleteValue(uuid);
                if (with_toast == true && self._app.AppType == ListsApp.APP) {
                    Helper.ToastUtil.Toast(Rez.Strings.ListDel, Helper.ToastUtil.SUCCESS);
                }
                if (self._app.AppType == ListsApp.APP && Helper.Properties.Get(Helper.Properties.LASTLIST, "").equals(uuid)) {
                    Helper.Properties.Store(Helper.Properties.LASTLISTSCROLL, -1);
                    Helper.Properties.Store(Helper.Properties.LASTLIST, "");
                }
                Debug.Log("Deleted list " + uuid);
                self.triggerOnListChanged(null);
                return true;
            } else {
                if (self._app.AppType == ListsApp.APP && !(store[1] instanceof Exceptions.OutOfMemoryException)) {
                    Views.ErrorView.Show(Views.ErrorView.LIST_DEL_FAILED, ["index=" + index.toString(), "delete=" + uuid, "exception=" + store[1].getErrorMessage()]);
                }
                return false;
            }
        }

        function clearAll(silent as Boolean) as Void {
            Application.Storage.clearValues();
            Debug.Log("Deleted all lists!");
            if (!silent) {
                if (self._app.AppType == ListsApp.APP) {
                    Helper.ToastUtil.Toast(Rez.Strings.StDelAllDone, Helper.ToastUtil.SUCCESS);
                }
                self.triggerOnListChanged(null);
                self.triggerOnListIndexChanged(null);
            }
        }

        function addListChangedListener(obj as Object) as Void {
            if (self.onListChangedListeners != null) {
                var del = [];
                for (var i = 0; i < self.onListChangedListeners.size(); i++) {
                    var weak = self.onListChangedListeners[i];
                    if (weak.stillAlive()) {
                        var o = weak.get();
                        if (o == null || !(o has :onListChanged)) {
                            del.add(weak);
                        }
                    } else {
                        del.add(weak);
                    }
                }
                if (del.size() > 0) {
                    for (var i = 0; i < del.size(); i++) {
                        self.onListChangedListeners.remove(del[i]);
                    }
                }
            } else {
                self.onListChangedListeners = [];
            }

            if (obj has :onListChanged) {
                var ref = obj.weak();
                if (self.onListChangedListeners.indexOf(ref) < 0) {
                    self.onListChangedListeners.add(ref);
                }
            }
        }

        function removeListChangedListener(obj as Object) as Void {
            if (self.onListChangedListeners != null) {
                self.onListChangedListeners.removeAll(obj.weak());
                if (self.onListChangedListeners.size() == 0) {
                    self.onListChangedListeners = null;
                }
            }
        }

        function addListIndexChangedListener(obj as Object) as Void {
            if (self.onListIndexChangedListeners != null) {
                var del = [];
                for (var i = 0; i < self.onListIndexChangedListeners.size(); i++) {
                    var weak = self.onListIndexChangedListeners[i];
                    if (weak.stillAlive()) {
                        var o = weak.get();
                        if (o == null || !(o has :onListIndexChanged)) {
                            del.add(weak);
                        }
                    } else {
                        del.add(weak);
                    }
                }
                if (del.size() > 0) {
                    for (var i = 0; i < del.size(); i++) {
                        self.onListIndexChangedListeners.remove(del[i]);
                    }
                }
            } else {
                self.onListIndexChangedListeners = [];
            }

            if (obj has :onListIndexChanged) {
                var ref = obj.weak();
                if (self.onListIndexChangedListeners.indexOf(ref) < 0) {
                    self.onListIndexChangedListeners.add(ref);
                }
            }
        }

        function removeListIndexChangedListener(obj as Object) as Void {
            if (self.onListIndexChangedListeners != null) {
                self.onListIndexChangedListeners.removeAll(obj.weak());
                if (self.onListIndexChangedListeners.size() == 0) {
                    self.onListIndexChangedListeners = null;
                }
            }
        }

        private function purgeIndex(index as ListIndex?) as ListIndex? {
            if (index != null && index.size() > 0) {
                if (self._app.AppType == ListsApp.APP) {
                    var delete = [] as Array<String or Number>;
                    var keys = index.keys();
                    for (var i = 0; i < keys.size(); i++) {
                        var item = index.get(keys[i]);
                        if (item instanceof Dictionary) {
                            if (!List.IsValidIndex(item)) {
                                delete.add(keys[i]);
                            } else if (Application.Storage.getValue(item.get(List.UUID)) == null) {
                                delete.add(keys[i]);
                            }
                        } else {
                            delete.add(keys[i]);
                        }
                    }

                    if (delete.size() > 0) {
                        for (var i = 0; i < delete.size(); i++) {
                            index.remove(delete[i]);
                        }

                        Debug.Log("Deleted " + delete.size() + " invalid lists from index: " + delete);
                    }
                }

                return index;
            }

            return null;
        }

        private function storeIndex(index as ListIndex) as Array<Boolean or Lang.Exception or Null> {
            try {
                index = self.purgeIndex(index);
                if (index == null || index.size() == 0) {
                    self.clearAll(true);
                    self.triggerOnListIndexChanged(null);
                } else {
                    Common.MemoryChecker.Check();
                    Application.Storage.setValue("listindex", index);
                    self.triggerOnListIndexChanged(index);
                    Debug.Log("Stored list index with " + index.size() + " items");
                }
            } catch (ex instanceof Lang.StorageFullException) {
                if (self._app.AppType == ListsApp.APP) {
                    Helper.ToastUtil.Toast(Rez.Strings.EStorageFull, Helper.ToastUtil.ERROR);
                }
                Debug.Log("Could not store list index, storage is full: " + ex.getErrorMessage());
                return [false, ex];
            } catch (ex instanceof Exceptions.OutOfMemoryException) {
                Debug.Log("Could not store list index: " + ex.toString());
                return [false, ex];
            } catch (ex instanceof Lang.Exception) {
                Debug.Log("Could not store list index: " + ex.getErrorMessage());
                if (self._app.AppType == ListsApp.APP) {
                    Helper.ToastUtil.Toast(Rez.Strings.EStorageError, Helper.ToastUtil.ERROR);
                }
                return [false, ex];
            }
            return [true, null];
        }

        private function triggerOnListChanged(list as List?) as Void {
            if (self.onListChangedListeners != null && self._app.AppType == ListsApp.APP) {
                for (var i = 0; i < self.onListChangedListeners.size(); i++) {
                    var listener = self.onListChangedListeners[i];
                    if (listener.stillAlive()) {
                        var obj = listener.get();
                        if (obj != null && obj has :onListChanged) {
                            obj.onListChanged(list);
                        }
                    }
                }
            }
        }

        private function triggerOnListIndexChanged(index as ListIndex?) as Void {
            if (self.onListIndexChangedListeners != null && self._app.AppType == ListsApp.APP) {
                for (var i = 0; i < self.onListIndexChangedListeners.size(); i++) {
                    var listener = self.onListIndexChangedListeners[i];
                    if (listener.stillAlive()) {
                        var obj = listener.get();
                        if (obj != null && obj has :onListIndexChanged) {
                            obj.onListIndexChanged(index);
                        }
                    }
                }
            }
        }
    }
}
