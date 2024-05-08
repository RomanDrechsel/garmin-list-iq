import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Communications;
import Controls;

module Views {
    class ListsSelectViewDelegate extends Controls.CustomViewDelegate {
        function initialize(view as Controls.CustomView) {
            CustomViewDelegate.initialize(view);
        }

        function onKey(keyEvent) as Boolean {
            if (keyEvent.getKey() == WatchUi.KEY_ENTER || keyEvent.getKey() == WatchUi.KEY_MENU) {
                var settings = new SettingsView();
                var delegate = new SettingsViewDelegate(settings);
                WatchUi.pushView(settings, delegate, WatchUi.SLIDE_LEFT);
                return true;
            }
            return false;
        }
    }
}
