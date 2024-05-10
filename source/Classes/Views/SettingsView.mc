import Toybox.Graphics;
import Toybox.Lang;
import Lists;
import Controls;
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

            self._verticalMargin = dc.getHeight() / 10;

            self.setTitle(Application.loadResource(Rez.Strings.StTitle));
            self.Items.add(new ButtonViewItem(self._mainLayer, Application.loadResource(Rez.Strings.StDelAll), SETTINGS_DELETEALL, self._verticalMargin));
            self.Items.add(new ButtonViewItem(self._mainLayer, Application.loadResource(Rez.Strings.StAppStore), SETTINGS_APPSTORE, self._verticalMargin));

            var str = Application.loadResource(Rez.Strings.StAppVersion);
            var version = Application.Properties.getValue("appVersion");
            str += "\n" + version;
            var item = new ViewItem(self._mainLayer, null, str, null, null, self._verticalMargin, -1, null);
            item.Subtitle.Justification = Graphics.TEXT_JUSTIFY_CENTER;
            self.Items.add(item);
        }

        function onUpdate(dc as Dc) as Void {
            CustomView.onUpdate(dc);

            dc.setColor(getTheme().BackgroundColor, getTheme().BackgroundColor);
            dc.clear();
            self.drawList(dc);
        }

        function onListTap(position as Number, item as ViewItem?) as Void {
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
