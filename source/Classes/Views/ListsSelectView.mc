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
        private const _listIconCode = 48;
        private var _firstDisplay = true;

        function initialize(first_display as Boolean) {
            ItemView.initialize();
            self.ScrollMode = SCROLL_DRAG;
            self._firstDisplay = first_display;
        }

        function onShow() as Void {
            ItemView.onShow();
            if ($.getApp().ListsManager != null) {
                $.getApp().ListsManager.addListIndexChangedListener(self);
            }
            self.publishLists($.getApp().ListsManager.GetListsIndex(), false);
            Helper.Properties.Store(Helper.Properties.LASTLIST, "");
        }

        function onHide() as Void {
            ItemView.onHide();
            self.Items = [];
            if ($.getApp().ListsManager != null) {
                $.getApp().ListsManager.removeListIndexChangedListener(self);
            }
        }

        function onDoubleTap(x as Number, y as Number) as Boolean {
            if (!ItemView.onDoubleTap(x, y)) {
                if (self.Items.size() > 0) {
                    var item = self.Items[0];
                    if (item.BoundObject instanceof String && item.BoundObject.equals("store") && Helper.Properties.Get(Helper.Properties.INIT, 0) < 0) {
                        $.openGooglePlay();
                        return true;
                    }
                }
            }
            return false;
        }

        function onKeyMenu() as Boolean {
            if (!ItemView.onKeyMenu()) {
                self.openSettings();
            }
            return true;
        }

        function onKeyEsc() as Boolean {
            if (!ItemView.onKeyEsc()) {
                System.exit();
            }
            return true;
        }

        function onListIndexChanged(index as Array<Lists.ListIndexItem>?) as Void {
            self.publishLists(index, true);
        }

        function onSettingsChanged() as Void {
            ItemView.onSettingsChanged();
            if ($.getApp().ListsManager != null) {
                self.publishLists($.getApp().ListsManager.GetListsIndex(), true);
            }
        }

        private function publishLists(index as Lists.ListIndex?, request_update as Boolean) as Void {
            if (self._firstDisplay && index != null) {
                self._firstDisplay = false;
                var startuplist = Helper.Properties.Get(Helper.Properties.LASTLIST, null);
                if (startuplist != null) {
                    var keys = index.keys();
                    for (var i = 0; i < keys.size(); i++) {
                        if ((keys[i] instanceof Number && keys[i] == startuplist) || (keys[i] instanceof String && keys[i].equals(startuplist))) {
                            var startscroll = Helper.Properties.Get(Helper.Properties.LASTLISTSCROLL, -1);
                            Helper.Properties.Store(Helper.Properties.LASTLIST, "");
                            self.GotoList(startuplist, startscroll);
                            return;
                        }
                    }
                }
            }

            self._firstDisplay = false;
            Helper.Properties.Store(Helper.Properties.LASTLISTSCROLL, -1);

            self._scrollOffset = 0;
            self._snapPosition = 0;

            if (index == null || index.size() == 0) {
                self.noLists();
                return;
            }

            var lists = index.values() as Array<ListIndexItem>;
            lists = Helper.MergeSort.Sort(lists, "o");
            index = null;

            self.Items = [] as Array<Item>;
            while (lists.size() > 0) {
                var item = lists[0];
                lists = lists.slice(1, null);
                var uuid = item.get(Lists.List.UUID);
                var items = item.get(Lists.List.ITEMS);
                var date = item.get(Lists.List.DATE);
                var title = item.get(Lists.List.TITLE);
                var substring = "";
                if (items != null) {
                    substring = Helper.StringUtil.stringReplace(Application.loadResource(Rez.Strings.LMSub), "%s", items.toString());
                }
                if (date != null) {
                    if (substring.length() > 0) {
                        substring += "\n";
                    }
                    substring += Helper.DateUtil.DatetoString(date, null);
                }
                self.addItem(title, substring, uuid, self._listIconCode, item.get("o"));
            }

            //no line below the last item
            if (self.Items.size() > 0) {
                self.Items[self.Items.size() - 1].DrawLine = false;
                self.setIterator(self._snapPosition);
            }

            if (self.DisplayButtonSupport()) {
                self.addSettingsButton();
            }

            if ($.getApp().NoBackButton) {
                self.addBackButton(true);
            }

            if (request_update) {
                WatchUi.requestUpdate();
            }
        }

        private function noLists() as Void {
            self.Items = [] as Array<Item>;
            var item = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.NoLists), null, "store", null, ($.screenHeight * 0.1).toNumber(), 0, null);
            item.DrawLine = false;
            item.TitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
            item.isSelectable = false;
            self.Items.add(item);

            var init = Helper.Properties.Get(Helper.Properties.INIT, 0);
            if (init < 1) {
                var txtRez;
                if (System.getDeviceSettings().isTouchScreen) {
                    txtRez = Rez.Strings.NoListsLink;
                } else {
                    txtRez = Rez.Strings.NoListsLinkBtn;
                }
                item = new Listitems.Item(self._mainLayer, null, Application.loadResource(txtRez), "store", null, null, 0, null);
                item.setSubFont(Helper.Fonts.Normal());
                item.DrawLine = false;
                item.isSelectable = false;
                item.SubtitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
                self.Items.add(item);
            }
            if (self.DisplayButtonSupport()) {
                self.addSettingsButton();
            }

            if ($.getApp().NoBackButton) {
                self.addBackButton(true);
            }

            self._scrollOffset = 0;
            self.moveIterator(0);
            self._needValidation = true;
        }

        protected function interactItem(item as Listitems.Item, doubletap as Boolean) as Boolean {
            if (!ItemView.interactItem(item, doubletap)) {
                if (item.BoundObject instanceof String) {
                    if (item.BoundObject.equals("settings")) {
                        self.openSettings();
                        return true;
                    } else if (item.BoundObject.equals("store")) {
                        if (doubletap && Helper.Properties.Get(Helper.Properties.INIT, 0) <= 0) {
                            $.openGooglePlay();
                            return true;
                        }
                    } else {
                        self.GotoList(item.BoundObject as String, -1);
                        return true;
                    }
                } else if (item.BoundObject instanceof Number) {
                    self.GotoList(item.BoundObject as Number, -1);
                    return true;
                }
            }
            return false;
        }

        private function GotoList(uuid as String or Number, scroll as Number) as Void {
            var view = new ListDetailsView(uuid, scroll > 0 ? scroll : null);
            WatchUi.pushView(view, new ItemViewDelegate(view), WatchUi.SLIDE_LEFT);
        }

        private function openSettings() as Void {
            var settings = new SettingsView();
            WatchUi.pushView(settings, new ItemViewDelegate(settings), WatchUi.SLIDE_LEFT);
        }
    }
}
