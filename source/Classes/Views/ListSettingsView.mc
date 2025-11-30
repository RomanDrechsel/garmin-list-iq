import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Lists;
import Controls;
import Controls.Listitems;
import Exceptions;

module Views {
    class ListSettingsView extends IconItemView {
        private enum {
            DELETE = 0,
            RESET = 1,
            AUTO_RESET = 2,
        }

        private var _listUuid as String or Number;
        private var _resetActive as Boolean? = null;
        private var _resetInterval as String? = null;

        function initialize(uuid as String or Number) {
            IconItemView.initialize();
            self.ScrollMode = SCROLL_DRAG;
            self._listUuid = uuid;
            self.readList(null);
        }

        function onLayout(dc as Dc) {
            IconItemView.onLayout(dc);
            $.getApp().ListsManager.addListChangedListener(self);
            self.loadItems(false);
        }

        protected function interactItem(item as Listitems.Item, doubletap as Boolean) as Boolean {
            var listsmanager = $.getApp().ListsManager;
            if (!IconItemView.interactItem(item, doubletap)) {
                if (item.BoundObject instanceof Number) {
                    if (item.BoundObject == DELETE) {
                        var dialog = new WatchUi.Confirmation(Application.loadResource(Rez.Strings.DeleteConfirm));
                        var delegate = new Controls.ConfirmDelegate(self.method(:deleteList));
                        WatchUi.pushView(dialog, delegate, WatchUi.SLIDE_BLINK);
                    } else if (item.BoundObject == RESET) {
                        if (listsmanager.ResetList(self._listUuid)) {
                            Helper.ToastUtil.Toast(Rez.Strings.StResetSuccess, Helper.ToastUtil.SUCCESS);
                        }
                    } else if (item.BoundObject == AUTO_RESET) {
                        var list = listsmanager.GetList(self._listUuid);
                        if (list != null) {
                            if (list.Reset != null) {
                                list.Reset = !list.Reset;
                                list.ResetLast = Time.now().value();
                                if (list.Reset) {
                                    Debug.Log("Activeded auto reset for list " + list.toString());
                                } else {
                                    Debug.Log("Deactivated auto reset for list " + list.toString());
                                }
                                listsmanager.StoreList(list);
                            } else {
                                Debug.Log("List " + list.toString() + " has no reset settings.");
                            }
                        } else {
                            Debug.Log("List " + self._listUuid + " not found for toggling reset setting");
                        }
                    } else {
                        return false;
                    }
                    return true;
                }
                return false;
            }
            return true;
        }

        function deleteList() as Void {
            $.getApp().ListsManager.deleteList(self._listUuid, true);
        }

        function onSettingsChanged() as Void {
            IconItemView.onSettingsChanged();
            self.loadItems(true);
        }

        function onListChanged(list as Lists.List?) as Void {
            if (list == null || list.Uuid.equals(self._listUuid)) {
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

            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StDelList), DELETE, null, false));
            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StResetBtn), RESET, null, false));

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
                self.Items.add(new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.StReset), interval, AUTO_RESET, icon, null, 0, null));
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
            var app = $.getApp();
            if (list == null) {
                list = app.ListsManager.GetList(self._listUuid);
            }
            if (list != null) {
                if (self._resetActive != null && list.Reset == null) {
                    self._scrollOffset = 0;
                }
                self._resetActive = list.Reset;
                self._resetInterval = list.ResetInterval;
            } else {
                app.GlobalStates.add(ListsApp.MOVETOP);
                app.GlobalStates.add(ListsApp.STARTPAGE);
                self.goBack();
            }
        }
    }
}
