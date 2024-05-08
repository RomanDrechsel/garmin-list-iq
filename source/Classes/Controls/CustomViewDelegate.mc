import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;
import Lists;

module Controls {
    class CustomViewDelegate extends WatchUi.BehaviorDelegate {
        protected var _view as CustomView;

        private var _dragLastScroll = 0;
        private var _dragStartPositionY = 0;
        private var _useSwipe = false;
        private var _lastTap = 0;

        function initialize(view as CustomView) {
            BehaviorDelegate.initialize();
            self._view = view;

            if (!(WatchUi.InputDelegate has :onDrag)) {
                self._view.ScrollMode = CustomView.SCROLL_SNAP;
                self._useSwipe = true;
            }
        }

        function onTap(clickEvent) as Boolean {
            var tap = self._view.onTap(clickEvent.getCoordinates()[0], clickEvent.getCoordinates()[1]);
            var now = System.getTimer();
            if (now - self._lastTap < 500) {
                self._lastTap = 0;
                self._view.onDoubleTap(clickEvent.getCoordinates()[0], clickEvent.getCoordinates()[1]);
                tap = true;
            } else {
                self._lastTap = now;
            }

            return tap;
        }

        function onDrag(dragEvent as WatchUi.DragEvent) as Lang.Boolean {
            var dragY = dragEvent.getCoordinates()[1];

            if (dragEvent.getType() == DRAG_TYPE_START) {
                self._dragStartPositionY = dragY;
                self._dragLastScroll = dragY;
            } else if (dragEvent.getType() == DRAG_TYPE_CONTINUE) {
                var delta = self._dragStartPositionY - dragY;
                var delta_scroll = self._dragLastScroll - dragY;
                self._dragStartPositionY = dragY;

                if (delta != 0) {
                    if (self._view.ScrollMode == CustomView.SCROLL_DRAG || delta_scroll.abs() >= self._view.UI_dragThreshold) {
                        self._dragLastScroll = dragY;
                        self._view.onScroll(delta_scroll);
                    }
                }
            }

            return true;
        }

        function onSwipe(swipeEvent) as Boolean {
            if (self._useSwipe == true) {
                if (swipeEvent.getDirection() == WatchUi.SWIPE_UP) {
                    self._view.onScroll(1);
                    return true;
                } else if (swipeEvent.getDirection() == WatchUi.SWIPE_DOWN) {
                    self._view.onScroll(-1);
                    return true;
                }
            }

            return false;
        }
    }
}
