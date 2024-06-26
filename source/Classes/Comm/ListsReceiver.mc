import Toybox;
import Toybox.WatchUi;
import Toybox.Lang;
using Toybox.Communications;

module Comm {
    class ListsReceiver {
        function Start() as Void {
            Communications.registerForPhoneAppMessages(method(:phoneMessageCallback));
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
                    }
                }
            } else if (message != null) {
                Debug.Log("Received invalid message: " + message.toString());
            } else {
                Debug.Log("Received invalid message!");
            }
        }
    }
}
