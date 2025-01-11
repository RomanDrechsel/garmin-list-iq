import Toybox.Graphics;
import Toybox.Lang;
import Lists;
import Controls;
import Controls.Listitems;

module Views {
    class SettingsView extends Controls.CustomView {
        private var _itemIcon as Listitems.ViewItemIcon;
        private var _itemIconDone as Listitems.ViewItemIcon;

        private enum {
            SETTINGS_DELETEALL,
            SETTINGS_THEME,
            SETTINGS_LOGS,
            SETTINGS_PERSISTANTLOGS,
            SETTINGS_SENDLOGS,
            SETTINGS_APPSTORE,
            SETTINGS_MOVEDOWN,
            SETTINGS_DOUBLETAP,
            SETTINGS_SHOWNOTES,
            SETTINGS_AUTOEXIT,
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

        function onShow() as Void {
            self.loadVisuals();
        }

        function onUpdate(dc as Dc) as Void {
            CustomView.onUpdate(dc);
        }

        function onListTap(position as Number, item as Item, doubletap as Boolean) as Void {
            if (item.BoundObject == SETTINGS_DELETEALL) {
                var dialog = new WatchUi.Confirmation(Application.loadResource(Rez.Strings.StDelAllConfirm));
                var delegate = new ConfirmDelegate(self.method(:deleteAllLists));
                WatchUi.pushView(dialog, delegate, WatchUi.SLIDE_BLINK);
            } else if (item.BoundObject == SETTINGS_LOGS) {
                if (item.getIcon() == self._itemIcon) {
                    Helper.Properties.Store(Helper.Properties.LOGS, true);
                    item.setIcon(self._itemIconDone);
                } else {
                    Helper.Properties.Store(Helper.Properties.LOGS, false);
                    item.setIcon(self._itemIcon);
                }
                WatchUi.requestUpdate();
            } else if ([SETTINGS_MOVEDOWN, SETTINGS_DOUBLETAP, SETTINGS_SHOWNOTES].indexOf(item.BoundObject) >= 0) {
                var val = item.getIcon() == self._itemIcon;
                var prop;
                switch (item.BoundObject) {
                    case SETTINGS_MOVEDOWN:
                        prop = Helper.Properties.LISTMOVEDOWN;
                        break;
                    case SETTINGS_DOUBLETAP:
                        prop = Helper.Properties.DOUBLETAPFORDONE;
                        break;
                    case SETTINGS_SHOWNOTES:
                        prop = Helper.Properties.SHOWNOTES;
                        break;
                    default:
                        prop = null;
                        break;
                }
                if (prop != null) {
                    Helper.Properties.Store(prop, val);
                    item.setIcon(val ? self._itemIconDone : self._itemIcon);
                    WatchUi.requestUpdate();
                    if ($.getApp().ListsManager != null) {
                        $.getApp().GlobalStates.put("movetop", true);
                    }
                }
            } else if (item.BoundObject == SETTINGS_PERSISTANTLOGS) {
                if (item.getIcon() == self._itemIcon) {
                    Helper.Properties.Store(Helper.Properties.PERSISTENTLOGS, true);
                    item.setIcon(self._itemIconDone);
                } else {
                    Helper.Properties.Store(Helper.Properties.PERSISTENTLOGS, false);
                    item.setIcon(self._itemIcon);
                }
                WatchUi.requestUpdate();
            } else if (item.BoundObject == SETTINGS_SENDLOGS) {
                var prop = Helper.Properties.Get(Helper.Properties.LOGS, true);
                if (prop == true) {
                    if ($.getApp().Debug != null) {
                        $.getApp().Debug.SendLogs();
                    }
                    Helper.ToastUtil.Toast(Rez.Strings.StSendLogsOk, Helper.ToastUtil.SUCCESS);
                } else {
                    Helper.ToastUtil.Toast(Rez.Strings.StSendLogsOff, Helper.ToastUtil.ERROR);
                }
            } else if (item.BoundObject == SETTINGS_AUTOEXIT) {
                var view = new SettingsAutoexitView();
                var delegate = new SettingsAutoexitViewDelegate(view);
                WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
            } else if (item.BoundObject == SETTINGS_THEME) {
                var view = new SettingsThemeView();
                WatchUi.pushView(view, new SettingsThemeViewDelegate(view), WatchUi.SLIDE_LEFT);
            } else if (item.BoundObject == SETTINGS_APPSTORE) {
                Communications.openWebPage(getAppStore(), null, null);
                WatchUi.popView(WatchUi.SLIDE_RIGHT);
            }
        }

        function deleteAllLists() as Void {
            if ($.getApp().ListsManager != null) {
                $.getApp().ListsManager.clearAll();
            }
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        }

        function onSettingsChanged() as Void {
            CustomView.onSettingsChanged();
            self.loadVisuals();
        }

        private function loadVisuals() as Void {
            self.Items = [];

            self.setTitle(Application.loadResource(Rez.Strings.StTitle));

            // Delete all lists
            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StDelAll), SETTINGS_DELETEALL, self._verticalItemMargin, true));

            var icon;
            //move items down when done
            var prop = Helper.Properties.Get(Helper.Properties.LISTMOVEDOWN, true);
            if (prop == true || prop == 1) {
                icon = self._itemIconDone;
            } else {
                icon = self._itemIcon;
            }
            var movedown = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.StMoveBottom), null, SETTINGS_MOVEDOWN, icon, self._verticalItemMargin, 0, null);
            self.Items.add(movedown);

            //Double tap for set items done
            prop = Helper.Properties.Get(Helper.Properties.DOUBLETAPFORDONE, false);
            if (prop == true || prop == 1) {
                icon = self._itemIconDone;
            } else {
                icon = self._itemIcon;
            }
            var doubletap = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.StDoubleTapForDone), null, SETTINGS_DOUBLETAP, icon, self._verticalItemMargin, 0, null);
            self.Items.add(doubletap);

            //Show notes for items
            prop = Helper.Properties.Get(Helper.Properties.SHOWNOTES, true);
            if (prop == true || prop == 1) {
                icon = self._itemIconDone;
            } else {
                icon = self._itemIcon;
            }
            var shownotes = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.StShowNotes), null, SETTINGS_SHOWNOTES, icon, self._verticalItemMargin, 0, null);
            self.Items.add(shownotes);

            //auto exit
            prop = Helper.Properties.Get(Helper.Properties.AUTOEXIT, 0);
            var txt = "";
            switch (prop) {
                case 0:
                    txt = Application.loadResource(Rez.Strings.StAutoExitOff);
                    break;
                case 1:
                    txt = Application.loadResource(Rez.Strings.StAutoExit1);
                    break;
                case 3:
                    txt = Application.loadResource(Rez.Strings.StAutoExit3);
                    break;
                case 5:
                    txt = Application.loadResource(Rez.Strings.StAutoExit5);
                    break;
                case 10:
                    txt = Application.loadResource(Rez.Strings.StAutoExit10);
                    break;
                case 15:
                    txt = Application.loadResource(Rez.Strings.StAutoExit15);
                    break;
                case 30:
                    txt = Application.loadResource(Rez.Strings.StAutoExit30);
                    break;
                case 60:
                    txt = Application.loadResource(Rez.Strings.StAutoExit60);
                    break;
            }
            var autoexit = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.StAutoExit), txt, SETTINGS_AUTOEXIT, null, self._verticalItemMargin, 0, null);
            autoexit.TitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
            autoexit.SubtitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
            self.Items.add(autoexit);

            // Change Theme
            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StTheme), SETTINGS_THEME, self._verticalItemMargin, true));

            //store logs
            prop = Helper.Properties.Get(Helper.Properties.LOGS, true);
            self.addItem(Application.loadResource(Rez.Strings.StLogs), null, SETTINGS_LOGS, prop ? self._itemIconDone : self._itemIcon, 2);

            //store logs persistent
            prop = Helper.Properties.Get(Helper.Properties.PERSISTENTLOGS, true);
            var persistent = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.StPersistentLogs1), Application.loadResource(Rez.Strings.StPersistentLogs2), SETTINGS_PERSISTANTLOGS, prop ? self._itemIconDone : self._itemIcon, self._verticalItemMargin, 3, null);
            persistent.DrawLine = true;
            persistent.SubtitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
            self.Items.add(persistent);

            //send logs to phone
            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StSendLogs), SETTINGS_SENDLOGS, self._verticalItemMargin, true));

            // open appstore
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
