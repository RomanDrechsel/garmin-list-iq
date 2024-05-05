import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Time;
import Lists;
import Views.Controls;
import Helper;
import Gfx;

module Views 
{
    class ListsSelectView extends CustomView
    {
        var ScrollMode = SCROLL_SNAP;
        private var _listIconCode = 48;

        private var _noListsLabel = null;
        private var _noListsLabel2 = null;

        function initialize()
        {
            CustomView.initialize();
        }

        function onLayout(dc as Dc) as Void
        {
            CustomView.onLayout(dc);
            self.UI_dragThreshold = (dc.getHeight() / 6).toNumber();
        }

        function onShow() as Void
        {
            CustomView.onShow();
            $.getApp().ListsManager.OnListsChanged.add(self);
            self.publishLists(getApp().ListsManager.GetLists(), false);
            Application.Storage.deleteValue("LastList");
        }

        function onHide() as Void
        {
            CustomView.onHide();
            $.getApp().ListsManager.OnListsChanged.remove(self);
        }
 
        function onUpdate(dc as Dc) as Void
        {
            View.onUpdate(dc);
            
            dc.setColor(getTheme().BackgroundColor, getTheme().BackgroundColor);
            dc.clear();

            if (self.Items.size() > 0)
            {
                self.drawList();
            }
            else
            {
                self.noLists(dc);
            }
        }

        function onListTap(position as Number, item as ViewItem) as Void
        {
            if (item != null)
            {
                self.GotoList(item.BoundObject);
            }
        }

        function onDoubleTap(x as Number, y as Number) as Void
        {
            if (self.Items.size() == 0)
            {
                var init = Application.Properties.getValue("Init") as Number;
                if (init == null || init < 1)
                {
                    Communications.openWebPage(getAppStore(), null, null);
                }
            }
        }

        function onListsChanged(index as ListIndexType) as Void
        {
            self.publishLists(index, false);
        }

        private function publishLists(index as ListIndexType, init as Boolean) as Void
        {
            if (index == null)
            {
                return;
            }

            var startlist = getApp().startupList;
            getApp().startupList = null;
            if (startlist != null && startlist.length() > 0)
            {
                if (index.hasKey(startlist))
                {
                    self.GotoList(startlist);
                }
            }

            var lists = index.values() as Array<ListIndexItemType>;
            lists = MergeSort.Sort(lists, "order");

            self.Items = [] as Array<ViewItem>;
            for (var i = 0; i < lists.size(); i++)
            {
                var list = lists[i] as ListIndexItemType;
                var substring = "";
                var items = list.get("items") as Number;
                if (items != null)
                {
                    substring = Application.loadResource(Rez.Strings.LMSub) as String;
                    substring = Helper.StringUtil.stringReplace(substring, "%s", items.toString());
                }
                var date = list.get("date");
                if (date != null)
                {
                    if (substring.length() > 0)
                    {
                        substring += "\n";
                    }
                    substring += DateUtil.toString(date, null);
                }
                self.addItem(list.get("name") as String, substring, list.get("key") as String, self._listIconCode, i);
            }

            if (self.Items.size() > 0)
            {
                self.moveIterator(null);
            }

            if (!init)
            {
                WatchUi.requestUpdate();
            }
        }

        private function noLists(dc as Dc) as Void
        {
            var width = (dc.getWidth() - (2 * self._margin));
            var height = (dc.getHeight() - (2 * self._margin));
            var padding = 0;
            if (self._margin == 0)
            {
                padding = width * 0.1;
            }

            if (self._noListsLabel == null)
            {
                self._noListsLabel = new MultilineLabel(dc, Application.loadResource(Rez.Strings.NoLists), width - (2 * padding), Fonts.get(Gfx.FONT_NORMAL));
                self._noListsLabel.Justification = Graphics.TEXT_JUSTIFY_CENTER;

                var init = Application.Properties.getValue("Init") as Number;
                if (init == null || init < 1)
                {
                    self._noListsLabel2 = new MultilineLabel(dc, Application.loadResource(Rez.Strings.NoListsLink), width - (2 * padding), Fonts.get(Gfx.FONT_SMALL));
                    self._noListsLabel2.Justification = Graphics.TEXT_JUSTIFY_CENTER;
                }
                else
                {
                    self._noListsLabel2 = null;
                }
            }

            var y = ((height - self._noListsLabel.getHeight()) * 0.3) + self._margin;
            self._noListsLabel.drawText(dc, self._margin + padding, y, 0xffffff);

            if (self._noListsLabel2 != null)
            {
                y = height - self._noListsLabel2.getHeight() - 20 + self._margin;
                self._noListsLabel2.drawText(dc, self._margin + padding, y, 0xbdbdbd);
            }
        }

        private function GotoList(uuid as String) as Void
        {
            var view = new ListDetailsView(uuid);
            var delegate = new ListDetailsViewDelegate(view);
            WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
        }
    }
}