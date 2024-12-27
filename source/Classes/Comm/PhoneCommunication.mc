import Toybox;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;
import Toybox.Application;
using Toybox.Communications;

module Comm {
    class PhoneCommunication extends Toybox.Communications.ConnectionListener {
        function initialize() {
            Communications.registerForPhoneAppMessages(method(:phoneMessageCallback));
        }

        function phoneMessageCallback(msg as Communications.Message) as Void {
            var message = msg.data as Application.PropertyValueType;
            if (message instanceof Dictionary) {
                var type = message.get("type") as String?;
                if (type != null) {
                    if (type.equals("list")) {
                        //add or edit a list
                        message.remove("type");
                        Debug.Log("Received list: " + message.toString().length() + " bytes");
                        if ($.getApp().ListsManager.addList(message) == false) {
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
                            Debug.Log("Received delete list but no uuid privided - ignoring");
                        }
                    } else if (type.equals("request")) {
                        var request = message.get("request") as String?;
                        if (request != null && request.equals("logs")) {
                            //request for logs
                            Debug.Log("Received request for logs: " + message.toString().length() + " bytes");
                            var tid = message.get("tid") as String?;
                            var resp = ({}) as Dictionary<String, String or Array<String> >;
                            resp.put("tid", tid);
                            resp.put("logs", $.getApp().Debug.GetLogs());
                            self.SendToPhone(resp as Application.PersistableType);
                        }
                    } else {
                        Debug.Log("Received unknown message " + message.toString() + " from phone");
                    }
                }
            } else if (message != null) {
                Debug.Log("Received invalid message " + message.toString() + " from phone");
            } else {
                Debug.Log("Received empty message from phone!");
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
