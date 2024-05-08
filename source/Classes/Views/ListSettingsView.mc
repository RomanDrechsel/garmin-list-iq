import Toybox.Graphics;
import Toybox.Lang;
import Lists;
import Controls;
import Helper;

module Views {
    class ListSettingsView extends Controls.CustomView {
        var ListUuid = null;
        var ScrollMode = SCROLL_DRAG;

        private var _itemIconUncheck = Application.loadResource(Rez.Drawables.Item);
        private var _itemIconCheck = Application.loadResource(Rez.Drawables.ItemDone);

        private var _settingsMoveDown = false;

        private enum {
            SETTINGS_MOVEDOWN,
            SETTINGS_DELETE,
        }

        function initialize(uuid as String) {
            CustomView.initialize();
            self.ListUuid = uuid;
        }

        function onLayout(dc as Dc) as Void {
            CustomView.onLayout(dc);
            self._verticalPadding = dc.getHeight() / 10;

            var settings_movedown = Application.Properties.getValue("ListMoveDown") as Number;
            if (settings_movedown != null && settings_movedown == 1) {
                self._settingsMoveDown = true;
            } else {
                self._settingsMoveDown = false;
            }

            self.setTitle(Application.loadResource(Rez.Strings.StTitle));
            self.addItem(Application.loadResource(Rez.Strings.StMoveBottom), null, SETTINGS_MOVEDOWN, self._settingsMoveDown ? self._itemIconCheck : self._itemIconUncheck, -1);
            self.Items.add(new ButtonViewItem(self._mainLayer, Application.loadResource(Rez.Strings.StDelList), SETTINGS_DELETE, self._verticalPadding));
        }

        function onUpdate(dc as Dc) as Void {
            CustomView.onUpdate(dc);

            dc.setColor(getTheme().BackgroundColor, getTheme().BackgroundColor);
            dc.clear();
            self.drawList(dc);
        }

        function onListTap(position as Number, item as ViewItem?) as Void {
            if (item != null) {
                if (item.BoundObject == SETTINGS_MOVEDOWN) {
                    if (self._settingsMoveDown) {
                        item.setIcon(self._itemIconUncheck);
                    } else {
                        item.setIcon(self._itemIconCheck);
                    }
                    self._settingsMoveDown = !self._settingsMoveDown;
                    Application.Properties.setValue("ListMoveDown", self._settingsMoveDown ? 1 : 2);
                    WatchUi.requestUpdate();
                } else if (item.BoundObject == SETTINGS_DELETE) {
                    var dialog = new WatchUi.Confirmation(Application.loadResource(Rez.Strings.DeleteConfirm));
                    var delegate = new ConfirmDelegate(self.method(:deleteList));
                    WatchUi.pushView(dialog, delegate, WatchUi.SLIDE_BLINK);
                }
            }
        }

        function deleteList() {
            getApp().ListsManager.deleteList(self.ListUuid);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }
}
