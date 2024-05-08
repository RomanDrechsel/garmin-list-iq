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

        static var ScrollbarSpace;

        private var _snapPosition = 0;
        private var _scrollOffset = 0;
        private var _paddingTop = null;
        private var _paddingBottom = null;

        protected var _margin = 0;
        protected var _verticalPadding = 0;
        protected var _BarWidthFactor = 0.05;
        protected var _fontoverride = null;

        protected var _scrollbar;
        protected var _hasTitle = false;

        protected var _mainLayer as LayerDef?;
        protected var _scrollbarLayer as LayerDef?;

        protected var _totalHeight as Number? = null;
        protected var _needScrollbar as Boolean? = null;

        function initialize() {
            View.initialize();
            self.Items = [];
        }

        function onLayout(dc as Dc) {
            dc.setAntiAlias(true);

            View.onLayout(dc);

            self.UI_dragThreshold = (dc.getHeight() / 6).toNumber();
            self._verticalPadding = dc.getHeight() / 30;

            self._margin = 0;
            if (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND) {
                var radius = dc.getWidth() / 2;
                self._margin = (radius - radius * Math.sin(Math.toRadians(45))).toNumber();
            }

            self.ScrollbarSpace = ((dc.getWidth() - 2 * self._margin) * self._BarWidthFactor).toNumber();

            var layerwidth = dc.getWidth() - 2 * self._margin;
            self._mainLayer = new LayerDef(dc, self._margin, 0, layerwidth, dc.getHeight());
            if (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND) {
                self._scrollbarLayer = new LayerDef(dc, dc.getWidth() / 2, 0, dc.getWidth() / 2, dc.getHeight());
                self._scrollbar = new Scrollbar.Round(self._scrollbarLayer, self.ScrollbarSpace);
                self.ScrollbarSpace = 0;
            } else {
                var barX = self._mainLayer.getX() + self._mainLayer.getWidth() - self.ScrollbarSpace;
                self._scrollbarLayer = new LayerDef(dc, barX, self._mainLayer.getY(), self.ScrollbarSpace, self._mainLayer.getHeight());
                self._scrollbar = new Scrollbar.Rectangle(self._scrollbarLayer);
            }

            self.validate(dc);
        }

        function drawList(dc as Dc) as Void {
            if (self._mainLayer == null) {
                return;
            }

            self.validate(dc);

            dc.setColor(getTheme().ListBackground, getTheme().ListBackground);
            dc.clear();
            dc.setAntiAlias(true);

            if (self.Items.size() > 0) {
                var y;
                if (self.ScrollMode == SCROLL_SNAP) {
                    y = self.getCenterItem(dc, self._snapPosition);
                    if (self._snapPosition == 0 && y < self._margin) {
                        y = self._margin;
                    }
                } else {
                    y = self._scrollOffset + self._margin;
                }

                var scrollY = y - self.getPaddingTop(dc) - self._margin;
                scrollY *= -1;

                for (var i = 0; i < self.Items.size(); i++) {
                    var item = self.Items[i];
                    if (y > dc.getHeight()) {
                        //outside lower screenborder
                        item.setBoundaries(-1, -1);
                    } else if (y < item.getHeight(dc) * -1) {
                        //outside upper screenborder
                        item.setBoundaries(-1, -1);
                        y += item.getHeight(dc);
                    } else {
                        y = item.draw(dc, y, i != self.Items.size() - 1);
                    }
                }

                if (self._scrollbar != null && self._scrollbarLayer != null) {
                    var totalheight = self.getTotalHeight();
                    var viewport = dc.getHeight() - self._margin * 2;
                    var maxscroll = totalheight - viewport;
                    self._scrollbar.draw(dc, scrollY.toFloat(), maxscroll.toFloat(), totalheight.toFloat(), viewport);
                }
            }
        }

        function addItem(title as String, substring as String?, identifier as Object?, icon as Number or BitmapResource or Null, position as Number) as Void {
            self.Items.add(new ViewItem(self._mainLayer, title, substring, identifier, icon, self._verticalPadding, position, self._fontoverride));
            self._totalHeight = null;
            self._needScrollbar = null;
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
                self._totalHeight = null;
                self._needScrollbar = null;
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

            if (self.ScrollMode == SCROLL_SNAP) {
                self.moveIterator(delta > 0 ? 1 : -1);
            } else if (self.needScrollbar()) {
                var startoffset = self._scrollOffset;
                self._scrollOffset -= delta;

                var viewport = self._mainLayer.getHeight() - self._margin * 2;
                var maxscroll = self.getTotalHeight() - viewport;
                var minY = -maxscroll;

                if (self._scrollOffset < minY) {
                    self._scrollOffset = minY;
                } else if (self._scrollOffset > 0) {
                    self._scrollOffset = 0;
                }

                if (startoffset != self._scrollOffset) {
                    WatchUi.requestUpdate();
                }
            }
        }

        function onListTap(position as Number, item as ViewItem) as Void;
        function onDoubleTap(x as Number, y as Number) as Void;

        function onTap(x as Number, y as Number) as Boolean {
            if (self._mainLayer == null) {
                return false;
            }

            if (x < self._mainLayer.getX() || x > self._mainLayer.getX() + self._mainLayer.getWidth() || y < self._mainLayer.getY() || y > self._mainLayer.getY() + self._mainLayer.getHeight()) {
                return false;
            }

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
            var pos = self._snapPosition;
            self._snapPosition += delta;
            if (self._snapPosition < 0) {
                self._snapPosition = 0;
            }

            if (self._snapPosition > self.Items.size() - 1) {
                self._snapPosition = self.Items.size() - 1;
            }

            if (pos != self._snapPosition) {
                WatchUi.requestUpdate();
            }
        }

        private function getCenterItem(dc as Dc, index as Number) as Number {
            var y = 0;
            for (var i = 0; i < index; i++) {
                y -= (self.Items[i] as ViewItem).getHeight(dc);
            }

            y += (self._mainLayer.getHeight() - (self.Items[index] as ViewItem).getHeight(dc)) / 2;
            return y;
        }

        private function getTotalHeight() as Number {
            if (self._totalHeight == null) {
                return -1;
            }
            return self._totalHeight;
        }

        private function getPaddingTop(dc as Dc) as Number {
            if (self._paddingTop == null) {
                if (self.ScrollMode == SCROLL_SNAP && self.Items.size() > 0) {
                    self._paddingTop = self._mainLayer.getHeight() / 2 - self._margin - (self.Items[0].getHeight(dc) / 2).toNumber();
                } else {
                    self._paddingTop = 0;
                }
            }

            return self._paddingTop;
        }

        private function getPaddingBottom(dc as Dc) as Number {
            if (self._paddingBottom == null) {
                if (self.ScrollMode == SCROLL_SNAP && self.Items.size() > 0) {
                    self._paddingBottom = self._mainLayer.getHeight() / 2 - self._margin - (self.Items[self.Items.size() - 1].getHeight(dc) / 2).toNumber();
                } else {
                    self._paddingBottom = 0;
                }
            }
            return self._paddingBottom;
        }

        protected function validate(dc as Dc) {
            if (self._totalHeight == null) {
                self._totalHeight = 0;
                for (var i = 0; i < self.Items.size(); i++) {
                    self._totalHeight += (self.Items[i] as ViewItem).getHeight(dc);
                }

                self._totalHeight += self.getPaddingTop(dc) + self.getPaddingBottom(dc);
            }

            if (self._needScrollbar == null) {
                self._needScrollbar = self._mainLayer.getHeight() - self._margin * 2 < self._totalHeight;
            }
        }
    }
}
