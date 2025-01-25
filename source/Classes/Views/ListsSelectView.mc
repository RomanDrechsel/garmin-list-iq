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
                $.getApp().ListsManager.OnListsChanged.add(self);
                self.publishLists($.getApp().ListsManager.GetLists(), false);
            }
        }

        function onHide() as Void {
            ItemView.onHide();
            if ($.getApp().ListsManager != null) {
                $.getApp().ListsManager.OnListsChanged.remove(self);
            }
        }

        function onDoubleTap(x as Number, y as Number) as Void {
            ItemView.onDoubleTap(x, y);
            if (self.Items.size() > 0) {
                var item = self.Items[0];
                if (item.BoundObject instanceof String && item.BoundObject.equals("store") && Helper.Properties.Get(Helper.Properties.INIT, 0) < 0) {
                    $.getApp().openGooglePlay();
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
            self.publishLists(index, true);
        }

        function onSettingsChanged() as Void {
            ItemView.onSettingsChanged();
            if ($.getApp().ListsManager != null) {
                self.publishLists($.getApp().ListsManager.GetLists(), true);
            }
        }

        private function publishLists(index as ListIndex?, initialize as Boolean) as Void {
            if (self._firstDisplay) {
                self._firstDisplay = false;
                var startuplist = Helper.Properties.Get(Helper.Properties.LASTLIST, "");
                if (startuplist.length() > 0) {
                    var startscroll = Helper.Properties.Get(Helper.Properties.LASTLISTSCROLL, -1);
                    Helper.Properties.Store(Helper.Properties.LASTLIST, "");
                    if (index.hasKey(startuplist)) {
                        self.GotoList(startuplist, startscroll);
                        return;
                    }
                }
            }

            self._firstDisplay = false;
            Helper.Properties.Store(Helper.Properties.LASTLIST, "");
            Helper.Properties.Store(Helper.Properties.LASTLISTSCROLL, -1);

            if (index == null || index.size() == 0) {
                self.noLists();
                return;
            }

            var lists = index.values() as Array<ListIndexItem>;
            lists = Helper.MergeSort.Sort(lists, "order");

            self.Items = [] as Array<Item>;
            for (var i = 0; i < lists.size(); i++) {
                var list = lists[i] as ListIndexItem;
                var substring = "";
                var items = list.get("items") as Number;
                if (items != null) {
                    substring = Application.loadResource(Rez.Strings.LMSub) as String;
                    substring = Helper.StringUtil.stringReplace(substring, "%s", items.toString());
                }
                var date = list.get("date");
                if (date != null) {
                    if (substring.length() > 0) {
                        substring += "\n";
                    }
                    substring += Helper.DateUtil.DatetoString(date, null);
                }
                self.addItem(list.get("name") as String, substring, list.get("key") as String, self._listIconCode, i);
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

            if (initialize) {
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

            self.moveIterator(0);
            self._needValidation = true;
        }

        protected function interactItem(item as Listitems.Item, doubletap as Boolean) as Void {
            if (!ItemView.interactItem(item, doubletap)) {
                if (item.BoundObject instanceof String) {
                    if (item.BoundObject.equals("settings")) {
                        self.openSettings();
                    } else if (item.BoundObject.equals("store")) {
                        $.getApp().openGooglePlay();
                    } else {
                        self.GotoList(item.BoundObject, -1);
                    }
                }
            }
        }

        private function GotoList(uuid as String, scroll as Number) as Void {
            var view = new ListDetailsView(uuid, scroll > 0 ? scroll : null);
            WatchUi.pushView(view, new ItemViewDelegate(view), WatchUi.SLIDE_LEFT);
        }

        private function openSettings() as Void {
            var settings = new SettingsView();
            WatchUi.pushView(settings, new ItemViewDelegate(settings), WatchUi.SLIDE_LEFT);
        }
    }
}
