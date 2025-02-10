import Toybox.System;
import Toybox.Communications;

(:background)
module BackgroundService {
    class BGService extends System.ServiceDelegate {
        function initialize() {
            ServiceDelegate.initialize();
        }

        function onPhoneAppMessage(msg as Communications.PhoneAppMessage) as Void {
            var phone = $.getApp().Phone as Comm.PhoneCommunication?;
            if (phone != null) {
                phone.phoneMessageCallback(msg);
            } else {
                Debug.Log("Could not process background message");
            }
        }
    }
}
