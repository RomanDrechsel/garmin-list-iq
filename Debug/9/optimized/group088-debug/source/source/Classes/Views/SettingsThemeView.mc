using Rez;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Application;
import Controls;
import Controls.Listitems;
import Helper;

module Views {
    class SettingsThemeView extends IconItemView {
        private var _themes as Dictionary<Number, String> = {};
        private var _lastScroll as Number = 0;

        function initialize() {
            ItemView.initialize();

            self._themes = {};
            self._themes.put(0, Application.loadResource(Rez.Strings.ThGrey));
            self._themes.put(1, Application.loadResource(Rez.Strings.ThRed));
            self._themes.put(2, Application.loadResource(Rez.Strings.ThBaW));
            self._themes.put(3, Application.loadResource(Rez.Strings.ThWaB));
            self._themes.put(666, Application.loadResource(Rez.Strings.ThBsoD));
        }

        function onLayout(dc as Dc) as Void {
            IconItemView.onLayout(dc);
            self.loadThemes();
        }

        function onShow() as Void {
            IconItemView.onShow();
            self._scrollOffset = self._lastScroll;
        }

        function onSettingsChanged() as Void {
            IconItemView.onSettingsChanged();
            self._scrollOffset = self._lastScroll;
            self.loadThemes();
        }

        function onScroll(delta as Number) as Void {
            IconItemView.onScroll(delta);
            self._lastScroll = self._scrollOffset;
        }

        protected function interactItem(item as Listitems.Item, doubletap as Boolean) as Boolean {
            if ($.getApp().ListsManager == null) {
                return false;
            }

            doubletap /*>theme<*/ = Helper.Properties.Get("Theme", 0);
            if (item.BoundObject instanceof String && item.BoundObject.equals("back")) {
                self.goBack();
                return true;
            }
            if (item.BoundObject != doubletap /*>theme<*/) {
                if (self._themes.get(item.BoundObject) != null) {
                    Helper.Properties.Store("Theme", item.BoundObject);
                    $.getApp().triggerOnSettingsChanged();
                    return true;
                }
            }
            return false;
        }

        private function loadThemes() as Void {
            var pre_0;
            pre_0 = 0;
            self.Items = [];
            self.setTitle(Application.loadResource(Rez.Strings.SelTheme));

            var theme = Helper.Properties.Get("Theme", pre_0);

            var keys = self._themes.keys();
            for (var i = pre_0; i < keys.size(); i += 1) {
                var item,
                    key = keys[i];
                item /*>name<*/ = self._themes.get(key);
                if (item /*>name<*/ == null) {
                    continue;
                }

                item = self.addItem(item /*>name<*/, null, key, key == theme ? self._itemIconDone : self._itemIcon, i);
                if (key == theme) {
                    self._centerItemOnDraw = item;
                }
            }

            //no lone below the last items
            if (self.Items.size() > pre_0) {
                self.Items[self.Items.size() - 1].DrawLine = false;
            }

            if (self.DisplayButtonSupport()) {
                self.addBackButton(false);
            }
        }
    }
}
