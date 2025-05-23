import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Time;
import Toybox.System;
import Controls;
import Exceptions;
import Controls.Listitems;

module Views {
    class ItemView extends WatchUi.View {
        enum EScrollmode {
            SCROLL_SNAP,
            SCROLL_DRAG,
        }

        enum EControls {
            CONTROLS_BUTTONS,
            CONTROLS_TOUCHSCREEN,
            CONTROLS_BOTH,
        }

        enum EButtons {
            SETTINGS = -1,
            BACK = -2,
            QUIT = -3,
        }

        var Items as Array<Item> = new Array<Item>[0];
        protected var _selectedItem as Listitems.Item? = null;

        var ScrollMode = SCROLL_DRAG;
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

        function initialize() {
            WatchUi.View.initialize();
        }

        function onLayout(dc as Dc) {
            View.onLayout(dc);
            if (dc has :setAntiAlias) {
                dc.setAntiAlias(true);
            }

            self.Interaction();
            self.Items = new Array<Item>[0];

            self.UI_dragThreshold = (dc.getHeight() / 6).toNumber();
            var mainLayerMargin = self.getMargin(dc);
            var scrollbarwidth = (dc.getWidth() * self._BarWidthFactor).toNumber();
            var layerwidth = dc.getWidth() - 2 * mainLayerMargin[0] - scrollbarwidth;
            var layerheight = dc.getHeight() - 2 * mainLayerMargin[1];

            self._mainLayer = new Controls.LayerDef(mainLayerMargin[0], mainLayerMargin[1], layerwidth, layerheight);
            if ($.isRoundDisplay) {
                self._scrollbarLayer = new Controls.LayerDef(dc.getWidth() / 2, 0, dc.getWidth() / 2, dc.getHeight());
            } else {
                self._scrollbarLayer = new Controls.LayerDef(dc.getWidth() - scrollbarwidth, 0, scrollbarwidth, dc.getHeight());
            }
            self._scrollbar = new Controls.Scrollbar(self._scrollbarLayer, scrollbarwidth);
        }

        function onShow() as Void {
            if ($.getApp().GlobalStates.indexOf(ListsApp.STARTPAGE) >= 0) {
                if (!(self instanceof ListsSelectView)) {
                    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                    return;
                } else {
                    $.getApp().GlobalStates.removeAll(ListsApp.STARTPAGE);
                }
            } else {
                self.Interaction();
            }
            if ($.getApp().GlobalStates.indexOf(ListsApp.MOVETOP) >= 0) {
                self._scrollOffset = 0;
                self.setIterator(0);
                $.getApp().GlobalStates.removeAll(ListsApp.MOVETOP);
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

            if (self.ScrollMode == SCROLL_SNAP) {
                self.setIterator(self._snapPosition);
            }

            if (self.Items.size() > 0) {
                for (var i = 0; i < self.Items.size(); i++) {
                    var item = self.Items[i];
                    item.draw(dc, self._scrollOffset, self._selectedItem == item);
                }

                if (self.needScrollbar()) {
                    var viewport_height = dc.getHeight();
                    if ($.isRoundDisplay) {
                        var margin = self.getMargin(dc);
                        viewport_height -= 2 * margin[1];
                    }
                    self._scrollbar.draw(dc, self._scrollOffset, self._viewHeight, viewport_height);
                }
            }
        }

        function addItem(title as String or Array<String>, substring as String or Array<String> or Null, identifier as Object?, icon as Number or BitmapResource or Null, position as Number) as Listitems.Item {
            var item = new Listitems.Item(self._mainLayer, title, substring, identifier, icon, null, position, null);
            self.Items.add(item);
            self._needValidation = true;
            return item;
        }

        function setTitle(title as String?) as Void {
            if (title != null && title.length() > 0) {
                var items = [];
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
                self.setCenterItemSelected();
            }

            if (startoffset != self._scrollOffset) {
                WatchUi.requestUpdate();
            }
        }

        function onDoubleTap(x as Number, y as Number) as Boolean {
            for (var i = 0; i < self.Items.size(); i++) {
                var item = self.Items[i];
                if (item.Clicked(y, self._scrollOffset)) {
                    return self.interactItem(item, true);
                }
            }
            return false;
        }

        function onTap(x as Number, y as Number) as Boolean {
            for (var i = 0; i < self.Items.size(); i++) {
                var item = self.Items[i];
                if (item.Clicked(y, self._scrollOffset)) {
                    return self.interactItem(item, false);
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
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        }

        protected function moveIterator(delta as Number?) as Void {
            if (delta == null) {
                self.setIterator(null);
            } else {
                self.setIterator(self._snapPosition + delta);
            }
        }

        protected function setIterator(pos as Number?) as Void {
            if (self.ScrollMode == SCROLL_SNAP) {
                if (pos == null) {
                    pos = 0;
                } else if (pos >= self.Items.size()) {
                    pos = self.Items.size() - 1;
                }
                if (pos < 0) {
                    pos = 0;
                }

                if (self.Items.size() > 0) {
                    while (self.Items.size() > pos && self.Items[pos] instanceof Listitems.Title) {
                        pos++;
                    }
                }
                self._snapPosition = pos;
                self.centerItem(self._snapPosition);
            }
        }

        private function getHeight() {
            if (self._viewHeight != null) {
                return self._viewHeight;
            } else {
                return 0;
            }
        }

        private function centerItem(item as Number or Listitems.Item) {
            if (item instanceof Number) {
                if (item >= 0 && self.Items.size() > item) {
                    item = self.Items[item];
                } else {
                    item = null;
                }
            }

            if (item == null) {
                return;
            }

            var y = item.getListY(); //upper edge of the item
            var h = item.getHeight(null); // height of the item
            var c = y + h / 2; // center point of the item

            self._scrollOffset = c - self._mainLayer.getHeight() / 2;
            if (self._scrollOffset < 0) {
                self._scrollOffset = 0;
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
                var radius = dc.getWidth() / 2;
                var marginX = (radius - radius * Math.sin(Math.toRadians(55))).toNumber();
                var marginY = (radius - radius * Math.cos(Math.toRadians(55))).toNumber();
                return [marginX, marginY];
            } else {
                return [(dc.getWidth() / 20).toNumber(), 0];
            }
        }

        /**
         * calculate the total height of the list and if a scrollbar is needed
         * and set the relative y-coordinates for all items
         */
        protected function validate(dc as Dc) as Void {
            if (self._needValidation == true) {
                if (self.DisplayButtonSupport() || $.isRoundDisplay) {
                    if (self.Items.size() > 0) {
                        if (self.Items[0] instanceof Listitems.Title) {
                            self._paddingTop = self._mainLayer.getHeight() / 2 - self.Items[0].getHeight(dc);
                            if (self.Items.size() > 1) {
                                self._paddingTop -= (self.Items[1].getHeight(dc) / 2).toNumber();
                            }
                        } else {
                            self._paddingTop = self._mainLayer.getHeight() / 2 - (self.Items[0].getHeight(dc) / 2).toNumber();
                        }
                        if (self._paddingTop < 0) {
                            self._paddingTop = 0;
                        }
                    } else {
                        self._paddingTop = 0;
                    }
                } else {
                    self._paddingTop = 0;
                }

                var y = self._paddingTop;
                for (var i = 0; i < self.Items.size(); i++) {
                    var item = self.Items[i];
                    //item.setLayer(self._mainLayer);
                    item.setListY(y);
                    item.Invalidate();
                    y += item.getHeight(dc);
                }

                if (self.DisplayButtonSupport() || $.isRoundDisplay) {
                    if (self.Items.size() > 0) {
                        self._paddingBottom = self._mainLayer.getHeight() / 2 - (self.Items[self.Items.size() - 1].getHeight(dc) / 2).toNumber();
                        if (self._paddingBottom < 0) {
                            self._paddingBottom = 0;
                        }
                    } else {
                        self._paddingBottom = 0;
                    }
                } else {
                    self._paddingBottom = 0;
                }
                self._viewHeight = y + self._paddingBottom;
                self._needScrollbar = self._mainLayer.getHeight() < self._viewHeight;
                self._needValidation = false;
                self.setCenterItemSelected();
            }
        }

        protected function addSettingsButton() as Void {
            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StTitle), SETTINGS, ($.screenHeight * 0.1).toNumber(), false));
        }

        protected function addBackButton(quit as Boolean) as Void {
            var rez = quit ? Rez.Strings.Quit : Rez.Strings.Back;
            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(rez), quit ? QUIT : BACK, ($.screenHeight * 0.1).toNumber(), false));
        }

        protected function interactItem(item as Listitems.Item, doubletap as Boolean) as Boolean {
            if (item.BoundObject instanceof Lang.Number) {
                if (item.BoundObject == BACK) {
                    self.goBack();
                    return true;
                } else if (item.BoundObject == QUIT) {
                    System.exit();
                }
            }
            return false;
        }

        protected function setCenterItemSelected() as Void {
            var centerY = $.screenHeight / 2;
            for (var i = 0; i < self.Items.size(); i++) {
                if (self.Items[i].Clicked(centerY, self._scrollOffset)) {
                    self._selectedItem = self.Items[i];
                    return;
                }
            }
            self._selectedItem = null;
        }

        static function SupportedControls() as EControls {
            if (self._controls == null) {
                var settings = System.getDeviceSettings();
                if (settings.isTouchScreen) {
                    if ((settings.inputButtons & System.BUTTON_INPUT_UP) != 0 && (settings.inputButtons & System.BUTTON_INPUT_DOWN) != 0) {
                        self._controls = CONTROLS_BOTH;
                    } else {
                        self._controls = CONTROLS_TOUCHSCREEN;
                    }
                } else {
                    self._controls = CONTROLS_BUTTONS;
                }
            }
            return self._controls;
        }

        static function DisplayButtonSupport() as Boolean {
            if (self._buttonDisplay == null) {
                var inputButtons = System.getDeviceSettings().inputButtons;
                if ((inputButtons & System.BUTTON_INPUT_MENU) == 0 && (inputButtons & System.BUTTON_INPUT_ESC) == 0) {
                    //only 1 button
                    self._buttonDisplay = true;
                } else {
                    var controls = self.SupportedControls();
                    if (controls == CONTROLS_TOUCHSCREEN) {
                        self._buttonDisplay = false;
                    } else if (controls == CONTROLS_BUTTONS) {
                        self._buttonDisplay = true;
                    } else {
                        self._buttonDisplay = Helper.Properties.Get(Helper.Properties.HWBCTRL, false);
                    }
                }
            }
            return self._buttonDisplay;
        }
    }
}
