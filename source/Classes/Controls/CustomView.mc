import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;
import Controls.Scrollbar;
import Helper;
import Controls.Listitems;

module Controls {
    class CustomView extends WatchUi.View {
        protected var TAG = "CustomView";

        enum EScrollmode {
            SCROLL_SNAP,
            SCROLL_DRAG,
        }

        var Items as Array<Item> = new Array<Item>[0];

        var ScrollMode = SCROLL_DRAG;
        var UI_dragThreshold = 40;

        /** top-padding of the list in SCROLL_SNAP - mode  */
        private var _paddingTop as Number? = null;
        /** bottom-padding of the list in SCROLL_SNAP - mode */
        private var _paddingBottom as Number? = null;
        /** scroll offset */
        private var _scrollOffset as Number = 0;

        /** index of the centered item on SCROLL_SNAP - mode */
        protected var _snapPosition as Number? = 0;
        /** margin of the items */
        protected var _verticalItemMargin as Number = 0;

        /** percentage of the width of the scrollbar */
        protected var _BarWidthFactor as Float = 0.05;

        /** special font for the Title-label of the items */
        protected var _fontoverride as FontResource? = null;

        /** scrollbar drawer */
        protected var _scrollbar as Scrollbar.Round or Scrollbar.Rectangle;

        /** main layer for the list */
        protected var _mainLayer as LayerDef?;
        /** layer for the scrollbar */
        protected var _scrollbarLayer as LayerDef?;

        /**
         * total height of the list, with Padding of top and bottom
         * null means there is a calculation nessesary
         */
        protected var _viewHeight as Number? = null;
        /**
         * is a scrollbar needed?
         * null means there is a calculation nessesary
         */
        protected var _needScrollbar as Boolean? = null;

        /** is a new validation needed? */
        protected var _needValidation as Boolean = true;

        function initialize() {
            View.initialize();
            self.Items = [];
            Debug.Log("Initialized " + self.TAG);
        }

        function onLayout(dc as Dc) {
            View.onLayout(dc);
            if (dc has :setAntialias) {
                dc.setAntiAlias(true);
            }

            self.UI_dragThreshold = (dc.getHeight() / 6).toNumber();
            self._verticalItemMargin = (dc.getHeight() * 0.05).toNumber();

            var mainLayerMargin = self.getMargin(dc);
            var scrollbarwidth = (dc.getWidth() * self._BarWidthFactor).toNumber();
            var layerwidth = dc.getWidth() - 2 * mainLayerMargin[0];
            var layerheight = dc.getHeight() - 2 * mainLayerMargin[1];
            if ($.isRoundDisplay == false) {
                layerwidth -= scrollbarwidth;
            }

            self._mainLayer = new LayerDef(dc, mainLayerMargin[0], mainLayerMargin[1], layerwidth, layerheight);
            if ($.isRoundDisplay) {
                self._scrollbarLayer = new LayerDef(dc, dc.getWidth() / 2, 0, dc.getWidth() / 2, dc.getHeight());
                self._scrollbar = new Scrollbar.Round(self._scrollbarLayer, scrollbarwidth);
            } else {
                var barX = self._mainLayer.getX() + self._mainLayer.getWidth();
                self._scrollbarLayer = new LayerDef(dc, barX, 0, scrollbarwidth, dc.getHeight());
                self._scrollbar = new Scrollbar.Rectangle(self._scrollbarLayer);
            }

            self._needValidation = true;
            self.validate(dc);
        }

        function onShow() as Void {
            if ($.getApp().GlobalStates.hasKey("movetop")) {
                self._scrollOffset = 0;
                self._snapPosition = 0;
                $.getApp().GlobalStates.remove("movetop");
            }
            WatchUi.View.onShow();
            Debug.Log("onShow " + self.TAG);
        }

        function onHide() as Void {
            WatchUi.View.onHide();
            Debug.Log("OnHide " + self.TAG);
        }

        function drawList(dc as Dc) as Void {
            if (self._mainLayer == null) {
                return;
            }

            dc.setColor(getTheme().ListBackground, getTheme().ListBackground);
            dc.clear();

            self.validate(dc);

            if (self.Items.size() > 0) {
                for (var i = 0; i < self.Items.size(); i++) {
                    self.Items[i].draw(dc, self._scrollOffset);
                }

                if (self._needScrollbar) {
                    var viewport_height = dc.getHeight();
                    if ($.isRoundDisplay) {
                        var margin = self.getMargin(dc);
                        viewport_height -= 2 * margin[1];
                    }
                    self._scrollbar.draw(dc, self._scrollOffset, self._viewHeight, viewport_height);
                }
            }
        }

        function addItem(title as String, substring as String?, identifier as Object?, icon as Number or BitmapResource or Null, position as Number) as Void {
            self.Items.add(new Listitems.Item(self._mainLayer, title, substring, identifier, icon, self._verticalItemMargin, position, self._fontoverride));

            //no line below the last item
            for (var i = 0; i < self.Items.size(); i++) {
                var item = self.Items[i];
                if (item instanceof Listitems.Button == false && item instanceof Listitems.Title == false) {
                    if (i < self.Items.size() - 1) {
                        item.DrawLine = true;
                    } else {
                        item.DrawLine = false;
                    }
                }
            }
            self._needValidation = true;
            self._paddingTop = null;
            self._paddingBottom = null;
        }

        function setTitle(title as String?) as Void {
            if (title != null && title.length() > 0) {
                var items;
                if (self.Items.size() > 0 && self.Items[0] instanceof Listitems.Title) {
                    items = self.Items.slice(1, null);
                } else {
                    items = self.Items;
                }
                self.Items = [new Listitems.Title(self._mainLayer, title)];
                if (items.size() > 0) {
                    self.Items.addAll(items);
                }
                self._needValidation = true;
            }
        }

        function needScrollbar() as Boolean {
            if (self._needScrollbar == null) {
                return false;
            }
            return self._needScrollbar;
        }

        function onScroll(delta as Number) as Void {
            if (delta == 0 || self._mainLayer == null) {
                return;
            }

            var startoffset = self._scrollOffset;

            if (self.ScrollMode == SCROLL_SNAP) {
                self.moveIterator(delta > 0 ? 1 : -1);
            } else if (self.needScrollbar()) {
                //delta is negative when scrolling up, else positive
                self._scrollOffset += delta;
                if (self._scrollOffset < 0) {
                    self._scrollOffset = 0;
                } else if (self._scrollOffset > self._viewHeight - self._mainLayer.getHeight()) {
                    self._scrollOffset = self._viewHeight - self._mainLayer.getHeight();
                }
            }

            if (startoffset != self._scrollOffset) {
                WatchUi.requestUpdate();
            }
        }

        function onListTap(position as Number, item as Item, doubletap as Boolean) as Void;

        function onDoubleTap(x as Number, y as Number) as Boolean {
            for (var i = 0; i < self.Items.size(); i++) {
                var item = self.Items[i];
                if (item.Clicked(y)) {
                    self.onListTap(i, item, true);
                    return true;
                }
            }
            return false;
        }

        function onTap(x as Number, y as Number) as Boolean {
            for (var i = 0; i < self.Items.size(); i++) {
                var item = self.Items[i];
                if (item.Clicked(y)) {
                    self.onListTap(i, item, false);
                    return true;
                }
            }

            return false;
        }

        protected function moveIterator(delta as Number?) as Void {
            if (delta == null) {
                self._snapPosition = 0;
            } else {
                self._snapPosition += delta;
                if (self._snapPosition < 0) {
                    self._snapPosition = 0;
                }

                if (self._snapPosition > self.Items.size() - 1) {
                    self._snapPosition = self.Items.size() - 1;
                }
            }

            self.centerItem(self._snapPosition);
        }

        private function getHeight() {
            if (self._viewHeight != null) {
                return self._viewHeight;
            } else {
                return 0;
            }
        }

        private function centerItem(index as Number) {
            if (index < 0 || self.Items.size() < index + 1) {
                return;
            }

            var item = self.Items[index];
            var y = item.getListY(); //upper edge of the item
            var h = item.getHeight(null); // height of the item
            var c = y + h / 2; // center point of the item

            self._scrollOffset = c - self._mainLayer.getHeight() / 2;
            if (self._scrollOffset < 0) {
                self._scrollOffset = 0;
            } else if (self._scrollOffset > self._viewHeight - self._mainLayer.getHeight()) {
                self._scrollOffset = self._viewHeight - self._mainLayer.getHeight();
            }
        }

        /**
         * on SCROLL_SNAP - mode returns the padding of the top of the first item
         */
        private function getPaddingTop(dc as Dc) as Number {
            if (self._paddingTop == null) {
                if (self.ScrollMode == SCROLL_SNAP && self.Items.size() > 0) {
                    self._paddingTop = self._mainLayer.getHeight() / 2 - (self.Items[0].getHeight(dc) / 2).toNumber();
                } else {
                    self._paddingTop = 0;
                }
            }

            return self._paddingTop;
        }

        /**
         * on SCROLL_SNAP - mode returns the padding of the bottom of the last item
         */
        private function getPaddingBottom(dc as Dc) as Number {
            if (self._paddingBottom == null) {
                if (self.ScrollMode == SCROLL_SNAP && self.Items.size() > 0) {
                    self._paddingBottom = self._mainLayer.getHeight() / 2 - (self.Items[self.Items.size() - 1].getHeight(dc) / 2).toNumber();
                } else {
                    self._paddingBottom = self._verticalItemMargin;
                }
            }
            return self._paddingBottom;
        }

        /**
         * returns the height of all listitems
         */
        private function getListHeight(dc as Dc) as Number {
            var height = 0;
            for (var i = 0; i < self.Items.size(); i++) {
                height += (self.Items[i] as Item).getHeight(dc);
            }

            return height;
        }

        /**
         * return the horizontal and vertical margin of the main-layer on round displays
         */
        private function getMargin(dc as Dc) as Array<Number> {
            if ($.isRoundDisplay) {
                var radius = dc.getWidth() / 2;
                var marginX = (radius - radius * Math.sin(Math.toRadians(55))).toNumber();
                var marginY = (radius - radius * Math.cos(Math.toRadians(55))).toNumber();
                return [marginX, marginY];
            } else {
                return [0, 0];
            }
        }

        /**
         * calculate the total height of the list and if a scrollbar is needed
         * and set the relative y-coordinates for all items
         */
        protected function validate(dc as Dc) {
            if (self._needValidation == true) {
                var y = self.getPaddingTop(dc);
                for (var i = 0; i < self.Items.size(); i++) {
                    var item = self.Items[i];
                    item.setLayer(self._mainLayer);
                    item.setListY(y);
                    item.Invalidate();
                    y += item.getHeight(dc);
                }

                self._viewHeight = y + self.getPaddingBottom(dc);
                self._needScrollbar = self._mainLayer.getHeight() < self._viewHeight;

                var layerwidth;

                if ($.isRoundDisplay) {
                    var margin = self.getMargin(dc);
                    layerwidth = dc.getWidth() - 2 * margin[0];
                } else {
                    layerwidth = dc.getWidth();
                    if (self._needScrollbar == true) {
                        var scrollbarwidth = (dc.getWidth() * self._BarWidthFactor).toNumber();
                        layerwidth -= scrollbarwidth;
                    }
                }
                if (layerwidth != self._mainLayer.getWidth()) {
                    self._mainLayer.setWidth(layerwidth);
                    for (var i = 0; i < self.Items.size(); i++) {
                        self.Items[i].Invalidate();
                    }
                }
            }
        }
    }
}
