using Debug;
using Rez;
using Toybox.Application;
using Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Lists;
import Controls;
import Controls.Listitems;
import Helper;

module Views {
    class ListSettingsView extends IconItemView {
        var ListUuid = null;

        private var _resetActive as Boolean? = null;
        private var _resetInterval as String? = null;

        function initialize(uuid as String) {
            IconItemView.initialize();
            self.ScrollMode = 1;
            self.ListUuid = uuid;
            self.readList();
        }

        function onLayout(dc as Dc) {
            IconItemView.onLayout(dc);
            if ($.getApp().ListsManager != null) {
                $.getApp().ListsManager.addListChangedListener(self);
            }
            self.loadItems(false);
        }

        protected function interactItem(item as Listitems.Item, doubletap as Boolean) as Boolean {
            if ($.getApp().ListsManager == null) {
                return;
            }

            if (item.BoundObject.equals("del")) {
                WatchUi.pushView(new WatchUi.Confirmation(Application.loadResource(Rez.Strings.DeleteConfirm)), new Controls.ConfirmDelegate(self.method(:deleteList)), 5 as Toybox.WatchUi.SlideType);
                return true;
            } else if (item.BoundObject.equals("reset")) {
                var list = $.getApp().ListsManager.getList(self.ListUuid) as Lists.List?;
                if (list != null) {
                    doubletap /*>active<*/ = list.get("r_a") as Boolean?;
                    if (doubletap /*>active<*/ != null) {
                        doubletap /*>active<*/ = !doubletap /*>active<*/;
                        list.put("r_a", doubletap /*>active<*/);
                        list.put("r_last", Time.now().value());
                        $.getApp().ListsManager.saveList(self.ListUuid, list);
                        item.setIcon(doubletap /*>active<*/ ? self._itemIconDone : self._itemIcon);
                        item.setIconInvert(doubletap /*>active<*/ ? self._itemIconDoneInvert : self._itemIconInvert);
                        WatchUi.requestUpdate();
                        if (doubletap /*>active<*/) {
                            Debug.Log("Activeded auto reset for list " + self.ListUuid);
                        } else {
                            Debug.Log("Deactivated auto reset for list " + self.ListUuid);
                        }
                    } else {
                        Debug.Log("List " + self.ListUuid + " has no reset settings.");
                    }
                } else {
                    Debug.Log("List " + self.ListUuid + " not found for toggling reset setting");
                }
                return true;
            } else if (item.BoundObject.equals("back")) {
                $.getApp().GlobalStates.put("movetop", true);
                self.goBack();
                return true;
            }
        }

        function deleteList() as Void {
            if ($.getApp().ListsManager != null) {
                $.getApp().ListsManager.deleteList(self.ListUuid, true);
                $.getApp().GlobalStates.put("movetop", true);
            }
            $.getApp().GlobalStates.put("startpage", true);
            WatchUi.popView(0 as Toybox.WatchUi.SlideType);
            WatchUi.popView(0 as Toybox.WatchUi.SlideType);
        }

        function onSettingsChanged() as Void {
            IconItemView.onSettingsChanged();
            self.loadItems(true);
        }

        function onListsChanged(index as ListIndex) as Void {
            self.readList();
            self.loadItems(true);
        }

        function onKeyEsc() as Boolean {
            IconItemView.onKeyEsc();
            self.goBack();
            return true;
        }

        function onKeyMenu() as Boolean {
            IconItemView.onKeyMenu();
            self.goBack();
            return true;
        }

        private function loadItems(request_update as Boolean) as Void {
            var pre_1;
            pre_1 = 1;
            self.Items = [];
            self.setTitle(Application.loadResource(Rez.Strings.StTitle));

            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StDelList), "del", null, false));

            if (self._resetActive != null) {
                var icon;
                if (self._resetActive == true) {
                    icon = self._itemIconDone;
                } else {
                    icon = self._itemIcon;
                }

                var interval = null;
                if (self._resetInterval != null) {
                    if (self._resetInterval.equals("d")) {
                        interval = Application.loadResource(Rez.Strings.StResetDaily);
                    } else if (self._resetInterval.equals("w")) {
                        interval = Application.loadResource(Rez.Strings.StResetWeekly);
                    } else if (self._resetInterval.equals("m")) {
                        interval = Application.loadResource(Rez.Strings.StResetMonthly);
                    }
                }

                self.Items[self.Items.size() - pre_1].DrawLine = true;
                self.Items.add(new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.StReset), interval, "reset", icon, null, 0, null));
                self.Items[self.Items.size() - pre_1].SubtitleJustification = pre_1 as Toybox.Graphics.TextJustification;
            }

            //no line below the last items
            self.Items[self.Items.size() - pre_1].DrawLine = false;

            if (self.DisplayButtonSupport()) {
                self.addBackButton(false);
            }

            self._needValidation = true;
            if (request_update) {
                WatchUi.requestUpdate();
            }
        }

        private function readList() as Void {
            if ($.getApp().ListsManager == null) {
                return;
            }

            var list = $.getApp().ListsManager.getList(self.ListUuid) as Lists.List?;
            if (list != null) {
                var active = list.get("r_a");
                if (active != null) {
                    self._resetActive = active;
                    self._resetInterval = list.get("r_i");
                } else {
                    self._resetActive = null;
                    self._resetInterval = null;
                }
            } else {
                self._resetActive = null;
                self._resetInterval = null;
            }
        }
    }
}
