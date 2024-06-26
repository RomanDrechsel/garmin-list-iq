import Toybox.Graphics;
import Toybox.Lang;
import Lists;
import Controls;
import Controls.Listitems;
import Helper;

module Views {
    class SettingsView extends Controls.CustomView {
        private enum {
            SETTINGS_DELETEALL,
            SETTINGS_APPSTORE,
        }

        function initialize() {
            CustomView.initialize();
        }

        function onLayout(dc as Dc) as Void {
            CustomView.onLayout(dc);

            self.setTitle(Application.loadResource(Rez.Strings.StTitle));
            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StDelAll), SETTINGS_DELETEALL, self._verticalItemMargin, true));
            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StAppStore), SETTINGS_APPSTORE, self._verticalItemMargin, true));

            var str = Application.loadResource(Rez.Strings.StAppVersion);
            var version = Application.Properties.getValue("appVersion");
            var item = new Listitems.Item(self._mainLayer, str, version, null, null, self._verticalItemMargin, -1, null);
            item.DrawLine = false;
            item.TitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
            item.SubtitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
            self.Items.add(item);
        }

        function onUpdate(dc as Dc) as Void {
            CustomView.onUpdate(dc);

            dc.setColor(getTheme().BackgroundColor, getTheme().BackgroundColor);
            dc.clear();
            self.drawList(dc);
        }

        function onListTap(position as Number, item as Item?) as Void {
            if (item != null) {
                if (item.BoundObject == SETTINGS_DELETEALL) {
                    var dialog = new WatchUi.Confirmation(Application.loadResource(Rez.Strings.StDelAllConfirm));
                    var delegate = new ConfirmDelegate(self.method(:deleteAllLists));
                    WatchUi.pushView(dialog, delegate, WatchUi.SLIDE_BLINK);
                } else if (item.BoundObject == SETTINGS_APPSTORE) {
                    Communications.openWebPage(getAppStore(), null, null);
                    WatchUi.popView(WatchUi.SLIDE_RIGHT);
                }
            }
        }

        function deleteAllLists() {
            getApp().ListsManager.clearAll();
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        }
    }
}
