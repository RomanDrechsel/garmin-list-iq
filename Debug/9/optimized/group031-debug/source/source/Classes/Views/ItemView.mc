using Rez;
using Debug;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Time;
import Toybox.System;
import Controls;
import Helper;
import Controls.Listitems;

module Views {
    class ItemView extends WatchUi.View {
        typedef EScrollmode as Toybox.Lang.Number;

        typedef EControls as Toybox.Lang.Number;

        var Items as Array<Item> = new Array<Item>[0];
        protected var _selectedItem as Listitems.Item? = null;

        var ScrollMode = 1;
        var UI_dragThreshold = 40;

        /** top-padding of the list in SCROLL_SNAP - mode  */
        private var _paddingTop as Number? = null;
        /** bottom-padding of the list in SCROLL_SNAP - mode */
        private var _paddingBottom as Number? = null;
        /** scroll offset */
        protected var _scrollOffset as Number = 0;

        /** index of the centered item on SCROLL_SNAP - mode */
        protected var _snapPosition as Number = 0;

        /** percentage of the width of the scrollbar */
        protected var _BarWidthFactor as Float = 0.05;

        /** scrollbar drawer */
        protected var _scrollbar as Scrollbar?;

        /** main layer for the list */
        protected var _mainLayer as Controls.LayerDef?;
        /** layer for the scrollbar */
        protected var _scrollbarLayer as Controls.LayerDef?;

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

        /** what kind of controls does the view use */
        protected static var _controls as EControls? = null;

        /**
         * center on an item on the next draw
         * useful if an item is set before self.validate(), e.g. in onLayout()
         */
        protected var _centerItemOnDraw as Number or Listitems.Item or Null = null;

        /** display hardware button support? */
        protected static var _buttonDisplay as Boolean? = null;

        function onLayout(dc as Dc) {
            var pre_0, pre_2;
            View.onLayout(dc);
            if (dc has :setAntialias) {
                dc.setAntiAlias(true);
            }

            pre_2 = 2;
            pre_0 = 0;
            self.Interaction();
            self.Items = new Array<Item>[pre_0];

            self.UI_dragThreshold = (dc.getHeight() / 6).toNumber();
            var mainLayerMargin = self.getMargin(dc);
            var scrollbarwidth = (dc.getWidth() * self._BarWidthFactor).toNumber();
            self._mainLayer = new Controls.LayerDef(mainLayerMargin[pre_0], mainLayerMargin[1], dc.getWidth() - mainLayerMargin[pre_0] * pre_2 - scrollbarwidth, dc.getHeight() - mainLayerMargin[1] * pre_2);
            if ($.isRoundDisplay) {
                self._scrollbarLayer = new Controls.LayerDef(dc.getWidth() / pre_2, pre_0, dc.getWidth() / pre_2, dc.getHeight());
            } else {
                self._scrollbarLayer = new Controls.LayerDef(dc.getWidth() - scrollbarwidth, pre_0, scrollbarwidth, dc.getHeight());
            }
            self._scrollbar = new Controls.Scrollbar(self._scrollbarLayer, scrollbarwidth);
        }

        function onShow() as Void {
            var pre_0;
            pre_0 = 0;
            if ($.getApp().GlobalStates.hasKey("startpage")) {
                if (self instanceof ListsSelectView == false) {
                    WatchUi.popView(pre_0 as Toybox.WatchUi.SlideType);
                    return;
                } else {
                    $.getApp().GlobalStates.remove("startpage");
                }
            } else {
                self.Interaction();
            }
            if ($.getApp().GlobalStates.hasKey("movetop")) {
                self._scrollOffset = pre_0;
                self.setIterator(pre_0);
                $.getApp().GlobalStates.remove("movetop");
            }
            WatchUi.View.onShow();
            $.getApp().addSettingsChangedListener(self);
        }

        function onHide() as Void {
            WatchUi.View.onHide();
            self.Interaction();
        }

        function onUpdate(dc as Dc) as Void {
            WatchUi.View.onUpdate(dc);
            self.drawList(dc);
        }

        function drawList(dc as Dc) as Void {
            var pre_0;
            dc.setColor(getTheme().BackgroundColor, getTheme().BackgroundColor);
            dc.clear();

            if (self._mainLayer == null) {
                return;
            }

            self.validate(dc);
            if (self._centerItemOnDraw != null) {
                self.centerItem(self._centerItemOnDraw);
                self._centerItemOnDraw = null;
            }

            pre_0 = 0;
            if (self.ScrollMode == pre_0) {
                self.setIterator(self._snapPosition);
            }

            if (self.Items.size() > pre_0) {
                for (var i = pre_0; i < self.Items.size(); i += 1) {
                    pre_0 /*>item<*/ = self.Items[i];
                    pre_0 /*>item<*/.draw(dc, self._scrollOffset, self._selectedItem == pre_0 /*>item<*/);
                }

                if (self.needScrollbar()) {
                    pre_0 /*>viewport_height<*/ = dc.getHeight();
                    if ($.isRoundDisplay) {
                        pre_0 /*>viewport_height<*/ -= self.getMargin(dc)[1] * 2;
                    }
                    self._scrollbar.draw(dc, self._scrollOffset, self._viewHeight, pre_0 /*>viewport_height<*/);
                }
            }
        }

        function addItem(title as String or Array<String>, substring as String or Array<String> or Null, identifier as Object?, icon as Number or BitmapResource or Null, position as Number) as Listitems.Item {
            title /*>item<*/ = new Listitems.Item(self._mainLayer, title, substring, identifier, icon, null, position, null);
            self.Items.add(title /*>item<*/);
            self._needValidation = true;
            return title /*>item<*/;
        }

        function setTitle(title as String?) as Void {
            var pre_0;
            pre_0 = 0;
            if (title != null && title.length() > pre_0) {
                var items;
                if (self.Items.size() > pre_0 && self.Items[pre_0] instanceof Listitems.Title) {
                    items = self.Items.slice(1, null);
                } else {
                    items = self.Items;
                }
                self.Items = [new Listitems.Title(self._mainLayer, title)];
                if (items.size() > pre_0) {
                    self.Items.addAll(items);
                }
                self._needValidation = true;
            }
        }

        function needScrollbar() as Boolean {
            var pre__needScrollbar;
            pre__needScrollbar = self._needScrollbar;
            if (pre__needScrollbar == null) {
                return false;
            }
            return pre__needScrollbar;
        }

        function onScroll(delta as Number) as Void {
            var pre_0;
            pre_0 = 0;
            if (delta == pre_0 || self._mainLayer == null) {
                return;
            }

            var startoffset = self._scrollOffset;

            if (self.ScrollMode == pre_0) {
                self.moveIterator(delta > pre_0 ? 1 : -1);
            } else if (self.needScrollbar()) {
                //delta is negative when scrolling up, else positive
                self._scrollOffset += delta;
                if (self._scrollOffset < pre_0) {
                    self._scrollOffset = pre_0;
                } else if (self._scrollOffset > self._viewHeight - self._mainLayer.getHeight()) {
                    self._scrollOffset = self._viewHeight - self._mainLayer.getHeight();
                }
                self.setCenterItemSelected();
            }

            if (startoffset != self._scrollOffset) {
                WatchUi.requestUpdate();
            }
        }

        function onDoubleTap(x as Number, y as Number) as Boolean {
            {
                x /*>i<*/ = 0;
                for (; x /*>i<*/ < self.Items.size(); x /*>i<*/ += 1) {
                    var item = self.Items[x /*>i<*/];
                    if (item.Clicked(y, self._scrollOffset)) {
                        self.interactItem(item, true);
                        return true;
                    }
                }
            }
            return false;
        }

        function onTap(x as Number, y as Number) as Boolean {
            {
                x /*>i<*/ = 0;
                for (; x /*>i<*/ < self.Items.size(); x /*>i<*/ += 1) {
                    var item = self.Items[x /*>i<*/];
                    if (item.Clicked(y, self._scrollOffset)) {
                        self.interactItem(item, false);
                        return true;
                    }
                }
            }

            return false;
        }

        function onSettingsChanged() as Void {
            self._buttonDisplay = null;
            self.setIterator(0);
            self._scrollOffset = 0;
        }

        function Interaction() as Void {
            var inactivity = $.getApp().Inactivity;
            if (inactivity != null) {
                inactivity.Interaction();
            }
        }

        function onKeyEnter() as Boolean {
            if (!self.DisplayButtonSupport() && !$.getApp().NoBackButton) {
                return self.onKeyMenu();
            } else if (self._selectedItem != null) {
                return self.interactItem(self._selectedItem, true);
            }
            return false;
        }

        function onKeyMenu() as Boolean {
            return false;
        }

        function onKeyEsc() as Boolean {
            return false;
        }

        static function goBack() {
            Debug.Log("Go Back");
            WatchUi.popView(2 as Toybox.WatchUi.SlideType);
        }

        protected function moveIterator(delta as Number?) as Void {
            if (delta == null) {
                self.setIterator(null);
            } else {
                self.setIterator(self._snapPosition + delta);
            }
        }

        protected function setIterator(pos as Number?) as Void {
            var pre_Items, pre_0;
            pre_0 = 0;
            if (self.ScrollMode == pre_0) {
                pre_Items = self.Items;
                if (pos == null) {
                    pos = pre_0;
                } else if (pos >= pre_Items.size()) {
                    pos = self.Items.size() - 1;
                }
                if (pos < pre_0) {
                    pos = pre_0;
                }

                if (pre_Items.size() > pre_0) {
                    while (self.Items.size() > pos && self.Items[pos] instanceof Listitems.Title) {
                        pos += 1;
                    }
                }
                self._snapPosition = pos;
                self.centerItem(self._snapPosition);
            }
        }

        private function getHeight() {
            var pre__viewHeight;
            pre__viewHeight = self._viewHeight;
            if (pre__viewHeight != null) {
                return pre__viewHeight;
            } else {
                return 0;
            }
        }

        private function centerItem(item as Number or Listitems.Item) {
            var pre_0;
            pre_0 = 0;
            if (item instanceof Number) {
                if (item >= pre_0 && self.Items.size() > item) {
                    item = self.Items[item];
                } else {
                    item = null;
                }
            }

            if (item == null) {
                return;
            } //upper edge of the item // height of the item // center point of the item

            self._scrollOffset = item.getListY() + item.getHeight(null) / 2 - self._mainLayer.getHeight() / 2;
            if (self._scrollOffset < pre_0) {
                self._scrollOffset = pre_0;
            } else if (self._scrollOffset > self._viewHeight - self._mainLayer.getHeight()) {
                self._scrollOffset = self._viewHeight - self._mainLayer.getHeight();
            }

            self._selectedItem = item;
        }

        /**
         * return the horizontal and vertical margin of the main-layer on round displays
         */
        private function getMargin(dc as Dc) as Array<Number> {
            if ($.isRoundDisplay) {
                dc /*>radius<*/ = dc.getWidth() / 2;
                return [(dc /*>radius<*/ - dc /*>radius<*/ * 0.81915205).toNumber(), (dc /*>radius<*/ - dc /*>radius<*/ * 0.57357645).toNumber()];
            } else {
                return [(dc.getWidth() / 20).toNumber(), 0];
            }
        }

        /**
         * calculate the total height of the list and if a scrollbar is needed
         * and set the relative y-coordinates for all items
         */
        protected function validate(dc as Dc) as Void {
            var pre_0, pre_1, pre_2;
            if (self._needValidation == true) {
                pre_2 = 2;
                pre_1 = 1;
                pre_0 = 0;
                if (self.DisplayButtonSupport() || $.isRoundDisplay) {
                    if (self.Items.size() > pre_0) {
                        if (self.Items[pre_0] instanceof Listitems.Title) {
                            self._paddingTop = self._mainLayer.getHeight() / pre_2 - (self.Items[pre_1].getHeight(dc) / pre_2).toNumber() - self.Items[pre_0].getHeight(dc);
                        } else {
                            self._paddingTop = self._mainLayer.getHeight() / pre_2 - (self.Items[pre_0].getHeight(dc) / pre_2).toNumber();
                        }
                    } else {
                        self._paddingTop = pre_0;
                    }
                } else {
                    self._paddingTop = pre_0;
                }

                var y = self._paddingTop;
                for (var i = pre_0; i < self.Items.size(); i += pre_1) {
                    var item = self.Items[i];
                    //item.setLayer(self._mainLayer);
                    item.setListY(y);
                    item.Invalidate();
                    y += item.getHeight(dc);
                }

                if (self.DisplayButtonSupport() || $.isRoundDisplay) {
                    if (self.Items.size() > pre_0) {
                        self._paddingBottom = self._mainLayer.getHeight() / pre_2 - (self.Items[self.Items.size() - pre_1].getHeight(dc) / pre_2).toNumber();
                        if (self._paddingBottom < pre_0) {
                            self._paddingBottom = pre_0;
                        }
                    } else {
                        self._paddingBottom = pre_0;
                    }
                } else {
                    self._paddingBottom = pre_0;
                }
                self._viewHeight = y + self._paddingBottom;
                self._needScrollbar = self._mainLayer.getHeight() < self._viewHeight;
                self._needValidation = false;
                self.setCenterItemSelected();
            }
        }

        protected function addSettingsButton() as Void {
            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StTitle), "settings", ($.screenHeight * 0.1).toNumber(), false));
        }

        protected function addBackButton(quit as Boolean) as Void {
            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(quit ? Rez.Strings.Quit : Rez.Strings.Back), quit ? "quit" : "back", ($.screenHeight * 0.1).toNumber(), false));
        }

        protected function interactItem(item as Listitems.Item, doubletap as Boolean) as Boolean {
            if (item.BoundObject instanceof String) {
                if (item.BoundObject.equals("back")) {
                    self.goBack();
                    return true;
                } else if (item.BoundObject.equals("quit")) {
                    System.exit();
                    return true;
                }
            }
            return false;
        }

        protected function setCenterItemSelected() as Void {
            var centerY = $.screenHeight / 2;
            for (var i = 0; i < self.Items.size(); i += 1) {
                if (self.Items[i].Clicked(centerY, self._scrollOffset)) {
                    self._selectedItem = self.Items[i];
                    return;
                }
            }
            self._selectedItem = null;
        }

        static function SupportedControls() as EControls {
            var pre_0;
            if (self._controls == null) {
                pre_0 = 0;
                var settings = System.getDeviceSettings();
                if (settings.isTouchScreen) {
                    if ((settings.inputButtons & 2) != pre_0 && (settings.inputButtons & 4) != pre_0) {
                        self._controls = 2;
                    } else {
                        self._controls = 1;
                    }
                } else {
                    self._controls = pre_0;
                }
            }
            return self._controls;
        }

        static function DisplayButtonSupport() as Boolean {
            if (self._buttonDisplay == null) {
                if ((System.getDeviceSettings().inputButtons & 8) == 0) {
                    //only 1 button
                    return true;
                }
                var controls = self.SupportedControls();
                if (controls == 1) {
                    self._buttonDisplay = false;
                } else if (controls == 0) {
                    self._buttonDisplay = true;
                } else {
                    self._buttonDisplay = Helper.Properties.Get("HWBCtrl", false);
                }
            }
            return self._buttonDisplay;
        }
    }
}
