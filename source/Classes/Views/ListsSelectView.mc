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
        private var _firstDisplay = true;

        function initialize(first_display as Boolean) {
            self.ScrollMode = SCROLL_SNAP;
            self._firstDisplay = first_display;
            CustomView.initialize();
        }

        function onShow() as Void {
            CustomView.onShow();
            if ($.getApp().ListsManager != null) {
                $.getApp().ListsManager.OnListsChanged.add(self);
                self.publishLists($.getApp().ListsManager.GetLists(), false);
            }
        }

        function onHide() as Void {
            CustomView.onHide();
            if ($.getApp().ListsManager != null) {
                $.getApp().ListsManager.OnListsChanged.remove(self);
            }
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
            self.GotoList(item.BoundObject, -1);
        }

        function onDoubleTap(x as Number, y as Number) as Void {
            if (self.Items.size() == 0) {
                var init = Helper.Properties.Get(Helper.Properties.INIT, 0);
                if (init < 1) {
                    Communications.openWebPage(getAppStore(), null, null);
                }
            }
        }

        function onListsChanged(index as ListIndex) as Void {
            self.publishLists(index, true);
        }

        function onSettingsChanged() as Void {
            CustomView.onSettingsChanged();
            if ($.getApp().ListsManager != null) {
                self.publishLists($.getApp().ListsManager.GetLists(), true);
            }
        }

        private function publishLists(index as ListIndex?, initialize as Boolean) as Void {
            if (index == null) {
                return;
            }

            if (self._firstDisplay) {
                self._firstDisplay = false;
                var startuplist = Helper.Properties.Get(Helper.Properties.LASTLIST, "");
                if (startuplist.length() > 0) {
                    var startscroll = Helper.Properties.Get(Helper.Properties.LASTLISTSCROLL, -1);
                    Helper.Properties.Store(Helper.Properties.LASTLIST, "");
                    if (index.hasKey(startuplist)) {
                        self.GotoList(startuplist, startscroll);
                        return;
                    }
                }
            }
            self._firstDisplay = false;
            Helper.Properties.Store(Helper.Properties.LASTLIST, "");
            Helper.Properties.Store(Helper.Properties.LASTLISTSCROLL, -1);

            var lists = index.values() as Array<ListIndexItem>;
            lists = Helper.MergeSort.Sort(lists, "order");

            self.Items = [] as Array<Item>;
            for (var i = 0; i < lists.size(); i++) {
                var list = lists[i] as ListIndexItem;
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

            //no line below the last item
            if (self.Items.size() > 0) {
                self.Items[self.Items.size() - 1].DrawLine = false;
            }

            if (self.Items.size() > 0) {
                self.moveIterator(null);
            }

            if (initialize) {
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
                self._noListsLabel = new MultilineLabel(Application.loadResource(Rez.Strings.NoLists), width - 2 * hor_padding, Helper.Fonts.Normal());

                var init = Helper.Properties.Get(Helper.Properties.INIT, 0);
                if (init < 1) {
                    self._noListsLabel2 = new MultilineLabel(Application.loadResource(Rez.Strings.NoListsLink), width - 2 * hor_padding, Helper.Fonts.Small());
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

        private function GotoList(uuid as String, scroll as Number) as Void {
            var view = new ListDetailsView(uuid, scroll > 0 ? scroll : null);
            var delegate = new ListDetailsViewDelegate(view);
            WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
        }
    }
}
