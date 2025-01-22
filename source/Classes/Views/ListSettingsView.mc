import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Lists;
import Controls;
import Controls.Listitems;
import Helper;

module Views {
    class ListSettingsView extends ItemView {
        var ListUuid = null;

        private var _itemIconUncheck as Listitems.ViewItemIcon;
        private var _itemIconCheck as Listitems.ViewItemIcon;

        private var _resetActive as Boolean? = null;
        private var _resetInterval as String? = null;

        function initialize(uuid as String) {
            ItemView.initialize();
            self.ScrollMode = SCROLL_DRAG;
            self.ListUuid = uuid;
            self._itemIconUncheck = $.getTheme().DarkTheme ? Application.loadResource(Rez.Drawables.Item) : Application.loadResource(Rez.Drawables.bItem);
            self._itemIconCheck = $.getTheme().DarkTheme ? Application.loadResource(Rez.Drawables.ItemDone) : Application.loadResource(Rez.Drawables.bItemDone);

            self.readList();
        }

        function onLayout(dc as Dc) {
            ItemView.onLayout(dc);
        }

        function onShow() as Void {
            ItemView.onShow();
            if ($.getApp().ListsManager != null) {
                $.getApp().ListsManager.OnListsChanged.add(self);
            }
            self.loadItems(false);
        }

        function onHide() as Void {
            ItemView.onHide();
            if ($.getApp().ListsManager != null) {
                $.getApp().ListsManager.OnListsChanged.remove(self);
            }
        }

        protected function interactItem(item as Listitems.Item, doubletap as Boolean) as Void {
            if ($.getApp().ListsManager == null) {
                return;
            }

            if (item.BoundObject.equals("del")) {
                var dialog = new WatchUi.Confirmation(Application.loadResource(Rez.Strings.DeleteConfirm));
                var delegate = new Controls.ConfirmDelegate(self.method(:deleteList));
                WatchUi.pushView(dialog, delegate, WatchUi.SLIDE_BLINK);
            } else if (item.BoundObject.equals("reset")) {
                var list = $.getApp().ListsManager.getList(self.ListUuid) as Lists.List?;
                if (list != null) {
                    var active = list.get("r_a") as Boolean?;
                    if (active != null) {
                        list.put("r_a", !active);
                        list.put("r_last", Time.now().value());
                        $.getApp().ListsManager.saveList(self.ListUuid, list);
                        item.setIcon(!active ? self._itemIconCheck : self._itemIconUncheck);
                        WatchUi.requestUpdate();
                        if (active) {
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
            }
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
            ItemView.onSettingsChanged();
            self.loadItems(true);
        }

        function onListsChanged(index as ListIndex) as Void {
            self.readList();
            self.loadItems(true);
        }

        function onKeyEsc() as Boolean {
            ItemView.onKeyEsc();
            self.goBack();
            return true;
        }

        function onKeyMenu() as Boolean {
            ItemView.onKeyMenu();
            self.goBack();
            return true;
        }

        private function loadItems(request_update as Boolean) as Void {
            self.Items = [];
            self.setTitle(Application.loadResource(Rez.Strings.StTitle));

            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StDelList), "del", null, false));

            if (self._resetActive != null) {
                var icon;
                if (self._resetActive == true) {
                    icon = self._itemIconCheck;
                } else {
                    icon = self._itemIconUncheck;
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

            //no lone below the last items
            if (self.Items.size() > 0) {
                self.Items[self.Items.size() - 1].DrawLine = false;
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
