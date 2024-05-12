import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Lists;
import Controls;
import Controls.Listitems;
import Helper;

module Views {
    class ListDetailsView extends Controls.CustomView {
        var ScrollMode = SCROLL_DRAG;

        var ListUuid = null;
        private var _listFound = false;

        private var _noListLabel = null;
        private var _itemIcon as WatchUi.BitmapResource or Graphics.BitmapReference = Application.loadResource(Rez.Drawables.Item);
        private var _itemIconDone as WatchUi.BitmapResource or Graphics.BitmapReference = Application.loadResource(Rez.Drawables.ItemDone);

        protected var _fontoverride = Fonts.Large();

        function initialize(uuid as String) {
            CustomView.initialize();
            self.ListUuid = uuid;
        }

        function onLayout(dc as Dc) {
            CustomView.onLayout(dc);
        }

        function onShow() as Void {
            CustomView.onShow();
            $.getApp().ListsManager.OnListsChanged.add(self);
            self.publishItems(false);
        }

        function onHide() as Void {
            CustomView.onHide();
            $.getApp().ListsManager.OnListsChanged.remove(self);
        }

        function onUpdate(dc as Dc) as Void {
            CustomView.onUpdate(dc);
            dc.setColor(getTheme().BackgroundColor, getTheme().BackgroundColor);
            dc.clear();

            if (self._listFound == false || self.Items.size() == 0) {
                self.noLists(dc);
            } else {
                self.drawList(dc);
            }
        }

        function onListTap(position as Number, item as Item?) as Void {
            if (item != null) {
                if (item.BoundObject == false) {
                    item.setColor(getTheme().DisabledColor);
                    item.setIcon(self._itemIconDone);
                } else {
                    item.setColor(null);
                    item.setIcon(self._itemIcon);
                }
                item.BoundObject = !item.BoundObject;

                $.getApp().ListsManager.updateList(self.ListUuid, item.ItemPosition, item.BoundObject);
                self.publishItems(true);

                WatchUi.requestUpdate();
            }
        }

        function onListsChanged(index as ListIndexType) as Void {
            self.publishItems(true);
        }

        function showSettings() as Void {
            var view = new ListSettingsView(self.ListUuid);
            var delegate = new ListSettingsViewDelegate(view);
            WatchUi.pushView(view, delegate, WatchUi.SLIDE_BLINK);
        }

        private function publishItems(request_update as Boolean) as Void {
            self.Items = [];

            var list = getApp().ListsManager.getList(self.ListUuid) as List?;
            if (list == null) {
                self._listFound = false;
            } else {
                Application.Storage.setValue("LastList", self.ListUuid);

                self._listFound = true;
                if (list.hasKey("name")) {
                    self.setTitle(list.get("name"));
                }

                if (list.hasKey("items")) {
                    var settings_movedown = Application.Properties.getValue("ListMoveDown") as Number;
                    var movedown = settings_movedown != null && settings_movedown == 1 ? true : false;

                    var ordered = [];
                    var done = [];

                    for (var i = 0; i < list["items"].size(); i++) {
                        var item = list["items"][i];
                        item.put("pos", i);
                        if (movedown && item.hasKey("d") && item.get("d") == true) {
                            done.add(item);
                        } else {
                            ordered.add(item);
                        }
                    }

                    if (done.size() > 0) {
                        ordered.addAll(done);
                    }

                    for (var i = 0; i < ordered.size(); i++) {
                        var item = ordered[i];
                        var icon, obj;

                        if (item.hasKey("d") && item.get("d") == true) {
                            icon = self._itemIconDone;
                            obj = true;
                        } else {
                            icon = self._itemIcon;
                            obj = false;
                        }

                        var text = null;
                        var note = null;
                        var itemobj = item.get("i");
                        if (itemobj instanceof String) {
                            text = itemobj;
                        } else if (itemobj instanceof Array) {
                            text = itemobj[0];
                            if (itemobj.size() > 1) {
                                note = itemobj[1];
                            }
                        }

                        if (text != null) {
                            self.addItem(text, note, obj, icon, item.get("pos"));
                            if (obj == true) {
                                self.Items[self.Items.size() - 1].setColor(getTheme().DisabledColor);
                            }
                        }
                    }
                }
            }

            if (request_update) {
                WatchUi.requestUpdate();
            }
        }

        private function noLists(dc as Dc) as Void {
            if (self._noListLabel == null) {
                var text;
                if (self._listFound == false) {
                    text = Application.loadResource(Rez.Strings.ListNotFound);
                } else {
                    text = Application.loadResource(Rez.Strings.ListEmpty);
                }
                self._noListLabel = new MultilineLabel(text, (dc.getWidth() * 0.8).toNumber(), Fonts.Normal());
            }

            var y = (dc.getHeight() - self._noListLabel.getHeight()) / 2;
            self._noListLabel.drawText(dc, (dc.getWidth() * 0.1).toNumber(), y, $.getTheme().MainColor, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
}
