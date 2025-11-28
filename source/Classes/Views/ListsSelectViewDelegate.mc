import Toybox.WatchUi;
import Toybox.Lang;

module Views {
    class ListsSelectViewDelegate extends Views.ItemViewDelegate {
        function initialize(view as Views.ListsSelectView) {
            Views.ItemViewDelegate.initialize(view);
        }

        (:withBackground)
        public function onTap(clickEvent as WatchUi.ClickEvent) as Lang.Boolean {
            if ($.getApp().ProcessingBackgroundData) {
                return true;
            }
            return Views.ItemViewDelegate.onTap(clickEvent);
        }

        (:withBackground)
        public function onDrag(dragEvent as WatchUi.DragEvent) as Lang.Boolean {
            if ($.getApp().ProcessingBackgroundData) {
                return true;
            }
            return Views.ItemViewDelegate.onDrag(dragEvent);
        }

        (:withBackground)
        public function onKey(keyEvent as WatchUi.KeyEvent) as Lang.Boolean {
            if ($.getApp().ProcessingBackgroundData) {
                var key = keyEvent.getKey();
                if (key != WatchUi.KEY_ENTER && key != WatchUi.KEY_ESC) {
                    return true;
                }
            }
            return Views.ItemViewDelegate.onKey(keyEvent);
        }
    }
}
