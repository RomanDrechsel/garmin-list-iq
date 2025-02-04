import Toybox;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;
import Toybox.Application;
using Toybox.Communications;

module Comm {
    class PhoneCommunication extends Toybox.Communications.ConnectionListener {
        private enum EMessageType {
            LIST = "list",
            DELETE_LIST = "dellist",
            REQUEST_LOGS = "req_logs",
        }

        function initialize() {
            Communications.registerForPhoneAppMessages(method(:phoneMessageCallback));
        }

        function phoneMessageCallback(msg as Communications.PhoneAppMessage) as Void {
            if ($.getApp().ListsManager == null) {
                Debug.Log("No ListsManager found, cannot handle phone app messages");
                return;
            }
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

        function SendToPhone(value as Application.PersistableType) as Void {
            Communications.transmit(value, {}, self);
            Debug.Log("Send to phone...");
        }

        function onComplete() as Void {
            Debug.Log("Send to phone successful.");
        }

        function onError() as Void {
            Debug.Log("Send to phone failed!");
        }

        private function processData(data as Array) as Void {
            var size = Helper.StringUtil.formatBytes(data.toString().length());
            var message_type = null;
            if (data[0] instanceof String) {
                message_type = data[0];
            } else {
                Debug.Log("Received unknown message from phone (" + size + ")");
                return;
            }

            data = data.slice(1, data.size() - 1);

            Debug.Log("Received message " + message_type + " (" + size + ")");

            var types = [LIST, DELETE_LIST, REQUEST_LOGS];
            if (types.indexOf(message_type) >= 0) {
                if (message_type.equals(LIST)) {
                    var dict = self.ArrayToDict(data);
                    if ($.getApp().ListsManager.addList(dict) == false) {
                        Debug.Log("Could not store list");
                    }
                } else if (message_type.equals(DELETE_LIST)) {
                    if (data.size() > 0) {
                        var uuid = data[0];
                        if ($.getApp().ListsManager.deleteList(uuid, false) == false) {
                            Debug.Log("Could not delete list " + uuid);
                        }
                    } else {
                        Debug.Log("Received delete list but no uuid provided - ignoring");
                    }
                } else if (message_type.equals(REQUEST_LOGS)) {
                    var message = self.ArrayToDict(data);
                    var tid = message.get("tid") as String?;
                    var resp = ({}) as Dictionary<String, String or Array<String> >;
                    resp.put("tid", tid);
                    if ($.getApp().Debug != null) {
                        resp.put("logs", $.getApp().Debug.GetLogs());
                    }
                    self.SendToPhone(resp as Application.PersistableType);
                }
            } else {
                Debug.Log("Received unknown message " + message_type.toString() + " from phone");
            }
        }

        private function processDataLegacy(message as Dictionary) as Void {
            var size = Helper.StringUtil.formatBytes(message.toString().length());
            Debug.Log("Received legacy message (" + size + ")");
            var type = message.get("type") as String?;
            if (type != null) {
                if (type.equals("list")) {
                    //add or edit a list
                    message.remove("type");
                    Debug.Log("Received list");
                    if ($.getApp().ListsManager.addListLegacy(message) == false) {
                        Debug.Log("Could not store list");
                    }
                } else if (type.equals("dellist")) {
                    //request for deleting a lists
                    var uuid = message.get("uuid") as String?;
                    if (uuid != null) {
                        Debug.Log("Received delete list request for list " + uuid);
                        if ($.getApp().ListsManager.deleteList(uuid, false) == false) {
                            Debug.Log("Could not delete list " + uuid);
                        }
                    } else {
                        Debug.Log("Received delete list but no uuid provided - ignoring");
                    }
                } else if (type.equals("request")) {
                    var request = message.get("request") as String?;
                    if (request != null && request.equals("logs")) {
                        //request for logs
                        Debug.Log("Received request for logs: " + message.toString().length() + " bytes");
                        var tid = message.get("tid") as String?;
                        var resp = ({}) as Dictionary<String, String or Array<String> >;
                        resp.put("tid", tid);
                        if ($.getApp().Debug != null) {
                            resp.put("logs", $.getApp().Debug.GetLogs());
                        }
                        self.SendToPhone(resp as Application.PersistableType);
                    }
                } else {
                    Debug.Log("Received unknown message " + message.toString() + " from phone");
                }
            }
        }

        protected function ArrayToDict(arr as Array) as Dictionary {
            var dict = {};
            for (var i = 0; i < arr.size(); i++) {
                var split = Helper.StringUtil.split(arr[i], "=", 2);
                if (split.size() == 1) {
                    dict.put(split[0], "");
                } else {
                    dict.put(split[0], split[1]);
                }
            }

            return dict;
        }
    }
}
