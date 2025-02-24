import Toybox.System;
import Toybox.Communications;

module BG {
    (:background)
    class Service extends System.ServiceDelegate {
        function initialize() {
            ServiceDelegate.initialize();
        }

        function onPhoneAppMessage(msg as Communications.PhoneAppMessage) as Void {
            var phone = $.getApp().Phone as Comm.PhoneCommunication?;
            if (phone != null) {
                try {
                    phone.phoneMessageCallback(msg);
                } catch (ex instanceof NoDataProcessedException) {
                    Background.exit(msg.data);
                }
                Background.exit(null);
            } else {
                Debug.Log("Could not process background message");
            }
            Background.exit(msg.data);
        }
    }
}
