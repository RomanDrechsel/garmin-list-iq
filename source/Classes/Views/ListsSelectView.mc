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
        private var _firstDisplay = true;
        private var _show_error_view as ErrorView.ECode? = null;
        (:withBackground)
        private var _processingBgDataLabel as Controls.Label? = null;
        private var _showProcessBgDataPopup = false;

        private enum {
            STORE = 0,
        }

        function initialize(first_display as Boolean, show_errorview_on_start as ErrorView.ECode?) {
            ItemView.initialize();
            self.ScrollMode = SCROLL_DRAG;
            self._firstDisplay = first_display;
            self._show_error_view = show_errorview_on_start;
        }

        public function onShow() as Void {
            ItemView.onShow();
            if (self._show_error_view != null) {
                Views.ErrorView.Show(self._show_error_view, null);
                self._show_error_view = null;
                return;
            }

            self._showProcessBgDataPopup = $.getApp().ProcessingBackgroundData;

            var listsmanager = $.getApp().ListsManager;
            if (listsmanager != null) {
                listsmanager.addListIndexChangedListener(self);
            }

            self.publishLists(listsmanager.GetListsIndex(), false);
            Helper.Properties.Store(Helper.Properties.LASTLIST, "");
        }

        public function onHide() as Void {
            ItemView.onHide();
            self.Items = [];
            var listsmanager = $.getApp().ListsManager;
            if (listsmanager != null) {
                listsmanager.removeListIndexChangedListener(self);
            }
        }

        (:withBackground)
        public function onUpdate(dc as Dc) as Void {
            ItemView.onUpdate(dc);

            if (self._showProcessBgDataPopup) {
                self._showProcessBgDataPopup = $.getApp().ProcessingBackgroundData;
                if (self._showProcessBgDataPopup) {
                    self.drawProcessingBackgroundDataPopup(dc);
                } else {
                    self.hideProcessingBackgroundDataPopup();
                }
            }
        }

        public function onKeyMenu() as Boolean {
            if (!ItemView.onKeyMenu()) {
                self.openSettings();
            }
            return true;
        }

        public function onKeyEsc() as Boolean {
            if (!ItemView.onKeyEsc()) {
                System.exit();
            }
            return true;
        }

        public function onListIndexChanged(index as Array<Lists.ListIndexItem>?) as Void {
            self.publishLists(index, true);
        }

        public function onSettingsChanged() as Void {
            ItemView.onSettingsChanged();
            var listsmanager = $.getApp().ListsManager;
            if (listsmanager != null) {
                self.publishLists(listsmanager.GetListsIndex(), true);
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

                    var sep = System.getDeviceSettings().screenWidth > 380 ? " " : "\n";
                    substring += Helper.DateUtil.DateToString(date, sep);
                }
                self.addItem(title, substring, uuid, 48, item.get("o"));
            }

            //no line below the last item
            if (self.Items.size() > 0) {
                self.Items[self.Items.size() - 1].DrawLine = false;
                self.setIterator(self._snapPosition);
            }

            if (self.DisplayButtonSupport()) {
                self.addSettingsButton();
            }

            if (self._noHardwareBackButton) {
                self.addBackButton(true);
            }

            if (request_update) {
                WatchUi.requestUpdate();
            }
        }

        private function noLists(request_update as Boolean) as Void {
            self.Items = [];
            var item = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.NoLists), null, STORE, null, (System.getDeviceSettings().screenHeight * 0.1).toNumber(), 0, null);
            item.DrawLine = false;
            item.TitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
            item.isSelectable = false;
            self.Items.add(item);

            if ($.getApp().GlobalStates.indexOf(ListsApp.LEGACYLIST) >= 0) {
                item = new Listitems.Item(self._mainLayer, null, Application.loadResource(Rez.Strings.ListLegacy), STORE, null, null, 1, null);
                item.setSubFont(Common.Fonts.Normal());
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
                item.setSubFont(Common.Fonts.Normal());
                item.DrawLine = false;
                item.isSelectable = false;
                item.SubtitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
                self.Items.add(item);
            }

            if (self.DisplayButtonSupport()) {
                self.addSettingsButton();
            }

            if (self._noHardwareBackButton) {
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

        (:withBackground)
        private function drawProcessingBackgroundDataPopup(dc as Dc) as Void {
            var txt = Application.loadResource(Rez.Strings.ProcessBg);
            var padding = (dc.getWidth() / 10).toNumber();
            var width = dc.getWidth() - 2 * padding;
            if (self._processingBgDataLabel == null) {
                self._processingBgDataLabel = new Controls.Label(txt, Common.Fonts.Normal(), width);
            }

            var height = self._processingBgDataLabel.getHeight(dc) + padding * 2;
            var y = dc.getHeight() / 2 - height / 2;
            dc.setColor(Themes.CurrentTheme.BackgroundColor, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(0, y, dc.getWidth(), height);
            dc.setColor(Themes.CurrentTheme.TitleSeparatorColor, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(1);
            dc.drawLine(0, y, dc.getWidth(), y);
            dc.drawLine(0, y + height, dc.getWidth(), y + height);
            self._processingBgDataLabel.draw(dc, padding, y + padding, Themes.CurrentTheme.MainColor, Graphics.TEXT_JUSTIFY_CENTER);
        }

        (:withoutBackground)
        private function drawProcessingBackgroundDataPopup(dc as Dc) as Void {}

        (:withBackground)
        private function hideProcessingBackgroundDataPopup() as Void {
            self._processingBgDataLabel = null;
            self._showProcessBgDataPopup = false;
        }

        (:withoutBackground)
        private function hideProcessingBackgroundDataPopup() as Void {}
    }
}
