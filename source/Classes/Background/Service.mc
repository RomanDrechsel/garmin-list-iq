import Toybox.Lang;
import Toybox.System;
import Toybox.Communications;
import Toybox.Background;

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
            var app = $.getApp();
            self._pendingMessage = msg;
            if (app.AppType == ListsApp.APP) {
                app.Phone.phoneMessageCallback(msg);
            } else if (app.AppType == ListsApp.BACKGROUND) {
                var cacher = new ListCacher();
                cacher.Cache(msg.data);
            } else {
                self.Finish(false);
            }
            self.Finish(true);
        }

        (:withBackground)
        function Finish(success as Boolean) as Void {
            if (!success && self._pendingMessage != null) {
                try {
                    Background.exit(self._pendingMessage.data);
                } catch (ex instanceof Background.ExitDataSizeLimitException) {
                    Debug.Log("Could not pass message to foreground - ExitDataSizeLimitException: " + ex.getErrorMessage());
                }
            }
            Background.exit(null);
        }

        (:withoutBackground)
        function Finish(success as Boolean) as Void {}
    }
}
