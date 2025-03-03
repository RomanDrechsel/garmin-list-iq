import Toybox.Lang;
import Toybox.System;
import Toybox.Communications;

module BG {
    (:background)
    class Service extends System.ServiceDelegate {
        private var _pendingMessage as Communications.PhoneAppMessage?;

        function initialize() {
            ServiceDelegate.initialize();
        }

        function onPhoneAppMessage(msg as Communications.PhoneAppMessage) as Void {
            var phone = $.getApp().Phone as Comm.PhoneCommunication?;
            if (phone != null) {
                self._pendingMessage = msg;
                phone.phoneMessageCallback(msg);
                return;
            } else {
                Debug.Log("Could not process background message");
                Background.exit(msg.data);
            }
        }

        function Finish(success as Boolean) as Void {
            if (success || self._pendingMessage == null) {
                Background.exit(null);
            } else {
                Background.exit(self._pendingMessage.data);
            }
        }
    }
}
