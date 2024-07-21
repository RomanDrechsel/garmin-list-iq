import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Time;
import Lists;
import Controls;
import Controls.Listitems;
import Helper;

module Views {
    class ListsSelectView extends Controls.CustomView {
        private var _listIconCode = 48;

        private var _noListsLabel as MultilineLabel? = null;
        private var _noListsLabel2 as MultilineLabel? = null;

        protected var TAG = "ListsSelectView";

        function initialize() {
            self.ScrollMode = SCROLL_SNAP;
            CustomView.initialize();
        }

        function onShow() as Void {
            CustomView.onShow();
            $.getApp().ListsManager.OnListsChanged.add(self);
            self.publishLists(getApp().ListsManager.GetLists(), true);
            Application.Storage.deleteValue("LastList");
        }

        function onHide() as Void {
            CustomView.onHide();
            $.getApp().ListsManager.OnListsChanged.remove(self);
        }

        function onUpdate(dc as Dc) as Void {
            CustomView.onUpdate(dc);

            dc.setColor(getTheme().BackgroundColor, getTheme().BackgroundColor);
            dc.clear();

            if (self.Items.size() > 0) {
                self.drawList(dc);
            } else {
                self.noLists(dc);
            }
        }

        function onListTap(position as Number, item as Item, doubletap as Boolean) as Void {
            self.GotoList(item.BoundObject);
        }

        function onDoubleTap(x as Number, y as Number) as Void {
            if (self.Items.size() == 0) {
                var init = Application.Properties.getValue("Init") as Number;
                if (init == null || init < 1) {
                    Communications.openWebPage(getAppStore(), null, null);
                }
            }
        }

        function onListsChanged(index as ListIndexType) as Void {
            self.publishLists(index, false);
        }

        private function publishLists(index as ListIndexType?, init as Boolean) as Void {
            if (index == null) {
                return;
            }

            var startlist = getApp().startupList;
            getApp().startupList = null;
            if (startlist != null && startlist.length() > 0) {
                if (index.hasKey(startlist)) {
                    self.GotoList(startlist);
                }
            }

            var lists = index.values() as Array<ListIndexItemType>;
            lists = Helper.MergeSort.Sort(lists, "order");

            self.Items = [] as Array<Item>;
            for (var i = 0; i < lists.size(); i++) {
                var list = lists[i] as ListIndexItemType;
                var substring = "";
                var items = list.get("items") as Number;
                if (items != null) {
                    substring = Application.loadResource(Rez.Strings.LMSub) as String;
                    substring = Helper.StringUtil.stringReplace(substring, "%s", items.toString());
                }
                var date = list.get("date");
                if (date != null) {
                    if (substring.length() > 0) {
                        substring += "\n";
                    }
                    substring += Helper.DateUtil.toString(date, null);
                }
                self.addItem(list.get("name") as String, substring, list.get("key") as String, self._listIconCode, i);
            }

            if (self.Items.size() > 0) {
                self.moveIterator(null);
            }

            if (!init) {
                WatchUi.requestUpdate();
            }
        }

        private function noLists(dc as Dc) as Void {
            var width = self._mainLayer.getWidth();

            var hor_padding = 0;
            if ($.isRoundDisplay == false) {
                hor_padding = width * 0.1;
            }

            if (self._noListsLabel == null) {
                self._noListsLabel = new MultilineLabel(Application.loadResource(Rez.Strings.NoLists), width - 2 * hor_padding, Fonts.Normal());

                var init = Application.Properties.getValue("Init") as Number?;
                if (init == null || init < 1) {
                    self._noListsLabel2 = new MultilineLabel(Application.loadResource(Rez.Strings.NoListsLink), width - 2 * hor_padding, Fonts.Small());
                } else {
                    self._noListsLabel2 = null;
                }
            }

            var y;
            if (self._noListsLabel2 == null) {
                y = self._mainLayer.getY() + (self._mainLayer.getHeight() - self._noListsLabel.getHeight(dc)) / 2;
            } else {
                y = self._mainLayer.getY() + (self._mainLayer.getHeight() - self._noListsLabel2.getHeight(dc) - self._noListsLabel.getHeight(dc)) / 2;

                //no overlapping of the labels
                var label1_bottom = y + self._noListsLabel.getHeight(dc);
                var label2_top = dc.getHeight() - self._noListsLabel2.getHeight(dc) - self._mainLayer.getY();
                if ($.isRoundDisplay == false) {
                    label2_top -= self._verticalItemMargin;
                }
                if (label1_bottom > label2_top) {
                    y -= label1_bottom - label2_top;
                }

                if (y < self._mainLayer.getY()) {
                    y = self._mainLayer.getY();
                }
            }

            self._noListsLabel.drawText(dc, self._mainLayer.getX() + hor_padding, y, getTheme().MainColor, Graphics.TEXT_JUSTIFY_CENTER);

            if (self._noListsLabel2 != null) {
                y = dc.getHeight() - self._noListsLabel2.getHeight(dc) - self._mainLayer.getY();
                if ($.isRoundDisplay == false) {
                    y -= self._verticalItemMargin;
                }
                self._noListsLabel2.drawText(dc, self._mainLayer.getX() + hor_padding, y, getTheme().SecondColor, Graphics.TEXT_JUSTIFY_CENTER);
            }
        }

        private function GotoList(uuid as String) as Void {
            var view = new ListDetailsView(uuid);
            var delegate = new ListDetailsViewDelegate(view);
            WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
        }
    }
}
