import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Application;
import Controls;
import Controls.Listitems;
import Exceptions;

module Views {
    class SettingsThemeView extends IconItemView {
        private var _themes as Dictionary<Number, String> = {};
        private var _lastScroll as Number = 0;

        function initialize() {
            IconItemView.initialize();

            self._themes = {
                0 => Application.loadResource(Rez.Strings.ThGrey),
                1 => Application.loadResource(Rez.Strings.ThRed),
                2 => Application.loadResource(Rez.Strings.ThBaW),
                3 => Application.loadResource(Rez.Strings.ThWaB),
                666 => Application.loadResource(Rez.Strings.ThBsoD),
            };
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
            if (!IconItemView.interactItem(item, doubletap)) {
                if ($.getApp().ListsManager == null) {
                    return false;
                }

                var theme = Helper.Properties.Get(Helper.Properties.THEME, 0);
                if (item.BoundObject instanceof Number && item.BoundObject != theme) {
                    if (self._themes.hasKey(item.BoundObject as Number)) {
                        Helper.Properties.Store(Helper.Properties.THEME, item.BoundObject as Number);
                        $.getApp().triggerOnSettingsChanged();
                        return true;
                    }
                }

                return false;
            }
            return true;
        }

        private function loadThemes() as Void {
            self.Items = [];
            self.setTitle(Application.loadResource(Rez.Strings.SelTheme));

            var theme = Helper.Properties.Get(Helper.Properties.THEME, 0);

            var keys = self._themes.keys();
            for (var i = 0; i < keys.size(); i++) {
                var key = keys[i];
                var name = self._themes.get(key);
                if (name == null) {
                    continue;
                }

                var item = self.addItem(name, null, key, key == theme ? self._itemIconDone : self._itemIcon, i);
                if (key == theme) {
                    self._centerItemOnDraw = item;
                }
            }

            //no lone below the last items
            if (self.Items.size() > 0) {
                self.Items[self.Items.size() - 1].DrawLine = false;
            }

            if (self.DisplayButtonSupport()) {
                self.addBackButton(false);
            }
        }
    }
}
