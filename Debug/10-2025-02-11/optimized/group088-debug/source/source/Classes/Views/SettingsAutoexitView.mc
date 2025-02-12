using Rez;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Application;
import Controls;
import Controls.Listitems;
import Helper;

module Views {
    class SettingsAutoexitView extends IconItemView {
        function onLayout(dc as Dc) as Void {
            IconItemView.onLayout(dc);
            self.loadList();
        }

        function onSettingsChanged() as Void {
            IconItemView.onSettingsChanged();
            self.loadList();
        }

        protected function interactItem(item as Listitems.Item, doubletap as Boolean) as Void {
            if (Helper.Properties.Get("AutoExit", 0) != item.BoundObject) {
                Helper.Properties.Store("AutoExit", item.BoundObject);
                if ($.getApp().ListsManager != null) {
                    $.getApp().triggerOnSettingsChanged();
                }
                self.goBack();
            }
        }

        private function loadList() as Void {
            var pre_0, pre_1;
            pre_1 = 1;
            pre_0 = 0;
            var intervals = [pre_0, pre_1, 3, 5, 10, 15, 30, 60];

            self.Items = [];
            self.setTitle(Application.loadResource(Rez.Strings.StAutoExit));
            var prop = Helper.Properties.Get("AutoExit", pre_0);

            for (var i = pre_0; i < intervals.size(); i += pre_1) {
                var item;
                item /*>txt<*/ = "";
                var time = intervals[i];
                switch (time) {
                    case pre_0:
                        item /*>txt<*/ = Application.loadResource(Rez.Strings.StAutoExitOff);
                        break;
                    case pre_1:
                        item /*>txt<*/ = Application.loadResource(Rez.Strings.StAutoExit1);
                        break;
                    case 3:
                        item /*>txt<*/ = Application.loadResource(Rez.Strings.StAutoExit3);
                        break;
                    case 5:
                        item /*>txt<*/ = Application.loadResource(Rez.Strings.StAutoExit5);
                        break;
                    case 10:
                        item /*>txt<*/ = Application.loadResource(Rez.Strings.StAutoExit10);
                        break;
                    case 15:
                        item /*>txt<*/ = Application.loadResource(Rez.Strings.StAutoExit15);
                        break;
                    case 30:
                        item /*>txt<*/ = Application.loadResource(Rez.Strings.StAutoExit30);
                        break;
                    case 60:
                        item /*>txt<*/ = Application.loadResource(Rez.Strings.StAutoExit60);
                        break;
                }
                item = new Listitems.Item(self._mainLayer, item /*>txt<*/, null, time, prop == time ? self._itemIconDone : self._itemIcon, null, i, null);
                self.Items.add(item);
                if (time == prop) {
                    self._centerItemOnDraw = item;
                }
            }

            //no lone below the last items
            if (self.Items.size() > pre_0) {
                self.Items[self.Items.size() - pre_1].DrawLine = false;
            }

            if (self.DisplayButtonSupport()) {
                self.addBackButton(false);
            }
        }
    }
}
