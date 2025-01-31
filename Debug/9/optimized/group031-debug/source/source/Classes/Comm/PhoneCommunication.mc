using Debug;
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

        function phoneMessageCallback(msg as Communications.PhoneAppMessage) as Void {
            if ($.getApp().ListsManager == null) {
                return;
            }
            var message = msg.data as Application.PropertyValueType;
            if (message instanceof Dictionary) {
                msg /*>type<*/ = message.get("type") as String?;
                if (msg /*>type<*/ != null) {
                    if (msg /*>type<*/.equals("list")) {
                        //add or edit a list
                        message.remove("type");
                        Debug.Log("Received list: " + message.toString().length() + " bytes");
                        if ($.getApp().ListsManager.addList(message) == false) {
                            Debug.Log("Could not store list");
                        }
                    } else if (msg /*>type<*/.equals("dellist")) {
                        //request for deleting a lists
                        msg /*>uuid<*/ = message.get("uuid") as String?;
                        if (msg /*>uuid<*/ != null) {
                            Debug.Log("Received delete list request for list " + msg /*>uuid<*/);
                            $.getApp().ListsManager.deleteList(msg /*>uuid<*/, false);
                        } else {
                            Debug.Log("Received delete list but no uuid provided - ignoring");
                        }
                    } else if (msg /*>type<*/.equals("request")) {
                        msg /*>request<*/ = message.get("request") as String?;
                        if (msg /*>request<*/ != null && msg /*>request<*/.equals("logs")) {
                            //request for logs
                            Debug.Log("Received request for logs: " + message.toString().length() + " bytes");
                            msg /*>resp<*/ = ({}) as Dictionary<String, String or Array<String> >;
                            msg /*>resp<*/.put("tid", message.get("tid") as String?);
                            if ($.getApp().Debug != null) {
                                msg /*>resp<*/.put("logs", $.getApp().Debug.GetLogs());
                            }
                            self.SendToPhone(msg /*>resp<*/ as Application.PersistableType);
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
            Communications.transmit(value, {}, self);
            Debug.Log("Send to phone...");
        }

        function onComplete() as Void {
            Debug.Log("Send to phone successful.");
        }

        function onError() as Void {
            Debug.Log("Send to phone failed!");
        }
    }
}
