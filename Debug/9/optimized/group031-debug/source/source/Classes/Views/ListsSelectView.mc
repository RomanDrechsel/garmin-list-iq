using Rez;
using Toybox.Application;
using Toybox.System;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Time;
import Lists;
import Controls;
import Controls.Listitems;
import Helper;

module Views {
    class ListsSelectView extends ItemView {
        private var _firstDisplay = true;
        private var _numLists as Number? = null;

        function initialize(first_display as Boolean) {
            ItemView.initialize();
            self.ScrollMode = 1;
            self._firstDisplay = first_display;
        }

        function onLayout(dc as Dc) as Void {
            ItemView.onLayout(dc);
            if ($.getApp().ListsManager != null) {
                $.getApp().ListsManager.addListChangedListener(self);
                self.publishLists($.getApp().ListsManager.GetLists());
            }
        }

        function onShow() as Void {
            ItemView.onShow();
            if (self.Items.size() == 0) {
                self.publishLists($.getApp().ListsManager.GetLists());
            }
            Helper.Properties.Store("LastList", "");
        }

        function onDoubleTap(x as Number, y as Number) as Boolean {
            if (!ItemView.onDoubleTap(x, y)) {
                y /*>pre_0<*/ = 0;
                if (self.Items.size() > y /*>pre_0<*/) {
                    x /*>item<*/ = self.Items[y /*>pre_0<*/];
                    if (x /*>item<*/.BoundObject instanceof String && x /*>item<*/.BoundObject.equals("store") && Helper.Properties.Get("Init", y /*>pre_0<*/) < y /*>pre_0<*/) {
                        ListsApp.openGooglePlay();
                    }
                }
            }
        }

        function onKeyMenu() as Void {
            ItemView.onKeyMenu();
            self.openSettings();
        }

        function onKeyEsc() as Void {
            ItemView.onKeyEsc();
            System.exit();
        }

        function onListsChanged(index as ListIndex) as Void {
            self.publishLists(index);
        }

        function onSettingsChanged() as Void {
            ItemView.onSettingsChanged();
            if ($.getApp().ListsManager != null) {
                self._numLists = null;
                self.publishLists($.getApp().ListsManager.GetLists());
            }
        }

        private function publishLists(index as ListIndex?) as Void {
            var startuplist, pre___, pre_0;
            pre_0 = 0;
            pre___ = "";
            if (self._firstDisplay) {
                self._firstDisplay = false;
                startuplist = Helper.Properties.Get("LastList", pre___);
                if (startuplist.length() > pre_0) {
                    if (index.hasKey(startuplist)) {
                        index /*>startscroll<*/ = Helper.Properties.Get("LastListScroll", -1);
                        Helper.Properties.Store("LastList", pre___);
                        self.GotoList(startuplist, index /*>startscroll<*/);
                        return;
                    }
                }
            }

            self._firstDisplay = false;
            Helper.Properties.Store("LastListScroll", -1);

            self._scrollOffset = pre_0;
            self._snapPosition = pre_0;

            if (index == null || index.size() == pre_0) {
                self.noLists();
                return;
            }

            var lists;
            lists = Helper.MergeSort.Sort(index.values() as Array<ListIndexItem>, "order");

            self.Items = [] as Array<Item>;
            {
                startuplist /*>i<*/ = pre_0;
                for (; startuplist /*>i<*/ < lists.size(); startuplist /*>i<*/ += 1) {
                    var list = lists[startuplist /*>i<*/] as ListIndexItem;
                    var substring = pre___;
                    index /*>items<*/ = list.get("items") as Number;
                    if (index /*>items<*/ != null) {
                        substring = Helper.StringUtil.stringReplace(Application.loadResource(Rez.Strings.LMSub) as String, "%s", index /*>items<*/.toString());
                    }
                    index /*>date<*/ = list.get("date");
                    if (index /*>date<*/ != null) {
                        if (substring.length() > pre_0) {
                            substring += "\n";
                        }
                        substring += Helper.DateUtil.DatetoString(index /*>date<*/, null);
                    }
                    self.addItem(list.get("name") as String, substring, list.get("key") as String, 48, startuplist /*>i<*/);
                }
            }

            //no line below the last item
            if (self.Items.size() > pre_0) {
                self.Items[self.Items.size() - 1].DrawLine = false;
                self.setIterator(pre_0);
            }

            if (self.DisplayButtonSupport()) {
                self.addSettingsButton();
            }

            if ($.getApp().NoBackButton) {
                self.addBackButton(true);
            }

            if (self._numLists == null || self._numLists != lists.size()) {
                self._numLists = lists.size();
                WatchUi.requestUpdate();
            }
        }

        private function noLists() as Void {
            var item, pre_0, pre_1;
            pre_1 = 1;
            pre_0 = 0;
            self.Items = [] as Array<Item>;
            item = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.NoLists), null, "store", null, ($.screenHeight * 0.1).toNumber(), pre_0, null);
            item.DrawLine = false;
            item.TitleJustification = pre_1 as Toybox.Graphics.TextJustification;
            item.isSelectable = false;
            self.Items.add(item);

            if (Helper.Properties.Get("Init", pre_0) < pre_1) {
                if (System.getDeviceSettings().isTouchScreen) {
                    item /*>txtRez<*/ = Rez.Strings.NoListsLink;
                } else {
                    item /*>txtRez<*/ = Rez.Strings.NoListsLinkBtn;
                }
                item = new Listitems.Item(self._mainLayer, null, Application.loadResource(item /*>txtRez<*/), "store", null, null, pre_0, null);
                item.setSubFont(Helper.Fonts.Normal());
                item.DrawLine = false;
                item.isSelectable = false;
                item.SubtitleJustification = pre_1 as Toybox.Graphics.TextJustification;
                self.Items.add(item);
            }
            if (self.DisplayButtonSupport()) {
                self.addSettingsButton();
            }

            if ($.getApp().NoBackButton) {
                self.addBackButton(true);
            }

            self._scrollOffset = pre_0;
            self.moveIterator(pre_0);
            self._needValidation = true;
        }

        protected function interactItem(item as Listitems.Item, doubletap as Boolean) as Void {
            if (!ItemView.interactItem(item, doubletap)) {
                if (item.BoundObject instanceof String) {
                    if (item.BoundObject.equals("settings")) {
                        self.openSettings();
                    } else if (item.BoundObject.equals("store")) {
                        if (doubletap && Helper.Properties.Get("Init", 0) <= 0) {
                            ListsApp.openGooglePlay();
                        }
                    } else {
                        self.GotoList(item.BoundObject, -1);
                    }
                }
            }
        }

        private function GotoList(uuid as String, scroll as Number) as Void {
            uuid /*>view<*/ = new ListDetailsView(uuid, scroll > 0 ? scroll : null);
            WatchUi.pushView(uuid /*>view<*/, new ItemViewDelegate(uuid /*>view<*/), 1 as Toybox.WatchUi.SlideType);
        }

        private function openSettings() as Void {
            var settings = new SettingsView();
            WatchUi.pushView(settings, new ItemViewDelegate(settings), 1 as Toybox.WatchUi.SlideType);
        }
    }
}
