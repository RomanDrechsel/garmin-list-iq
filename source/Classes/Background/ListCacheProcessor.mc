import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

(:withBackground)
module BG {
    class ListCacheProcessor {
        private var _processTimer as Timer.Timer? = null;
        private var _processIndex as Array<String>? = null; //array of uuid's
        private var _processDelList as Array<String>? = null; // array of uuid's
        private var _processLogRequest as Array<String>? = null; //full request array
        private var _app as ListsApp? = null;

        public function ProcessCache() as Void {
            self._app = $.getApp();
            var listindex = Application.Storage.getValue(BG.ListCacher.LISTINDEX);
            if (listindex != null) {
                if (listindex instanceof Array) {
                    if (listindex.size() > 0) {
                        self._app.ProcessingBackgroundData = true;
                        self._processIndex = listindex;
                    }
                }
                listindex = null;
                Application.Storage.deleteValue(BG.ListCacher.LISTINDEX);
            }

            var dellist = Application.Storage.getValue(BG.ListCacher.DELETE_LIST);
            if (dellist != null) {
                if (dellist instanceof Array && dellist.size() > 0) {
                    self._app.ProcessingBackgroundData = true;
                    self._processDelList = dellist;
                }
                Application.Storage.deleteValue(BG.ListCacher.DELETE_LIST);
                dellist = null;
            }

            var logrequest = Application.Storage.getValue(BG.ListCacher.REQUEST_LOGS);
            if (logrequest != null) {
                if (logrequest instanceof Array) {
                    var time = logrequest[logrequest.size() - 1];
                    if (time instanceof Number && Time.now().value() - time < 120) {
                        //request only valid for 90sec
                        self._processLogRequest = logrequest.slice(-1, null);
                        self._app.ProcessingBackgroundData = true;
                    }
                }

                Application.Storage.deleteValue(BG.ListCacher.REQUEST_LOGS);
                logrequest = null;
            }

            if (self._app.ProcessingBackgroundData == true) {
                self._processTimer = new Timer.Timer();
                self._processTimer.start(method(:processCacheTimerCallback), 1, false);
            }
        }

        public function processCacheTimerCallback() as Void {
            var next_loop = false;
            if (self._processIndex != null && self._processIndex.size() > 0) {
                var uuid = self._processIndex[0];
                self._processIndex = self._processIndex.slice(1, null);
                var list = Application.Storage.getValue(BG.ListCacher.LIST + uuid);
                if (list != null && list instanceof Array) {
                    self._app.Phone.processData(list, true);
                    Application.Storage.deleteValue(BG.ListCacher.LIST + uuid);
                } else {
                    Debug.Log("Could not find background cache for list " + uuid);
                }
                next_loop = true;
            }

            if (!next_loop && self._processDelList != null && self._processDelList.size() > 0) {
                var uuid = self._processDelList[0];
                self._processDelList = self._processDelList.slice(1, null);
                self._app.Phone.processData([Comm.PhoneCommunication.DELETE_LIST, uuid], true);
                next_loop = true;
            }

            if (!next_loop && self._processLogRequest != null && self._processLogRequest.size() > 0) {
                self._app.Phone.processData(self._processLogRequest, true);
                self._processLogRequest = null;
                next_loop = true;
            }

            if ((self._processIndex != null && self._processIndex.size() > 0) || (self._processDelList != null && self._processDelList.size() > 0) || self._processLogRequest != null) {
                self._processTimer = new Timer.Timer();
                self._processTimer.start(method(:processCacheTimerCallback), 1, false);
            } else {
                self._processTimer.stop();
                self._processTimer = null;
                self._app.ProcessingBackgroundData = null;
            }
        }
    }
}
