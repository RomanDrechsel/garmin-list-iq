import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Time;
import Lists;
import Controls;
import Controls.Listitems;
import Exceptions;

module Views {
    class ListsSelectView extends ItemView {
        private const _listIconCode = 48;
        private var _firstDisplay = true;
        private var _show_error_view = null as ErrorView.ECode?;

        private enum {
            STORE = 0,
        }

        function initialize(first_display as Boolean, show_errorview_on_start as ErrorView.ECode?) {
            ItemView.initialize();
            self.ScrollMode = SCROLL_DRAG;
            self._firstDisplay = first_display;
            self._show_error_view = show_errorview_on_start;
        }

        function onShow() as Void {
            ItemView.onShow();
            if (self._show_error_view != null) {
                Views.ErrorView.Show(self._show_error_view, null);
                self._show_error_view = null;
                return;
            }

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
                if (startuplist != null && index.hasKey(startuplist)) {
                    var startscroll = Helper.Properties.Get(Helper.Properties.LASTLISTSCROLL, -1);
                    Helper.Properties.Store(Helper.Properties.LASTLIST, "");
                    self.GotoList(startuplist, startscroll);
                    return;
                }
            }

            self._firstDisplay = false;
            Helper.Properties.Store(Helper.Properties.LASTLISTSCROLL, -1);

            self._scrollOffset = 0;
            self._snapPosition = 0;

            if (index == null || index.size() == 0) {
                self.noLists(request_update);
                return;
            }

            var lists = index.values() as Array<ListIndexItem>;
            lists = Helper.MergeSort.Sort(lists, Lists.List.ORDER);
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
                    if (items == 1) {
                        substring = Application.loadResource(Rez.Strings.LMSubOne);
                    } else {
                        substring = Helper.StringUtil.stringReplace(Application.loadResource(Rez.Strings.LMSub), "%s", items.toString());
                    }
                }
                if (date != null) {
                    if (substring.length() > 0) {
                        substring += "\n";
                    }
                    substring += Helper.DateUtil.DateToString(date, "\n");
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

        private function noLists(request_update as Boolean) as Void {
            self.Items = [] as Array<Item>;
            var item = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.NoLists), null, STORE, null, ($.screenHeight * 0.1).toNumber(), 0, null);
            item.DrawLine = false;
            item.TitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
            item.isSelectable = false;
            self.Items.add(item);

            if ($.getApp().GlobalStates.indexOf(ListsApp.LEGACYLIST) >= 0) {
                item = new Listitems.Item(self._mainLayer, null, Application.loadResource(Rez.Strings.ListLegacy), STORE, null, null, 1, null);
                item.setSubFont(Helper.Fonts.Normal());
                item.DrawLine = false;
                item.isSelectable = false;
                item.SubtitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
                self.Items.add(item);
            } else if (Helper.Properties.Get(Helper.Properties.INIT, 0) < 1) {
                var txtRez;
                if (System.getDeviceSettings().isTouchScreen) {
                    txtRez = Rez.Strings.NoListsLink;
                } else {
                    txtRez = Rez.Strings.NoListsLinkBtn;
                }
                item = new Listitems.Item(self._mainLayer, null, Application.loadResource(txtRez), STORE, null, null, 0, null);
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

            if (request_update) {
                WatchUi.requestUpdate();
            }
        }

        protected function interactItem(item as Listitems.Item, doubletap as Boolean) as Boolean {
            if (!ItemView.interactItem(item, doubletap)) {
                if (item.BoundObject instanceof Number) {
                    if (item.BoundObject == ItemView.SETTINGS) {
                        self.openSettings();
                        return true;
                    } else if (item.BoundObject == STORE) {
                        if (doubletap && Helper.Properties.Get(Helper.Properties.INIT, 0) <= 0) {
                            $.openGooglePlay();
                            return true;
                        }
                    } else {
                        self.GotoList(item.BoundObject as Number, -1);
                        return true;
                    }
                } else if (item.BoundObject instanceof String) {
                    self.GotoList(item.BoundObject as String, -1);
                    return true;
                }
                return false;
            }
            return true;
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
