import Toybox.Lang;
import Toybox.Application;
import Toybox.Time;

module BG {
    (:background)
    class ListCacher {
        (:withBackground)
        public enum ECacheType {
            LIST = "bg_",
            LISTINDEX = "bg_listindex",
            DELETE_LIST = "bg_dellist",
            REQUEST_LOGS = "bg_requestlogs",
        }

        (:withBackground)
        private const _maxListCache = 5;
        private var _app as ListsApp;

        function initialize(app as ListsApp) {
            self._app = app;
        }

        (:withBackground)
        public function Cache(data as Object?) as Void {
            if (data instanceof Array) {
                var message_type = null;
                if (data[0] instanceof String) {
                    message_type = data[0];

                    if (message_type.equals(Comm.PhoneCommunication.LIST)) {
                        var uuid = null;
                        for (var i = 1; i < data.size(); i++) {
                            if (data[i].substring(0, 5).equals("uuid=")) {
                                uuid = data[i].substring(5, data[i].length());
                                break;
                            }
                        }
                        if (uuid == null) {
                            Debug.Log("Could not cache background list, no uuid found");
                            return;
                        }

                        var index = Application.Storage.getValue(LISTINDEX);
                        var store = false;
                        if (index == null || !(index instanceof Array)) {
                            index = [uuid];
                            store = true;
                        } else if (index.indexOf(uuid) < 0) {
                            index.add(uuid);
                            store = true;
                        }
                        if (store) {
                            try {
                                if (index.size() > self._maxListCache) {
                                    var del = index[0];
                                    Application.Storage.deleteValue(del);
                                    index = index.slice(1, null);
                                    Debug.Log("More than " + self._maxListCache + " lists cached, deleted oldest");
                                }
                                Application.Storage.setValue(LISTINDEX, index);

                                //if there was a request to delete the list before - remove it
                                var dellist = Application.Storage.getValue(DELETE_LIST);
                                if (dellist != null && dellist.indexOf(uuid) >= 0) {
                                    dellist.remove(uuid);
                                    Application.Storage.setValue(DELETE_LIST, dellist);
                                }
                            } catch (ex instanceof Lang.Exception) {
                                Debug.Log("Could not cache list index: " + ex.getErrorMessage());
                                return;
                            }
                        }
                        try {
                            Application.Storage.setValue(LIST + uuid, data);
                            Debug.Log("Cached list " + uuid + " for foreground");
                        } catch (ex instanceof Lang.Exception) {
                            Debug.Log("Could not cache list " + uuid + ": " + ex.getErrorMessage());
                        }
                    } else if (message_type.equals(Comm.PhoneCommunication.DELETE_LIST)) {
                        if (data.size() > 1) {
                            var uuid = data[1] as String;
                            try {
                                var dellist = Application.Storage.getValue(DELETE_LIST);
                                if (dellist == null || dellist.indexOf(uuid) < 0) {
                                    dellist.add(uuid);
                                    Application.Storage.setValue(DELETE_LIST, dellist);
                                    //remove list from cache index, if it is in it
                                    self.removeListFromIndex(uuid, null);
                                }
                            } catch (ex instanceof Lang.Exception) {
                                Debug.Log("Could not cache delete list " + uuid + ": " + ex.getErrorMessage());
                            }
                        }
                    } else if (message_type.equals(Comm.PhoneCommunication.REQUEST_LOGS)) {
                        try {
                            data.add(Time.now().value());
                            Application.Storage.setValue(REQUEST_LOGS, data);
                        } catch (ex instanceof Lang.Exception) {
                            Debug.Log("Could not cache log request: " + ex.getErrorMessage());
                        }
                    }
                } else {
                    Debug.Log("Received not supported message from phone, do not cache...");
                }
            } else {
                Debug.Log("Received unknown message from phone, do not cache...");
            }
        }

        (:withBackground)
        public function ProcessCache() as Void {
            var listindex = Application.Storage.getValue(LISTINDEX);
            if (listindex != null) {
                if (listindex instanceof Array) {
                    var count = listindex.size();
                    while (listindex.size() > 0) {
                        var uuid = listindex[0];
                        listindex = listindex.slice(1, null);
                        var list = Application.Storage.getValue(LIST + uuid);
                        if (list != null && list instanceof Array) {
                            Debug.Log("Process background cache for list " + uuid);
                            self._app.Phone.processData(list);
                        } else {
                            Debug.Log("Could not find list background cache for list " + uuid);
                        }
                        Application.Storage.deleteValue(LIST + uuid);
                    }
                    if (count > 0) {
                        Debug.Log("Processing " + count + " cached lists from background");
                    }
                }

                Application.Storage.deleteValue(LISTINDEX);
                listindex = null;
            }

            var dellist = Application.Storage.getValue(DELETE_LIST);
            if (dellist != null) {
                if (dellist instanceof Array) {
                    var count = dellist.size();
                    for (var i = 0; i < dellist.size(); i++) {
                        self._app.Phone.processData([Comm.PhoneCommunication.DELETE_LIST, dellist[i]]);
                    }
                    if (count > 0) {
                        Debug.Log("Deleted " + count + " lists from background cache");
                    }
                }
                Application.Storage.deleteValue(DELETE_LIST);
                dellist = null;
            }

            var logrequest = Application.Storage.getValue(REQUEST_LOGS);
            if (logrequest != null) {
                if (logrequest instanceof Array) {
                    var time = logrequest[logrequest.size() - 1];
                    if (time instanceof Number && Time.now().value() - time < 300) {
                        logrequest = logrequest.slice(-1, null);
                        self._app.Phone.processData(logrequest);
                    }
                }

                Application.Storage.deleteValue(REQUEST_LOGS);
                logrequest = null;
            }

            self._app.ListCacher = null;
        }

        (:withoutBackground)
        public function ProcessCache() as Void {}

        (:withBackground)
        private function removeListFromIndex(uuid as String, index as Array?) as Void {
            if (index == null) {
                index = Application.Storage.getValue(LISTINDEX);
            }
            if (index != null && index instanceof Array && index.indexOf(uuid) >= 0) {
                index.remove(uuid);
                Application.Storage.deleteValue(LIST + uuid);
                Debug.Log("Removed list " + uuid + " from background cache");
                if (index.size() > 0) {
                    Application.Storage.setValue(LISTINDEX, index);
                } else {
                    Application.Storage.deleteValue(LISTINDEX);
                }
            }
        }
    }
}
