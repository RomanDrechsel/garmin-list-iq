import Toybox;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;
import Toybox.Application;
using Toybox.Communications;
import Views;

module Comm {
    (:background)
    class PhoneCommunication extends Toybox.Communications.ConnectionListener {
        public enum EMessageType {
            LIST = "list",
            DELETE_LIST = "dellist",
            REQUEST_LOGS = "req_logs",
        }

        private var _app as ListsApp;

        function initialize(app as ListsApp, register_callback as Boolean) {
            ConnectionListener.initialize();
            self._app = app;

            if (register_callback) {
                Communications.registerForPhoneAppMessages(method(:phoneMessageCallback));
            }
        }

        function phoneMessageCallback(msg as Communications.PhoneAppMessage) as Void {
            var message = msg.data as Application.PropertyValueType;
            if (message instanceof Array) {
                self.processData(message);
            } else if (message instanceof Dictionary) {
                self.processDataLegacy(message);
            } else if (message != null) {
                Debug.Log("Received invalid message " + message.toString() + " from phone");
            } else {
                Debug.Log("Received empty message from phone!");
            }
        }

        function SendToPhone(value as Array) as Void {
            if (value.size() == 0) {
                Debug.Log("Could not send empty message to phone!");
                return;
            }
            Communications.transmit(value, {}, self);
            Debug.Log("Send to phone...");
        }

        function onComplete() as Void {
            Debug.Log("Send to phone successful.");
        }

        function onError() as Void {
            Debug.Log("Send to phone failed!");
        }

        function processData(data as Array) as Void {
            if (self._app.ListsManager == null) {
                Debug.Log("No ListsManager found, cannot handle phone app messages");
                if (self._app.BackgroundService != null) {
                    self._app.BackgroundService.Finish(false);
                }
                return;
            }

            var size = Helper.StringUtil.formatBytes(Helper.StringUtil.getSize(data));
            var message_type = null;
            if (data[0] instanceof String) {
                message_type = data[0];
            } else {
                Debug.Log("Received unknown message from phone (" + size + ")");
                return;
            }
            Debug.Log("Received message " + message_type + " (" + size + ")");

            data = data.slice(1, null);
            if (message_type.equals(LIST)) {
                self._app.ListsManager.addList(data);
            } else if (message_type.equals(DELETE_LIST)) {
                if (data.size() > 0) {
                    var uuid = Helper.StringUtil.StringToNumber(data[0] as String);
                    if (self._app.ListsManager.deleteList(uuid != null ? uuid : data[0] as String, false) == false) {
                        Debug.Log("Could not delete list " + uuid);
                    }
                } else {
                    Debug.Log("Received delete list but no uuid provided - ignoring");
                }
            } else if (message_type.equals(REQUEST_LOGS)) {
                if (!self._app.isBackground) {
                    var tid = null;
                    var split = Helper.StringUtil.split(data[0] as String, "=", 2);
                    if (split.size() > 1) {
                        tid = split[1];
                    }

                    var resp = [];
                    if (tid != null && tid.length() > 0) {
                        resp.add("tid=" + tid);
                    }
                    if (self._app.Debug != null) {
                        var logs = self._app.Debug.GetLogs() as Array<String>;
                        for (var i = 0; i < logs.size(); i++) {
                            resp.add(i + "=" + logs[i]);
                        }
                    }
                    self.SendToPhone(resp);
                }
            } else {
                Debug.Log("Received unknown message " + message_type.toString() + " from phone");
            }
        }

        private function processDataLegacy(message as Dictionary) as Void {
            var size = Helper.StringUtil.formatBytes(message.toString().length());
            Debug.Log("Received legacy message (" + size + ")");
            if (!self._app.isBackground) {
                Views.ErrorView.Show(Views.ErrorView.LEGACY_APP, null);
            }
        }
    }
}
