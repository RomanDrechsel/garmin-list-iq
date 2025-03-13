import Toybox.Lang;
import Toybox.System;
import Toybox.Communications;

module BG {
    (:background)
    class Service extends System.ServiceDelegate {
        (:withBackground)
        public enum {
            OUTOFMEMORY = 0,
            NOT_STORED = 1,
        }

        (:withBackground)
        private var _pendingMessage as Communications.PhoneAppMessage?;

        function initialize() {
            ServiceDelegate.initialize();
        }

        (:withBackground)
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

        (:withBackground)
        function Finish(success as Boolean) as Void {
            success = false;
            if (!success && self._pendingMessage != null) {
                try {
                    (new ListCacher($.getApp())).Cache(self._pendingMessage.data);
                } catch (ex instanceof Exceptions.OutOfMemoryException) {
                    Debug.Log("Could not cache message for foreground: " + ex.toString());
                    Background.exit(OUTOFMEMORY);
                } catch (ex instanceof Lang.Exception) {
                    Debug.Log("Could not cache message for foreground: " + ex.getErrorMessage());
                    Background.exit(NOT_STORED);
                }
            }
            Background.exit(null);
        }

        (:withoutBackground)
        function Finish(success as Boolean) as Void {}
    }
}
