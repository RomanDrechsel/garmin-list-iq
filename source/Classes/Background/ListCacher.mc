import Toybox.Lang;
import Toybox.Application;
import Toybox.Time;

(:background,:withBackground)
module BG {
    class ListCacher {
        public enum ECacheType {
            LIST = "bg_",
            LISTINDEX = "bg_listindex",
            DELETE_LIST = "bg_dellist",
            REQUEST_LOGS = "bg_requestlogs",
        }

        public function Cache(data as Object?) as Void {
            if (data instanceof Array) {
                var message_type = null;
                if (data[0] instanceof String) {
                    message_type = data[0];

                    if (message_type.equals(Comm.PhoneCommunication.LIST)) {
                        if (data.size() > 1) {
                            var uuid = null;
                            for (var i = 0; i < data.size(); i++) {
                                var row = data[i];
                                if (row.substring(0, 5).equals("uuid=")) {
                                    uuid = row.substring(5, null);
                                    break;
                                }
                            }

                            if (uuid == null || uuid.length() == 0) {
                                Debug.Log("Received list, but no uuid - skipping");
                                return;
                            }

                            var listindex;
                            try {
                                listindex = Application.Storage.getValue(LISTINDEX) as Array<String>?;
                            } catch (ex instanceof Lang.Exception) {
                                Debug.Log("Could not get background list index: " + ex.getErrorMessage());
                                return;
                            }
                            if (listindex == null || listindex.size() == 0 || !(listindex[0] instanceof String)) {
                                listindex = [] as Array<String>;
                            }
                            if (listindex.indexOf(uuid) >= 0) {
                                listindex.remove(uuid);
                            }

                            listindex.add(uuid);
                            try {
                                Application.Storage.setValue(LISTINDEX, listindex);
                            } catch (ex instanceof Lang.Exception) {
                                Debug.Log("Could not store background list index: " + ex.getErrorMessage());
                                return;
                            }
                            try {
                                Application.Storage.setValue(LIST + uuid, data);
                                Debug.Log("Stored list " + uuid + " in background cache");
                            } catch (ex instanceof Lang.Exception) {
                                Debug.Log("Could not store background list cache " + uuid + ": " + ex.getErrorMessage());
                            }
                        }
                    } else if (message_type.equals(Comm.PhoneCommunication.DELETE_LIST)) {
                        if (data.size() > 1) {
                            var uuid = data[1] as String;
                            try {
                                var dellist = Application.Storage.getValue(DELETE_LIST) as Array?;
                                if (dellist == null) {
                                    dellist = [];
                                }
                                if (dellist.indexOf(uuid) < 0) {
                                    dellist.add(uuid);
                                    Application.Storage.setValue(DELETE_LIST, dellist);

                                    //remove list from cache index, if it is in it
                                    var index = Application.Storage.getValue(LISTINDEX);
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

        public function TrimCache(num as Number) as Void {
            var listindex = Application.Storage.getValue(LISTINDEX) as Array<String>?;
            if (listindex == null || !(listindex instanceof Array) || listindex.size() < num) {
                return;
            }

            var trim = listindex.size() - num;
            if (trim > 0) {
                for (var i = 0; i < trim; i++) {
                    try {
                        Application.Storage.deleteValue(LIST + listindex[i]);
                    } catch (ex instanceof Lang.Exception) {
                        Debug.Log("Could not remove list " + listindex[i] + " from background cache: " + ex.getErrorMessage());
                    }
                }
                listindex = listindex.slice(trim, null);
                try {
                    Application.Storage.setValue(LISTINDEX, listindex);
                } catch (ex instanceof Lang.Exception) {
                    Debug.Log("Could not update index in storage: " + ex.getErrorMessage());
                    return;
                }
                Debug.Log("Removed " + trim + " list(s) from background cache");
            }
        }
    }
}
