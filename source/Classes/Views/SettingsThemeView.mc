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

        protected function interactItem(item as Listitems.Item, doubletap as Boolean) as Void {
            if ($.getApp().ListsManager == null) {
                return;
            }

            var theme = Helper.Properties.Get(Helper.Properties.THEME, 0);
            if (item.BoundObject != theme) {
                var name = self._themes.get(item.BoundObject);
                if (name != null) {
                    Helper.Properties.Store(Helper.Properties.THEME, item.BoundObject);
                    $.getApp().triggerOnSettingsChanged();
                }
            }
        }

        private function loadThemes() as Void {
            self.Items = [];
            self.setTitle(Application.loadResource(Rez.Strings.SelTheme));

            var theme = Helper.Properties.Get(Helper.Properties.THEME, 0);

            var keys = self._themes.keys();
            var setItem = 1;
            for (var i = 0; i < keys.size(); i++) {
                var key = keys[i];
                var name = self._themes.get(key);
                if (name == null) {
                    continue;
                }

                self.addItem(name, null, key, key == theme ? self._itemIconDone : self._itemIcon, i);
                if (key == theme) {
                    setItem = i + 1;
                }
            }

            //no lone below the last items
            if (self.Items.size() > 0) {
                self.Items[self.Items.size() - 1].DrawLine = false;
            }

            self.setIterator(setItem);
        }
    }
}
