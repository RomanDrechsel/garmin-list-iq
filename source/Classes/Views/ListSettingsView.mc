import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Lists;
import Controls;
import Controls.Listitems;
import Helper;

module Views {
    class ListSettingsView extends IconItemView {
        var ListUuid as String;
        private var _resetActive as Boolean? = null;
        private var _resetInterval as String? = null;

        function initialize(uuid as String) {
            IconItemView.initialize();
            self.ScrollMode = SCROLL_DRAG;
            self.ListUuid = uuid;
            self.readList(null);
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
                return false;
            }

            if (item.BoundObject.equals("del")) {
                var dialog = new WatchUi.Confirmation(Application.loadResource(Rez.Strings.DeleteConfirm));
                var delegate = new Controls.ConfirmDelegate(self.method(:deleteList));
                WatchUi.pushView(dialog, delegate, WatchUi.SLIDE_BLINK);
                return true;
            } else if (item.BoundObject.equals("reset")) {
                var list = $.getApp().ListsManager.GetList(self.ListUuid) as Lists.List?;
                if (list != null) {
                    if (list.Reset != null) {
                        list.Reset = !list.Reset;
                        list.ResetLast = Time.now().value();
                        if (list.Reset) {
                            Debug.Log("Activeded auto reset for list " + list.toString());
                        } else {
                            Debug.Log("Deactivated auto reset for list " + list.toString());
                        }
                        $.getApp().ListsManager.StoreList(list);
                    } else {
                        Debug.Log("List " + list.toString() + " has no reset settings.");
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
            return false;
        }

        function deleteList() as Void {
            if ($.getApp().ListsManager != null) {
                $.getApp().ListsManager.deleteList(self.ListUuid, true);
                $.getApp().GlobalStates.put("movetop", true);
            }
            $.getApp().GlobalStates.put("startpage", true);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }

        function onSettingsChanged() as Void {
            IconItemView.onSettingsChanged();
            self.loadItems(true);
        }

        function onListChanged(list as Lists.List?) as Void {
            if (list != null && list.Uuid.equals(self.ListUuid)) {
                self.readList(list);
                self.loadItems(true);
            }
        }

        function onKeyEsc() as Boolean {
            if (!IconItemView.onKeyEsc()) {
                self.goBack();
            }

            return true;
        }

        function onKeyMenu() as Boolean {
            if (!IconItemView.onKeyMenu()) {
                self.goBack();
            }
            return true;
        }

        private function loadItems(request_update as Boolean) as Void {
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

                self.Items[self.Items.size() - 1].DrawLine = true;
                self.Items.add(new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.StReset), interval, "reset", icon, null, 0, null));
                self.Items[self.Items.size() - 1].SubtitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
            }

            //no line below the last items
            self.Items[self.Items.size() - 1].DrawLine = false;

            if (self.DisplayButtonSupport()) {
                self.addBackButton(false);
            }

            self._needValidation = true;
            if (request_update) {
                WatchUi.requestUpdate();
            }
        }

        private function readList(list as Lists.List?) as Void {
            if ($.getApp().ListsManager == null) {
                return;
            }

            if (list == null) {
                list = $.getApp().ListsManager.GetList(self.ListUuid) as Lists.List?;
            }
            if (list != null) {
                self._resetActive = list.Reset;
                self._resetInterval = list.ResetInterval;
            } else {
                self._resetActive = null;
                self._resetInterval = null;
            }
        }
    }
}
