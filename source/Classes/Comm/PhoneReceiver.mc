import Toybox;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;
import Toybox.Application;
using Toybox.Communications;

module Comm {
    class PhoneReceiver extends Toybox.Communications.ConnectionListener {
        function initialize() {
            Communications.registerForPhoneAppMessages(method(:phoneMessageCallback));
            Debug.Log("Started PhoneReceiver");
        }

        function phoneMessageCallback(msg as Communications.Message) as Void {
            var message = msg.data as Application.PropertyValueType;
            if (message instanceof Dictionary) {
                var type = message.get("type") as String?;
                if (type != null) {
                    if (type.equals("list")) {
                        message.remove("type");
                        if (getApp().ListsManager.addList(message)) {
                            Debug.Log("Received list: " + message.toString());
                        }
                        return;
                    } else if (type.equals("request")) {
                        var request = message.get("request") as String?;
                        if (request != null && request.equals("logs")) {
                            var tid = message.get("tid") as String?;
                            var resp = ({}) as Dictionary<String, String or Array<String> >;
                            resp.put("tid", tid);
                            resp.put("logs", $.getApp().Debug.GetLogs());
                            self.SendToPhone(resp);
                        }
                    }
                }
            } else if (message != null) {
                Debug.Log("Received invalid message: " + message.toString());
            } else {
                Debug.Log("Received invalid message!");
            }
        }

        function SendToPhone(value as Application.PersistableType) as Void {
            Debug.Log("Send to phone...");
            Communications.transmit(value, {}, self);
        }

        function onComplete() as Void {
            Debug.Log("Send to phone successful.");
        }

        function onError() as Void {
            Debug.Log("Send to phone failed!");
        }
    }
}
