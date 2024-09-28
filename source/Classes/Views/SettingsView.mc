import Toybox.Graphics;
import Toybox.Lang;
import Lists;
import Controls;
import Controls.Listitems;

module Views {
    class SettingsView extends Controls.CustomView {
        protected var TAG = "SettingsView";

        private var _itemIcon as Listitems.ViewItemIcon;
        private var _itemIconDone as Listitems.ViewItemIcon;

        private enum {
            SETTINGS_DELETEALL,
            SETTINGS_THEME,
            SETTINGS_LOGS,
            SETTINGS_PERSISTANTLOGS,
            SETTINGS_APPSTORE,
        }

        function initialize() {
            CustomView.initialize();
            self._itemIcon = $.getTheme().DarkTheme ? Application.loadResource(Rez.Drawables.Item) : Application.loadResource(Rez.Drawables.bItem);
            self._itemIconDone = $.getTheme().DarkTheme ? Application.loadResource(Rez.Drawables.ItemDone) : Application.loadResource(Rez.Drawables.bItemDone);
        }

        function onLayout(dc as Dc) as Void {
            CustomView.onLayout(dc);
            self.loadVisuals();
        }

        function onUpdate(dc as Dc) as Void {
            CustomView.onUpdate(dc);

            dc.setColor(getTheme().BackgroundColor, getTheme().BackgroundColor);
            dc.clear();
            self.drawList(dc);
        }

        function onShow() as Void {
            self.loadVisuals();
        }

        function onListTap(position as Number, item as Item, doubletap as Boolean) as Void {
            if (item.BoundObject == SETTINGS_DELETEALL) {
                var dialog = new WatchUi.Confirmation(Application.loadResource(Rez.Strings.StDelAllConfirm));
                var delegate = new ConfirmDelegate(self.method(:deleteAllLists));
                WatchUi.pushView(dialog, delegate, WatchUi.SLIDE_BLINK);
            } else if (item.BoundObject == SETTINGS_APPSTORE) {
                Communications.openWebPage(getAppStore(), null, null);
                WatchUi.popView(WatchUi.SLIDE_RIGHT);
            } else if (item.BoundObject == SETTINGS_THEME) {
                var view = new SettingsThemeView();
                var delegate = new SettingsThemeViewDelegate(view);
                WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
            } else if (item.BoundObject == SETTINGS_LOGS) {
                if (item.getIcon() == self._itemIcon) {
                    Helper.Properties.Store(Helper.Properties.LOGS, true);
                    item.setIcon(self._itemIconDone);
                } else {
                    Helper.Properties.Store(Helper.Properties.LOGS, false);
                    item.setIcon(self._itemIcon);
                }
                WatchUi.requestUpdate();
            } else if (item.BoundObject == SETTINGS_PERSISTANTLOGS) {
                if (item.getIcon() == self._itemIcon) {
                    Helper.Properties.Store(Helper.Properties.PERSISTENTLOGS, true);
                    item.setIcon(self._itemIconDone);
                } else {
                    Helper.Properties.Store(Helper.Properties.PERSISTENTLOGS, false);
                    item.setIcon(self._itemIcon);
                }
                WatchUi.requestUpdate();
            }
        }

        function deleteAllLists() as Void {
            $.getApp().ListsManager.clearAll();
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        }

        function onSettingsChanged() as Void {
            self.loadVisuals();
        }

        private function loadVisuals() as Void {
            self.Items = [];

            self.setTitle(Application.loadResource(Rez.Strings.StTitle));
            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StDelAll), SETTINGS_DELETEALL, self._verticalItemMargin, true));
            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StTheme), SETTINGS_THEME, self._verticalItemMargin, true));

            var setting = Helper.Properties.Get(Helper.Properties.LOGS, false);
            self.addItem(Application.loadResource(Rez.Strings.StLogs), null, SETTINGS_LOGS, setting ? self._itemIconDone : self._itemIcon, 2);
            setting = Helper.Properties.Get(Helper.Properties.PERSISTENTLOGS, false);
            self.addItem(Application.loadResource(Rez.Strings.StPersistentLogs1), Application.loadResource(Rez.Strings.StPersistentLogs2), SETTINGS_PERSISTANTLOGS, setting ? self._itemIconDone : self._itemIcon, 3);

            self.Items[2].DrawLine = true;
            self.Items[4].DrawLine = true;

            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StAppStore), SETTINGS_APPSTORE, self._verticalItemMargin, true));

            var str = Application.loadResource(Rez.Strings.StAppVersion);
            var version = Application.Properties.getValue("appVersion");
            var item = new Listitems.Item(self._mainLayer, str, version, null, null, self._verticalItemMargin, -1, null);

            item.TitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
            item.SubtitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
            item.DrawLine = false;
            self.Items.add(item);
            self._needValidation = true;
        }
    }
}
