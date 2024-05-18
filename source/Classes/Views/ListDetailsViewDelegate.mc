import Toybox.Lang;
import Toybox.WatchUi;

module Views {
    class ListDetailsViewDelegate extends Controls.CustomViewDelegate {
        function initialize(view as Views.ListDetailsView) {
            CustomViewDelegate.initialize(view);
        }

        function onKey(keyEvent) as Boolean {
            if (keyEvent.getKey() == WatchUi.KEY_ENTER || keyEvent.getKey() == WatchUi.KEY_MENU) {
                self._view.showSettings();
                return true;
            }
            return false;
        }

        /*function onSwipe(swipeEvent as SwipeEvent) as Boolean
    {
        var done = CustomViewDelegate.onSwipe(swipeEvent);
        if (!done)
        {
            if (swipeEvent.getDirection() == WatchUi.SWIPE_RIGHT)
            {
                WatchUi.popView(WatchUi.SLIDE_RIGHT);
                return true;
            }
        }

        return done;
    }*/
    }
}
