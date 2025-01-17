import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Application;
import Controls;
import Controls.Listitems;
import Helper;

module Views {
    class SettingsAutoexitView extends Controls.CustomView {
        function onLayout(dc as Dc) as Void {
            CustomView.onLayout(dc);
            self.loadList();
        }

        function onSettingsChanged() as Void {
            CustomView.onSettingsChanged();
            self.loadList();
        }

        function onUpdate(dc as Dc) as Void {
            CustomView.onUpdate(dc);

            dc.setColor(getTheme().BackgroundColor, getTheme().BackgroundColor);
            dc.clear();
            self.drawList(dc);
        }

        function onListTap(position as Number, item as Item, doubletap as Boolean) as Void {
            var prop = Helper.Properties.Get(Helper.Properties.AUTOEXIT, 0);
            if (prop != item.BoundObject) {
                Helper.Properties.Store(Helper.Properties.AUTOEXIT, item.BoundObject);
                if ($.getApp().ListsManager != null) {
                    $.getApp().triggerOnSettingsChanged();
                }
                WatchUi.popView(WatchUi.SLIDE_RIGHT);
            }
        }

        private function loadList() as Void {
            var intervals = [0, 1, 3, 5, 10, 15, 30, 60];

            self.Items = [];
            self.setTitle(Application.loadResource(Rez.Strings.StAutoExit));

            var itemIcon = $.getTheme().DarkTheme ? Application.loadResource(Rez.Drawables.Item) : Application.loadResource(Rez.Drawables.bItem);
            var itemIconDone = $.getTheme().DarkTheme ? Application.loadResource(Rez.Drawables.ItemDone) : Application.loadResource(Rez.Drawables.bItemDone);
            var prop = Helper.Properties.Get(Helper.Properties.AUTOEXIT, 0);

            for (var i = 0; i < intervals.size(); i++) {
                var txt = "";
                var time = intervals[i];
                switch (time) {
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
                var item = new Listitems.Item(self._mainLayer, txt, null, time, prop == time ? itemIconDone : itemIcon, self._verticalItemMargin, i, null);
                self.Items.add(item);
            }

            //no lone below the last items
            if (self.Items.size() > 0) {
                self.Items[self.Items.size() - 1].DrawLine = false;
            }
        }
    }
}
