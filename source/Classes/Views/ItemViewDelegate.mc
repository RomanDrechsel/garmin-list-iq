import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.System;
import Lists;

module Views {
    class ItemViewDelegate extends WatchUi.BehaviorDelegate {
        protected var _view as ItemView;

        private var _dragLastScroll = 0;
        private var _dragStartPositionY = 0;
        private var _noDrag = false;
        private var _lastTap = 0;

        function initialize(view as ItemView) {
            BehaviorDelegate.initialize();
            self._view = view;

            if (!(WatchUi.InputDelegate has :onDrag)) {
                self._noDrag = true;
            }
        }

        public function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
            self._view.Interaction();
            var tap = self._view.onTap(clickEvent.getCoordinates()[0], clickEvent.getCoordinates()[1]);
            var now = System.getTimer();
            if (now - self._lastTap < 500 && now - self._lastTap > 50) {
                self._lastTap = 0;
                self._view.onDoubleTap(clickEvent.getCoordinates()[0], clickEvent.getCoordinates()[1]);
                tap = true;
            } else {
                self._lastTap = now;
            }
            return tap;
        }

        public function onDrag(dragEvent as WatchUi.DragEvent) as Lang.Boolean {
            self._view.Interaction();
            var dragY = dragEvent.getCoordinates()[1];

            if (dragEvent.getType() == DRAG_TYPE_START) {
                self._dragStartPositionY = dragY;
                self._dragLastScroll = dragY;
            } else if (dragEvent.getType() == DRAG_TYPE_CONTINUE) {
                var delta = self._dragStartPositionY - dragY;
                var delta_scroll = self._dragLastScroll - dragY;
                self._dragStartPositionY = dragY;

                if (delta != 0) {
                    if (self._view.ScrollMode == ItemView.SCROLL_DRAG || delta_scroll.abs() >= self._view.UI_dragThreshold) {
                        self._dragLastScroll = dragY;
                        self._view.onScroll(delta_scroll);
                    }
                }
            }

            return true;
        }

        public function onSwipe(swipeEvent as SwipeEvent) as Boolean {
            self._view.Interaction();
            if (self._noDrag) {
                var delta = self._view.ScrollMode == ItemView.SCROLL_SNAP ? 1 : (System.getDeviceSettings().screenHeight * 0.21).toNumber();
                if (swipeEvent.getDirection() == WatchUi.SWIPE_UP) {
                    self._view.onScroll(delta);
                    return true;
                } else if (swipeEvent.getDirection() == WatchUi.SWIPE_DOWN) {
                    self._view.onScroll(delta * -1);
                    return true;
                } else if (swipeEvent.getDirection() == WatchUi.SWIPE_RIGHT) {
                    self._view.goBack();
                    return true;
                }
            }

            return false;
        }

        public function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
            self._view.Interaction();
            var key = keyEvent.getKey();
            if (key == WatchUi.KEY_ENTER) {
                return self._view.onKeyEnter();
            } else if (key == WatchUi.KEY_ESC) {
                return self._view.onKeyEsc();
            } else if (key == WatchUi.KEY_MENU) {
                return self._view.onKeyMenu();
            } else if (key == WatchUi.KEY_UP) {
                if (self._view.ScrollMode == ItemView.SCROLL_DRAG) {
                    self._view.onScroll((System.getDeviceSettings().screenHeight * -0.21).toNumber());
                } else {
                    self._view.onScroll(-1);
                }
                return true;
            } else if (key == WatchUi.KEY_DOWN) {
                if (self._view.ScrollMode == ItemView.SCROLL_DRAG) {
                    self._view.onScroll((System.getDeviceSettings().screenHeight * 0.21).toNumber());
                } else {
                    self._view.onScroll(1);
                }
                return true;
            }

            return false;
        }
    }
}
