import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Communications;
import Controls;

module Views {
    class SettingsViewDelegate extends Controls.CustomViewDelegate {
        function initialize(view as Controls.CustomView) {
            CustomViewDelegate.initialize(view);
        }

        function onKey(keyEvent) as Boolean {
            if (keyEvent.getKey() == WatchUi.KEY_ENTER || keyEvent.getKey() == WatchUi.KEY_MENU) {
                WatchUi.popView(WatchUi.SLIDE_RIGHT);
                return true;
            }
            return false;
        }

        function onSwipe(swipeEvent as SwipeEvent) as Boolean {
            var done = CustomViewDelegate.onSwipe(swipeEvent);
            if (!done) {
                if (swipeEvent.getDirection() == WatchUi.SWIPE_RIGHT) {
                    WatchUi.popView(WatchUi.SLIDE_RIGHT);
                    return true;
                }
            }

            return done;
        }
    }
}
