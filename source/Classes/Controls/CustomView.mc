import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;
import Controls.Scrollbar;
import Helper;

module Controls {
    class CustomView extends WatchUi.View {
        enum EScrollmode {
            SCROLL_SNAP,
            SCROLL_DRAG,
        }

        var Items as Array<ViewItem> = new Array<ViewItem>[0];

        var ScrollMode = SCROLL_DRAG;
        var UI_dragThreshold = 40;

        static var ScrollbarWidth;

        /** index of the centered item on SCROLL_SNAP - mode */
        private var _snapPosition as Number? = 0;
        /** top-padding of the list in SCROLL_SNAP - mode  */
        private var _paddingTop as Number? = null;
        /** bottom-padding of the list in SCROLL_SNAP - mode */
        private var _paddingBottom as Number? = null;
        /** scroll offset */
        private var _scrollOffset as Number = 0;

        /** additional vertical margin of the list */
        protected var _verticalMargin as Number = 0;
        /** horizontal margin of the list in SCROLL_SNAP - mode */
        protected var _horizonalMargin as Number = 0;

        /** percentage of the width of the scrollbar */
        protected var _BarWidthFactor as Float = 0.05;

        /** special font for the Title-label of the items */
        protected var _fontoverride as FontResource? = null;

        /** scrollbar drawer */
        protected var _scrollbar as Scrollbar.Round or Scrollbar.Rectangle;
        /** is there already a title-item in items-list */
        protected var _hasTitle as Boolean = false;

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
        private var _needValidation as Boolean = true;

        function initialize() {
            View.initialize();
            self.Items = [];
        }

        function onLayout(dc as Dc) {
            View.onLayout(dc);
            dc.setAntiAlias(true);

            self.UI_dragThreshold = (dc.getHeight() / 6).toNumber();
            self._verticalMargin = dc.getHeight() / 30;

            if (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND) {
                var radius = dc.getWidth() / 2;
                self._horizonalMargin = (radius - radius * Math.sin(Math.toRadians(45))).toNumber();
            }

            self.ScrollbarWidth = ((dc.getWidth() - 2 * self._horizonalMargin) * self._BarWidthFactor).toNumber();

            var layerwidth = dc.getWidth() - 2 * self._horizonalMargin - self.ScrollbarWidth;
            self._mainLayer = new LayerDef(dc, self._horizonalMargin, 0, layerwidth, dc.getHeight());
            if (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND) {
                self._scrollbarLayer = new LayerDef(dc, dc.getWidth() / 2, 0, dc.getWidth() / 2, dc.getHeight());
                self._scrollbar = new Scrollbar.Round(self._scrollbarLayer, self.ScrollbarWidth);
                self.ScrollbarWidth = 0;
            } else {
                var barX = self._mainLayer.getX() + self._mainLayer.getWidth();
                self._scrollbarLayer = new LayerDef(dc, barX, self._mainLayer.getY(), self.ScrollbarWidth, self._mainLayer.getHeight());
                self._scrollbar = new Scrollbar.Rectangle(self._scrollbarLayer);
            }

            self._needValidation = true;
            self.validate(dc);
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
                    self.Items[i].draw(dc, self._scrollOffset, i != self.Items.size() - 1);
                }

                if (self._needScrollbar) {
                    self._scrollbar.draw(dc, self._scrollOffset, self._viewHeight);
                }
            }
        }

        function addItem(title as String, substring as String?, identifier as Object?, icon as Number or BitmapResource or Null, position as Number) as Void {
            self.Items.add(new ViewItem(self._mainLayer, title, substring, identifier, icon, self._verticalMargin, position, self._fontoverride));
            self._needValidation = true;
            self._paddingTop = null;
            self._paddingBottom = null;
        }

        function setTitle(title as String?) as Void {
            if (title != null && title.length() > 0) {
                var items = [];
                if (self.Items.size() > 0) {
                    items = self.Items;
                    if (self._hasTitle == true) {
                        items = items.slice(1, null);
                    }
                }
                self._hasTitle = true;
                self.Items = [];
                self.Items.add(new TitleViewItem(self._mainLayer, title));
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
                //delta is negative when scrolling down, else positive
                if (delta > self._scrollOffset) {
                    delta = self._scrollOffset;
                }
                self._scrollOffset -= delta;
                if (self._scrollOffset > self._viewHeight - self._mainLayer.getHeight()) {
                    self._scrollOffset = self._viewHeight - self._mainLayer.getHeight();
                }
            }

            if (startoffset != self._scrollOffset) {
                WatchUi.requestUpdate();
            }
        }

        function onListTap(position as Number, item as ViewItem) as Void;
        function onDoubleTap(x as Number, y as Number) as Void;

        function onTap(x as Number, y as Number) as Boolean {
            for (var i = 0; i < self.Items.size(); i++) {
                var item = self.Items[i];
                if (item.Clicked(y)) {
                    self.onListTap(i, item);
                    return true;
                }
            }

            return false;
        }

        protected function moveIterator(delta as Number?) as Void {
            if (delta == null) {
                self._snapPosition = 0;
                return;
            }
            self._snapPosition += delta;
            if (self._snapPosition < 0) {
                self._snapPosition = 0;
            }

            if (self._snapPosition > self.Items.size() - 1) {
                self._snapPosition = self.Items.size() - 1;
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
            var y = self.Items[index].getListY(); //upper edge of the item
            var h = self.Items[index].getHeight(null); // height of the item
            var c = y + h / 2; // center point of the item

            self._scrollOffset = c - self._mainLayer.getHeight() / 2;
            if (self._scrollOffset < 0) {
                self._scrollOffset = 0;
            } else if (self._scrollOffset > self._viewHeight - self._mainLayer.getHeight()) {
                self._scrollOffset = self._viewHeight - self._mainLayer.getHeight();
            }
            Log("Center item " + index + " at offset " + self._scrollOffset);
        }

        /**
         * on SCROLL_SNAP - mode returns the padding of the top of the first item
         */
        private function getPaddingTop(dc as Dc) as Number {
            if (self._paddingTop == null) {
                if (self.ScrollMode == SCROLL_SNAP && self.Items.size() > 0) {
                    self._paddingTop = self._mainLayer.getHeight() / 2 - self._verticalMargin - (self.Items[0].getHeight(dc) / 2).toNumber();
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
                    self._paddingBottom = self._mainLayer.getHeight() / 2 - self._verticalMargin - (self.Items[self.Items.size() - 1].getHeight(dc) / 2).toNumber();
                } else {
                    self._paddingBottom = 0;
                }
            }
            return self._paddingBottom;
        }

        /** returns the height of all listitems */
        private function getListHeight(dc as Dc) as Number {
            var height = 0;
            for (var i = 0; i < self.Items.size(); i++) {
                height += (self.Items[i] as ViewItem).getHeight(dc);
            }

            return height;
        }

        /**
         * calculate the total height of the list and if a scrollbar is needed
         * and set the relative y-coordinates for all items
         */
        protected function validate(dc as Dc) {
            if (self._needValidation == true) {
                var y = self._verticalMargin + self.getPaddingTop(dc);
                for (var i = 0; i < self.Items.size(); i++) {
                    var item = self.Items[i];
                    item.setListY(y);
                    y += item.getHeight(dc);
                }

                self._viewHeight = y + self.getPaddingBottom(dc) + self._verticalMargin;
                self._needScrollbar = self._mainLayer.getHeight() < self._viewHeight;
            }
        }
    }
}
