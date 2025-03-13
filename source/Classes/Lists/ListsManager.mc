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
    (:background)
    typedef ListIndexItem as Dictionary<Number, String or Number>;
    (:background)
    typedef ListIndex as Dictionary<String or Number, ListIndexItem>;

    (:background)
    class ListsManager {
        private var onListChangedListeners as Array<WeakReference>?;
        private var onListIndexChangedListeners as Array<WeakReference>?;
        private var _batchQueue = null as Array<AddListBatch>?;
        private var _batchTimer = null as Timer?;
        private var _app as ListsApp;

        function initialize(app as ListsApp) {
            self._app = app;
        }

        function addList(data as Array) as Void {
            var batch = new AddListBatch(data);
            if (self._batchQueue == null) {
                self._batchQueue = [batch];
            } else {
                self._batchQueue.add(batch);
            }
            if (self._batchTimer == null) {
                self.BatchTimer();
            }
        }

        function GetListsIndex() as ListIndex {
            var index = Application.Storage.getValue("listindex") as ListIndex?;
            if (index == null) {
                return {};
            }
            try {
                self._app.MemoryCheck.Check();
            } catch (ex instanceof Exceptions.OutOfMemoryException) {
                Debug.Log("Could not get list index: " + ex.toString());
                return {};
            }
            return index;
        }

        function GetList(uuid as String) as List? {
            try {
                var list = new List(Application.Storage.getValue(uuid));
                self._app.MemoryCheck.Check();
                if (list.IsValid()) {
                    return list;
                } else {
                    return null;
                }
            } catch (ex instanceof Exceptions.OutOfMemoryException) {
                Debug.Log("Could not get list " + uuid + ": " + ex.toString());
                return null;
            } catch (ex instanceof Exceptions.LegacyNotSupportedException) {
                self.clearAll();
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

        function updateListitem(uuid as String, position as Number, done as Boolean) as Void {
            if (position < 0) {
                return;
            }
            try {
                var list = self.GetList(uuid);
                if (list != null) {
                    var item = list.GetItem(position);
                    self._app.MemoryCheck.Check();

                    if (item != null) {
                        item.Done = done;
                        var save = list.ToBackend();
                        if (save != null) {
                            try {
                                Application.Storage.setValue(uuid, save);
                                Debug.Log("Updated list " + list.toString());
                            } catch (e instanceof Lang.StorageFullException) {
                                if (!self._app.isBackground) {
                                    Helper.ToastUtil.Toast(Rez.Strings.EStorageFull, Helper.ToastUtil.ERROR);
                                }
                                Debug.Log("Could not update list " + list.toString() + ": storage is full: " + e.getErrorMessage());
                            } catch (e instanceof Lang.Exception) {
                                if (!self._app.isBackground) {
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
                self._app.MemoryCheck.Check();
                Application.Storage.setValue(list.Uuid, list.ToBackend());

                if (!self._app.isBackground && Helper.Properties.Get(Helper.Properties.LASTLIST, "").equals(list.Uuid)) {
                    Helper.Properties.Store(Helper.Properties.LASTLISTSCROLL, -1);
                }

                Debug.Log("Stored list " + list.toString());
                self._app.MemoryCheck.Check();
                self.triggerOnListChanged(list);
                return [true, null];
            } catch (ex instanceof Exceptions.OutOfMemoryException) {
                Debug.Log("Could not store list " + list.toString() + ": " + ex.toString());
                return [false, ex];
            } catch (ex instanceof Lang.StorageFullException) {
                Debug.Log("Could not store list " + list.toString() + ": storage is full: " + ex.getErrorMessage());
                if (!self._app.isBackground) {
                    Helper.ToastUtil.Toast(Rez.Strings.EStorageFull, Helper.ToastUtil.ERROR);
                }
                return [false, ex];
            } catch (ex) {
                Debug.Log("Could not store list " + list.toString() + ": " + ex.getErrorMessage());
                if (!self._app.isBackground) {
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
                if (with_toast == true && !self._app.isBackground) {
                    Helper.ToastUtil.Toast(Rez.Strings.ListDel, Helper.ToastUtil.SUCCESS);
                }
                if (!self._app.isBackground && Helper.Properties.Get(Helper.Properties.LASTLIST, "").equals(uuid)) {
                    Helper.Properties.Store(Helper.Properties.LASTLISTSCROLL, -1);
                    Helper.Properties.Store(Helper.Properties.LASTLIST, "");
                }
                Debug.Log("Deleted list " + uuid);
                self.triggerOnListChanged(null);
                return true;
            } else {
                if (!self._app.isBackground && !(store[1] instanceof Exceptions.OutOfMemoryException)) {
                    Views.ErrorView.Show(Views.ErrorView.LIST_DEL_FAILED, ["index=" + index.toString(), "delete=" + uuid, "exception=" + store[1].getErrorMessage()]);
                }
                return false;
            }
        }

        function clearAll() as Void {
            Application.Storage.clearValues();
            Debug.Log("Deleted all lists!");
            if (!self._app.isBackground) {
                Helper.ToastUtil.Toast(Rez.Strings.StDelAllDone, Helper.ToastUtil.SUCCESS);
            }
            self.triggerOnListChanged(null);
            self.triggerOnListIndexChanged(null);
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

        public function BatchTimer() as Void {
            var background = self._app.BackgroundService;
            if (self._batchQueue != null && self._batchQueue.size() > 0) {
                var batch = (self._batchQueue as Array<AddListBatch>)[0];
                var finish = null;
                try {
                    finish = batch.ProcessBatch(self._app.MemoryCheck);
                } catch (ex instanceof Exceptions.OutOfMemoryException) {
                    Debug.Log("Could not add list " + batch.List.toString() + ": " + ex.toString());
                } catch (ex instanceof Exceptions.LegacyNotSupportedException) {
                    if (!$.getApp().isBackground) {
                        Views.ErrorView.Show(Views.ErrorView.LEGACY_APP, null);
                    }
                }
                if (finish instanceof Lang.Array) {
                    if (finish[0] == true) {
                        if (self._batchQueue.size() > 1) {
                            self._batchQueue = self._batchQueue.slice(0, 1);
                        } else {
                            self._batchQueue = null;
                        }
                        if (finish[1] == false) {
                            if (!self._app.isBackground) {
                                Views.ErrorView.Show(Views.ErrorView.LIST_REC_INVALID, null);
                            }
                        } else {
                            var save = self.StoreList(batch.List);
                            if (save[0] == true) {
                                //Store Index...
                                var listindex = self.GetListsIndex();
                                listindex.put(batch.List.Uuid, batch.List.ToIndex());
                                var saveIndex = self.storeIndex(listindex);
                                if (saveIndex[0] == false) {
                                    Application.Storage.deleteValue(batch.List.Uuid);
                                    if (!self._app.isBackground && !(saveIndex[1] instanceof Exceptions.OutOfMemoryException)) {
                                        Views.ErrorView.Show(Views.ErrorView.LIST_REC_INDEX_STORE_FAILED, ["list=" + batch.List.ToBackend(), "exception=" + saveIndex[1].getErrorMessage()]);
                                    }
                                } else {
                                    if (!self._app.isBackground) {
                                        Helper.Properties.Store(Helper.Properties.INIT, 1);

                                        if (batch.IsSync == false) {
                                            Helper.ToastUtil.Toast(Rez.Strings.ListRec, Helper.ToastUtil.SUCCESS);
                                        }
                                    }
                                }
                            } else if (!(save[1] instanceof Exceptions.OutOfMemoryException)) {
                                if (!self._app.isBackground) {
                                    Views.ErrorView.Show(Views.ErrorView.LIST_REC_STORE_FAILED, ["list=" + batch.List.ToBackend(), "exception=" + save[1].getErrorMessage()]);
                                }
                            }
                        }
                    }
                } else {
                    if (self._batchQueue.size() > 1) {
                        self._batchQueue = self._batchQueue.slice(0, 1);
                    } else {
                        self._batchQueue = null;
                    }
                }
            }

            if (self._batchQueue == null || self._batchQueue.size() <= 0) {
                self._batchQueue = null;
                if (self._batchTimer != null) {
                    self._batchTimer.stop();
                    self._batchTimer = null;
                }
                if (background != null) {
                    background.Finish(true);
                }
            } else if (background != null) {
                /* doe to Timer.Timer() is not available in background -> send it to the next foreground session */
                background.Finish(false);
            } else {
                if (self._batchTimer == null) {
                    self._batchTimer = new Timer.Timer();
                }
                self._batchTimer.start(method(:BatchTimer), 50, false);
            }
        }

        private function purgeIndex(index as ListIndex?) as ListIndex? {
            if (index != null && index.size() > 0) {
                if (!self._app.isBackground) {
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
                    self.clearAll();
                    self.triggerOnListIndexChanged(null);
                } else {
                    self._app.MemoryCheck.Check();
                    Application.Storage.setValue("listindex", index);
                    self.triggerOnListIndexChanged(index);
                    Debug.Log("Stored list index with " + index.size() + " items");
                }
            } catch (ex instanceof Lang.StorageFullException) {
                if (!self._app.isBackground) {
                    Helper.ToastUtil.Toast(Rez.Strings.EStorageFull, Helper.ToastUtil.ERROR);
                }
                Debug.Log("Could not store list index, storage is full: " + ex.getErrorMessage());
                return [false, ex];
            } catch (ex instanceof Exceptions.OutOfMemoryException) {
                Debug.Log("Could not store list index: " + ex.toString());
                return [false, ex];
            } catch (ex instanceof Lang.Exception) {
                Debug.Log("Could not store list index: " + ex.getErrorMessage());
                if (!self._app.isBackground) {
                    Helper.ToastUtil.Toast(Rez.Strings.EStorageError, Helper.ToastUtil.ERROR);
                }
                return [false, ex];
            }
            return [true, null];
        }

        private function triggerOnListChanged(list as List?) as Void {
            if (self.onListChangedListeners != null && !self._app.isBackground) {
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
            if (self.onListIndexChangedListeners != null && !self._app.isBackground) {
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
