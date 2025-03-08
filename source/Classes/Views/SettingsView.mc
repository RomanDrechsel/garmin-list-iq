import Toybox.Graphics;
import Toybox.Lang;
import Lists;
import Controls;
import Controls.Listitems;

module Views {
    class SettingsView extends IconItemView {
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
            SETTINGS_HWBCTRL,
            SETTINGS_TEST,
        }

        private var _lastScroll = 0;

        function initialize() {
            IconItemView.initialize();
            self.ScrollMode = SCROLL_DRAG;
        }

        function onLayout(dc as Dc) as Void {
            IconItemView.onLayout(dc);
            self.loadVisuals();
        }

        function onShow() as Void {
            IconItemView.onShow();
            self._scrollOffset = self._lastScroll;
        }

        function onSettingsChanged() as Void {
            IconItemView.onSettingsChanged();
            self._scrollOffset = self._lastScroll;
            self.loadVisuals();
        }

        function onScroll(delta as Number) as Void {
            IconItemView.onScroll(delta);
            self._lastScroll = self._scrollOffset;
        }

        function deleteAllLists() as Void {
            if ($.getApp().ListsManager != null) {
                $.getApp().ListsManager.clearAll();
            }
            self.goBack();
        }

        private function loadVisuals() as Void {
            self.Items = [];

            self.setTitle(Application.loadResource(Rez.Strings.StTitle));

            // Delete all lists
            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StDelAll), SETTINGS_DELETEALL, null, true));

            var icon;
            //move items down when done
            var prop = Helper.Properties.Get(Helper.Properties.LISTMOVEDOWN, true);
            if (prop == true || prop == 1) {
                icon = self._itemIconDone;
            } else {
                icon = self._itemIcon;
            }
            var movedown = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.StMoveBottom), null, SETTINGS_MOVEDOWN, icon, null, 0, null);
            self.Items.add(movedown);

            //Double tap for set items done
            prop = Helper.Properties.Get(Helper.Properties.DOUBLETAPFORDONE, false);
            if (prop == true || prop == 1) {
                icon = self._itemIconDone;
            } else {
                icon = self._itemIcon;
            }
            var doubletap = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.StDoubleTapForDone), null, SETTINGS_DOUBLETAP, icon, null, 0, null);
            self.Items.add(doubletap);

            //Show notes for items
            prop = Helper.Properties.Get(Helper.Properties.SHOWNOTES, true);
            if (prop == true || prop == 1) {
                icon = self._itemIconDone;
            } else {
                icon = self._itemIcon;
            }
            var shownotes = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.StShowNotes), null, SETTINGS_SHOWNOTES, icon, null, 0, null);
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
            var autoexit = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.StAutoExit), txt, SETTINGS_AUTOEXIT, null, null, 0, null);
            autoexit.TitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
            autoexit.SubtitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
            self.Items.add(autoexit);

            // Change Theme
            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StTheme), SETTINGS_THEME, null, true));

            // Hardware button controls
            if (ItemView.SupportedControls() == ItemView.CONTROLS_BOTH) {
                self.addItem(Application.loadResource(Rez.Strings.StBtnCtrl), null, SETTINGS_HWBCTRL, ItemView.DisplayButtonSupport() ? self._itemIconDone : self._itemIcon, 0);
            }

            //store logs
            prop = Helper.Properties.Get(Helper.Properties.LOGS, true);
            self.addItem(Application.loadResource(Rez.Strings.StLogs), null, SETTINGS_LOGS, prop ? self._itemIconDone : self._itemIcon, 0);

            //store logs persistent
            prop = Helper.Properties.Get(Helper.Properties.PERSISTENTLOGS, true);
            var persistent = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.StPersistentLogs1), Application.loadResource(Rez.Strings.StPersistentLogs2), SETTINGS_PERSISTANTLOGS, prop ? self._itemIconDone : self._itemIcon, null, 0, null);
            persistent.DrawLine = true;
            persistent.SubtitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
            self.Items.add(persistent);

            //send logs to phone
            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StSendLogs), SETTINGS_SENDLOGS, null, true));

            // open appstore
            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StAppStore), SETTINGS_APPSTORE, null, true));

            //app version
            var str = Application.loadResource(Rez.Strings.StAppVersion);
            var version = Application.Properties.getValue("appVersion");
            var item = new Listitems.Item(self._mainLayer, str, version, SETTINGS_TEST, null, null, -1, null);
            item.TitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
            item.SubtitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
            item.DrawLine = false;
            item.isSelectable = false;
            self.Items.add(item);

            if ($.getApp().NoBackButton) {
                self.addBackButton(false);
            }

            self._needValidation = true;
        }

        protected function interactItem(item as Listitems.Item, doubletap as Boolean) as Boolean {
            if (!IconItemView.interactItem(item, doubletap)) {
                if (item.BoundObject instanceof Number) {
                    if (item.BoundObject == SETTINGS_DELETEALL) {
                        var dialog = new WatchUi.Confirmation(Application.loadResource(Rez.Strings.StDelAllConfirm));
                        var delegate = new Controls.ConfirmDelegate(self.method(:deleteAllLists));
                        WatchUi.pushView(dialog, delegate, WatchUi.SLIDE_BLINK);
                        return true;
                    } else if ([SETTINGS_MOVEDOWN, SETTINGS_DOUBLETAP, SETTINGS_SHOWNOTES].indexOf(item.BoundObject) >= 0) {
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
                            var val = !Helper.Properties.Get(prop, false);
                            Helper.Properties.Store(prop, val);
                            item.setIcon(val ? self._itemIconDone : self._itemIcon);
                            item.setIconInvert(val ? self._itemIconDoneInvert : self._itemIconInvert);
                            WatchUi.requestUpdate();
                            if ($.getApp().ListsManager != null) {
                                $.getApp().GlobalStates.add(ListsApp.MOVETOP);
                            }
                            return true;
                        }
                    } else if (item.BoundObject == SETTINGS_HWBCTRL) {
                        var check = item.getIcon() == self._itemIcon;
                        Helper.Properties.Store(Helper.Properties.HWBCTRL, check);
                        item.setIcon(check ? self._itemIconDone : self._itemIcon);
                        $.getApp().triggerOnSettingsChanged();
                        return true;
                    } else if (item.BoundObject == SETTINGS_LOGS) {
                        var check = item.getIcon() == self._itemIcon;
                        Helper.Properties.Store(Helper.Properties.LOGS, check);
                        item.setIcon(check ? self._itemIconDone : self._itemIcon);
                        WatchUi.requestUpdate();
                        return true;
                    } else if (item.BoundObject == SETTINGS_PERSISTANTLOGS) {
                        var check = item.getIcon() == self._itemIcon;
                        Helper.Properties.Store(Helper.Properties.PERSISTENTLOGS, check);
                        item.setIcon(check ? self._itemIconDone : self._itemIcon);
                        WatchUi.requestUpdate();
                        return true;
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
                        return true;
                    } else if (item.BoundObject == SETTINGS_AUTOEXIT) {
                        var view = new SettingsAutoexitView();
                        WatchUi.pushView(view, new ItemViewDelegate(view), WatchUi.SLIDE_LEFT);
                        return true;
                    } else if (item.BoundObject == SETTINGS_THEME) {
                        var view = new SettingsThemeView();
                        WatchUi.pushView(view, new ItemViewDelegate(view), WatchUi.SLIDE_LEFT);
                        return true;
                    } else if (item.BoundObject == SETTINGS_APPSTORE) {
                        $.openGooglePlay();
                        return true;
                    }
                    return false;
                }
                return false;
            }

            return true;
        }
    }
}
