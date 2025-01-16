import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.System;
import Lists;

module Views {
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
            self._view.Interaction();
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
                    if (self._view.ScrollMode == CustomView.SCROLL_DRAG || delta_scroll.abs() >= self._view.UI_dragThreshold) {
                        self._dragLastScroll = dragY;
                        self._view.onScroll(delta_scroll);
                    }
                }
            }

            return true;
        }

        function onSwipe(swipeEvent as SwipeEvent) as Boolean {
            self._view.Interaction();
            if (self._useSwipe == true) {
                if (swipeEvent.getDirection() == WatchUi.SWIPE_UP) {
                    self._view.onScroll(1);
                    return true;
                } else if (swipeEvent.getDirection() == WatchUi.SWIPE_DOWN) {
                    self._view.onScroll(-1);
                    return true;
                } else if (swipeEvent.getDirection() == WatchUi.SWIPE_RIGHT) {
                    self._view.goBack();
                    return true;
                }
            }

            return false;
        }

        function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
            self._view.Interaction();
            var key = keyEvent.getKey();
            if (key == WatchUi.KEY_ENTER) {
                Debug.Log("Pressed ENTER");
                if (self._view has :onKeyEnter) {
                    return self._view.onKeyEnter();
                }
            } else if (key == WatchUi.KEY_ESC) {
                Debug.Log("Pressed ESC");
                return self._view.onKeyEsc();
            } else if (key == WatchUi.KEY_MENU) {
                Debug.Log("Pressed MENU");
                if (self._view has :onKeyMenu) {
                    return self._view.onKeyMenu();
                }
            } else if (key == WatchUi.KEY_UP) {
                Debug.Log("Pressed UP");
                if (self._view.ScrollMode == CustomView.SCROLL_DRAG) {
                    var height = System.getDeviceSettings().screenHeight;
                    self._view.onScroll((height * -0.33).toNumber());
                } else {
                    self._view.onScroll(-1);
                }
            } else if (key == WatchUi.KEY_DOWN) {
                Debug.Log("Pressed DOWN");
                if (self._view.ScrollMode == CustomView.SCROLL_DRAG) {
                    var height = System.getDeviceSettings().screenHeight;
                    self._view.onScroll((height * 0.33).toNumber());
                } else {
                    self._view.onScroll(1);
                }
            } else {
                Debug.Log("Pressed " + key);
            }

            return false;
        }
    }
}