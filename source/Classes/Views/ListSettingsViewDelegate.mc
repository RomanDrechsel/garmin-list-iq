import Toybox.Lang;
import Toybox.WatchUi;
import Controls;

module Views {
    class ListSettingsViewDelegate extends CustomViewDelegate {
        function initialize(view as CustomView) {
            CustomViewDelegate.initialize(view);
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
