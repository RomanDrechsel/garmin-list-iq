using Toybox.WatchUi;
using Toybox.Application.Properties;
using Helper;
using Rez;
using Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Lists;
import Controls;
import Controls.Listitems;

module Views {
    class SettingsView extends IconItemView {
        private var _lastScroll = 0;

        function initialize() {
            IconItemView.initialize();
            self.ScrollMode = 1;
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
            var version, persistent, pre_1;
            pre_1 = 1;
            version /*>pre_0<*/ = 0;
            self.Items = [];

            self.setTitle(Application.loadResource(Rez.Strings.StTitle));

            // Delete all lists
            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StDelAll), version /*>pre_0<*/, null, true));

            //move items down when done
            persistent /*>prop<*/ = Helper.Properties.Get("ListMoveDown", true);
            if (persistent /*>prop<*/ == true || persistent /*>prop<*/ == pre_1) {
                persistent /*>icon<*/ = self._itemIconDone;
            } else {
                persistent /*>icon<*/ = self._itemIcon;
            }
            persistent /*>movedown<*/ = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.StMoveBottom), null, 6, persistent /*>icon<*/, null, version /*>pre_0<*/, null);
            self.Items.add(persistent /*>movedown<*/);

            //Double tap for set items done
            persistent /*>prop<*/ = Helper.Properties.Get("DoubleTapForDone", false);
            if (persistent /*>prop<*/ == true || persistent /*>prop<*/ == pre_1) {
                persistent /*>icon<*/ = self._itemIconDone;
            } else {
                persistent /*>icon<*/ = self._itemIcon;
            }
            persistent /*>doubletap<*/ = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.StDoubleTapForDone), null, 7, persistent /*>icon<*/, null, version /*>pre_0<*/, null);
            self.Items.add(persistent /*>doubletap<*/);

            //Show notes for items
            persistent /*>prop<*/ = Helper.Properties.Get("ShowNotes", true);
            if (persistent /*>prop<*/ == true || persistent /*>prop<*/ == pre_1) {
                persistent /*>icon<*/ = self._itemIconDone;
            } else {
                persistent /*>icon<*/ = self._itemIcon;
            }
            persistent /*>shownotes<*/ = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.StShowNotes), null, 8, persistent /*>icon<*/, null, version /*>pre_0<*/, null);
            self.Items.add(persistent /*>shownotes<*/);

            //auto exit
            persistent /*>txt<*/ = "";
            switch (Helper.Properties.Get("AutoExit", version /*>pre_0<*/)) {
                case version /*>pre_0<*/:
                    persistent /*>txt<*/ = Application.loadResource(Rez.Strings.StAutoExitOff);
                    break;
                case pre_1:
                    persistent /*>txt<*/ = Application.loadResource(Rez.Strings.StAutoExit1);
                    break;
                case 3:
                    persistent /*>txt<*/ = Application.loadResource(Rez.Strings.StAutoExit3);
                    break;
                case 5:
                    persistent /*>txt<*/ = Application.loadResource(Rez.Strings.StAutoExit5);
                    break;
                case 10:
                    persistent /*>txt<*/ = Application.loadResource(Rez.Strings.StAutoExit10);
                    break;
                case 15:
                    persistent /*>txt<*/ = Application.loadResource(Rez.Strings.StAutoExit15);
                    break;
                case 30:
                    persistent /*>txt<*/ = Application.loadResource(Rez.Strings.StAutoExit30);
                    break;
                case 60:
                    persistent /*>txt<*/ = Application.loadResource(Rez.Strings.StAutoExit60);
                    break;
            }
            persistent /*>autoexit<*/ = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.StAutoExit), persistent /*>txt<*/, 9, null, null, version /*>pre_0<*/, null);
            persistent /*>autoexit<*/.TitleJustification = pre_1 as Toybox.Graphics.TextJustification;
            persistent /*>autoexit<*/.SubtitleJustification = pre_1 as Toybox.Graphics.TextJustification;
            self.Items.add(persistent /*>autoexit<*/);

            // Change Theme
            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StTheme), pre_1, null, true));

            // Hardware button controls
            if (ItemView.SupportedControls() == 2) {
                self.addItem(Application.loadResource(Rez.Strings.StBtnCtrl), null, 10, ItemView.DisplayButtonSupport() ? self._itemIconDone : self._itemIcon, version /*>pre_0<*/);
            }

            //store logs
            persistent /*>prop<*/ = Helper.Properties.Get("Logs", true);
            self.addItem(Application.loadResource(Rez.Strings.StLogs), null, 2, persistent /*>prop<*/ ? self._itemIconDone : self._itemIcon, version /*>pre_0<*/);

            //store logs persistent
            persistent /*>prop<*/ = Helper.Properties.Get("PersistentLogs", true);
            persistent = new Listitems.Item(
                self._mainLayer,
                Application.loadResource(Rez.Strings.StPersistentLogs1),
                Application.loadResource(Rez.Strings.StPersistentLogs2),
                3,
                persistent /*>prop<*/ ? self._itemIconDone : self._itemIcon,
                null,
                version /*>pre_0<*/,
                null
            );
            persistent.DrawLine = true;
            persistent.SubtitleJustification = pre_1 as Toybox.Graphics.TextJustification;
            self.Items.add(persistent);

            //send logs to phone
            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StSendLogs), 4, null, true));

            // open appstore
            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StAppStore), 5, null, true));

            //app version
            persistent /*>str<*/ = Application.loadResource(Rez.Strings.StAppVersion);
            version = Properties /*>Application.Properties<*/.getValue("appVersion");
            persistent /*>item<*/ = new Listitems.Item(self._mainLayer, persistent /*>str<*/, version, "test", null, null, -1, null);
            persistent /*>item<*/.TitleJustification = pre_1 as Toybox.Graphics.TextJustification;
            persistent /*>item<*/.SubtitleJustification = pre_1 as Toybox.Graphics.TextJustification;
            persistent /*>item<*/.DrawLine = false;
            persistent /*>item<*/.isSelectable = false;
            self.Items.add(persistent /*>item<*/);

            if ($.getApp().NoBackButton) {
                self.addBackButton(false);
            }

            self._needValidation = true;
        }

        protected function interactItem(item as Listitems.Item, doubletap as Boolean) as Boolean {
            var pre_1;
            if (!IconItemView.interactItem(item, doubletap)) {
                doubletap /*>pre_0<*/ = 0;
                if (item.BoundObject == doubletap /*>pre_0<*/) {
                    WatchUi.pushView(new WatchUi.Confirmation(Application.loadResource(Rez.Strings.StDelAllConfirm)), new Controls.ConfirmDelegate(self.method(:deleteAllLists)), 5 as Toybox.WatchUi.SlideType);
                } else if ([6, 7, 8].indexOf(item.BoundObject) >= doubletap /*>pre_0<*/) {
                    switch (item.BoundObject) {
                        case 6:
                            pre_1 /*>prop<*/ = "ListMoveDown";
                            break;
                        case 7:
                            pre_1 /*>prop<*/ = "DoubleTapForDone";
                            break;
                        case 8:
                            pre_1 /*>prop<*/ = "ShowNotes";
                            break;
                        default:
                            pre_1 /*>prop<*/ = null;
                            break;
                    }
                    if (pre_1 /*>prop<*/ != null) {
                        doubletap /*>val<*/ = !Helper.Properties.Get(pre_1 /*>prop<*/, false);
                        Helper.Properties.Store(pre_1 /*>prop<*/, doubletap /*>val<*/);
                        item.setIcon(doubletap /*>val<*/ ? self._itemIconDone : self._itemIcon);
                        item.setIconInvert(doubletap /*>val<*/ ? self._itemIconDoneInvert : self._itemIconInvert);
                        WatchUi.requestUpdate();
                        if ($.getApp().ListsManager != null) {
                            $.getApp().GlobalStates.put("movetop", true);
                        }
                    }
                } else if (item.BoundObject == 10) {
                    doubletap /*>check<*/ = item.getIcon() == self._itemIcon;
                    Helper.Properties.Store("HWBCtrl", doubletap /*>check<*/);
                    item.setIcon(doubletap /*>check<*/ ? self._itemIconDone : self._itemIcon);
                    $.getApp().triggerOnSettingsChanged();
                } else if (item.BoundObject == 2) {
                    doubletap /*>check<*/ = item.getIcon() == self._itemIcon;
                    Helper.Properties.Store("Logs", doubletap /*>check<*/);
                    item.setIcon(doubletap /*>check<*/ ? self._itemIconDone : self._itemIcon);
                    WatchUi.requestUpdate();
                } else if (item.BoundObject == 3) {
                    doubletap /*>check<*/ = item.getIcon() == self._itemIcon;
                    Helper.Properties.Store("PersistentLogs", doubletap /*>check<*/);
                    item.setIcon(doubletap /*>check<*/ ? self._itemIconDone : self._itemIcon);
                    WatchUi.requestUpdate();
                } else {
                    pre_1 = 1;
                    if (item.BoundObject == 4) {
                        if (Helper.Properties.Get("Logs", true) == true) {
                            if ($.getApp().Debug != null) {
                                $.getApp().Debug.SendLogs();
                            }
                            Helper.ToastUtil.Toast(Rez.Strings.StSendLogsOk, doubletap /*>pre_0<*/);
                        } else {
                            Helper.ToastUtil.Toast(Rez.Strings.StSendLogsOff, pre_1);
                        }
                    } else if (item.BoundObject == 9) {
                        doubletap /*>view<*/ = new SettingsAutoexitView();
                        WatchUi.pushView(doubletap /*>view<*/, new ItemViewDelegate(doubletap /*>view<*/), pre_1 as Toybox.WatchUi.SlideType);
                    } else if (item.BoundObject == pre_1) {
                        doubletap /*>view<*/ = new SettingsThemeView();
                        WatchUi.pushView(doubletap /*>view<*/, new ItemViewDelegate(doubletap /*>view<*/), pre_1 as Toybox.WatchUi.SlideType);
                    } else if (item.BoundObject == 5) {
                        ListsApp.openGooglePlay();
                    }
                } /* else if (item.BoundObject != null) {
                    var view = new ErrorView(Rez.Strings.ErrListRec, 666, {});
                    WatchUi.pushView(view, new ItemViewDelegate(view), WatchUi.SLIDE_LEFT);
                }*/
                return true;
            }

            return false;
        }
    }
}
