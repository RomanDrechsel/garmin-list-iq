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
                //self._view.ScrollMode = ItemView.SCROLL_SNAP;
                self._noDrag = true;
            }
        }

        function onTap(clickEvent) as Boolean {
            var pre__view, pre_0;
            pre_0 = 0;
            pre__view = self._view;
            pre__view.Interaction();
            var tap = pre__view.onTap(clickEvent.getCoordinates()[pre_0], clickEvent.getCoordinates()[1]);
            pre__view /*>now<*/ = System.getTimer();
            if (pre__view /*>now<*/ - self._lastTap < 500) {
                self._lastTap = pre_0;
                self._view.onDoubleTap(clickEvent.getCoordinates()[pre_0], clickEvent.getCoordinates()[1]);
                tap = true;
            } else {
                self._lastTap = pre__view /*>now<*/;
            }
            return tap;
        }

        function onDrag(dragEvent as WatchUi.DragEvent) as Lang.Boolean {
            var pre_1;
            pre_1 = 1;
            self._view.Interaction();
            var dragY = dragEvent.getCoordinates()[pre_1];

            if (dragEvent.getType() == 0) {
                self._dragStartPositionY = dragY;
                self._dragLastScroll = dragY;
            } else if (dragEvent.getType() == pre_1) {
                dragEvent /*>delta<*/ = self._dragStartPositionY - dragY;
                var delta_scroll = self._dragLastScroll - dragY;
                self._dragStartPositionY = dragY;

                if (dragEvent /*>delta<*/ != 0) {
                    if (self._view.ScrollMode == pre_1 || delta_scroll.abs() >= self._view.UI_dragThreshold) {
                        self._dragLastScroll = dragY;
                        self._view.onScroll(delta_scroll);
                    }
                }
            }

            return true;
        }

        function onSwipe(swipeEvent as SwipeEvent) as Boolean {
            var pre__view;
            pre__view = self._view;
            pre__view.Interaction();
            if (self._noDrag == true) {
                pre__view /*>delta<*/ = pre__view.ScrollMode == 0 ? 1 : ($.screenHeight * 0.5).toNumber();
                if (swipeEvent.getDirection() == 0) {
                    self._view.onScroll(pre__view /*>delta<*/);
                    return true;
                } else if (swipeEvent.getDirection() == 2) {
                    self._view.onScroll(pre__view /*>delta<*/ * -1);
                    return true;
                } else if (swipeEvent.getDirection() == 1) {
                    ItemView.goBack();
                    return true;
                }
            }

            return false;
        }

        function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
            var pre__view;
            pre__view = self._view;
            pre__view.Interaction();
            var key = keyEvent.getKey();
            if (key == 4) {
                if (pre__view has :onKeyEnter) {
                    return pre__view.onKeyEnter();
                }
            } else if (key == 5) {
                return pre__view.onKeyEsc();
            } else if (key == 7) {
                if (pre__view has :onKeyMenu) {
                    return pre__view.onKeyMenu();
                }
            } else {
                keyEvent /*>pre_1<*/ = 1;
                if (key == 13) {
                    if (pre__view.ScrollMode == keyEvent /*>pre_1<*/) {
                        keyEvent /*>height<*/ = System.getDeviceSettings().screenHeight;
                        pre__view.onScroll((keyEvent /*>height<*/ * -0.21).toNumber());
                    } else {
                        self._view.onScroll(-1);
                    }
                    return true;
                } else if (key == 8) {
                    if (self._view.ScrollMode == keyEvent /*>pre_1<*/) {
                        keyEvent /*>height<*/ = System.getDeviceSettings().screenHeight;
                        self._view.onScroll((keyEvent /*>height<*/ * 0.21).toNumber());
                    } else {
                        self._view.onScroll(keyEvent /*>pre_1<*/);
                    }
                    return true;
                }
            }

            return false;
        }
    }
}
