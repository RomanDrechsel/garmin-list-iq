using Helper;
using Debug;
import Toybox;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;
import Toybox.Application;
using Toybox.Communications;
import Views;

module Comm {
    class PhoneCommunication extends Toybox.Communications.ConnectionListener {
        typedef EMessageType as Toybox.Lang.String;

        function initialize() {
            Communications.registerForPhoneAppMessages(method(:phoneMessageCallback));
        }

        function phoneMessageCallback(msg as Communications.PhoneAppMessage) as Void {
            if ($.getApp().ListsManager == null) {
                Debug.Log("No ListsManager found, cannot handle phone app messages");
                return;
            }
            msg /*>message<*/ = msg.data as Application.PropertyValueType;
            if (msg /*>message<*/ instanceof Array) {
                self.processData(msg /*>message<*/);
            } else if (msg /*>message<*/ instanceof Dictionary) {
                self.processDataLegacy(msg /*>message<*/);
            } else if (msg /*>message<*/ != null) {
                Debug.Log("Received invalid message " + msg /*>message<*/.toString() + " from phone");
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

        private function processData(data as Array) as Void {
            var size, message_type, pre_0;
            pre_0 = 0;
            size = Helper.StringUtil.formatBytes(data.toString().length());
            if (data[pre_0] instanceof String) {
                message_type = data[pre_0];
            } else {
                Debug.Log("Received unknown message from phone (" + size + ")");
                return;
            }

            Debug.Log("Received message " + message_type + " (" + size + ")");

            data = data.slice(1, null);

            if (["list", "dellist", "req_logs"].indexOf(message_type) >= pre_0) {
                if (message_type.equals("list")) {
                    message_type /*>dict<*/ = self.ArrayToDict(data);
                    if ($.getApp().ListsManager.addList(message_type /*>dict<*/) == false) {
                        Debug.Log("Could not store list");
                    }
                } else if (message_type.equals("dellist")) {
                    if (data.size() > pre_0) {
                        message_type /*>uuid<*/ = data[pre_0];
                        $.getApp().ListsManager.deleteList(message_type /*>uuid<*/, false);
                    } else {
                        Debug.Log("Received delete list but no uuid provided - ignoring");
                    }
                } else if (message_type.equals("req_logs")) {
                    message_type /*>tid<*/ = self.ArrayToDict(data).get("tid") as String?;
                    size /*>resp<*/ = [];
                    if (message_type /*>tid<*/ != null && message_type /*>tid<*/.length() > pre_0) {
                        size /*>resp<*/.add("tid=" + message_type /*>tid<*/);
                    }
                    if ($.getApp().Debug != null) {
                        data /*>logs<*/ = $.getApp().Debug.GetLogs();
                        {
                            message_type /*>i<*/ = pre_0;
                            for (; message_type /*>i<*/ < data /*>logs<*/.size(); message_type /*>i<*/ += 1) {
                                size /*>resp<*/.add(message_type /*>i<*/ + "=" + data /*>logs<*/[message_type /*>i<*/]);
                            }
                        }
                    }
                    self.SendToPhone(size /*>resp<*/);
                }
            } else {
                Debug.Log("Received unknown message " + message_type.toString() + " from phone");
            }
        }

        private function processDataLegacy(message as Dictionary) as Void {
            Debug.Log("Received legacy message (" + Helper.StringUtil.formatBytes(message.toString().length()) + ")");
            message /*>error<*/ = new Views.ErrorViewLegacyApp();
            WatchUi.pushView(message /*>error<*/, new Views.ItemViewDelegate(message /*>error<*/), 0 as Toybox.WatchUi.SlideType);
        }

        protected function ArrayToDict(arr as Array) as Dictionary {
            var pre_0, pre_1;
            pre_0 = 0;
            var dict = {};
            pre_1 = 1;
            for (var i = pre_0; i < arr.size(); i += pre_1) {
                var split = Helper.StringUtil.split(arr[i], "=", 2);
                if (split.size() == pre_1) {
                    dict.put(split[pre_0], "");
                } else {
                    dict.put(split[pre_0], split[pre_1]);
                }
            }

            return dict;
        }
    }
}
