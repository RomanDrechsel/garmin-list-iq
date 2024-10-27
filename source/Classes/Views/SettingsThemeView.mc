import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Application;
import Controls;
import Controls.Listitems;
import Helper;

module Views {
    class SettingsThemeView extends Controls.CustomView {
        private var _themes as Dictionary<Number, String> = {};

        function initialize() {
            CustomView.initialize();

            self._themes = {};
            self._themes.put(0, Application.loadResource(Rez.Strings.ThGrey));
            self._themes.put(1, Application.loadResource(Rez.Strings.ThRed));
            self._themes.put(2, Application.loadResource(Rez.Strings.ThBaW));
            self._themes.put(3, Application.loadResource(Rez.Strings.ThWaB));
            self._themes.put(666, Application.loadResource(Rez.Strings.ThBsoD));
        }

        function onLayout(dc as Dc) as Void {
            CustomView.onLayout(dc);
            self.loadThemes();
        }

        function onUpdate(dc as Dc) as Void {
            CustomView.onUpdate(dc);

            dc.setColor(getTheme().BackgroundColor, getTheme().BackgroundColor);
            dc.clear();
            self.drawList(dc);
        }

        function onSettingsChanged() as Void {
            self.loadThemes();
        }

        function onListTap(position as Number, item as Item, doubletap as Boolean) as Void {
            var theme = Helper.Properties.Get(Helper.Properties.THEME, 0);
            if (item.BoundObject != theme) {
                var name = self._themes.get(item.BoundObject);
                if (name != null) {
                    Helper.Properties.Store(Helper.Properties.THEME, item.BoundObject);
                    $.getApp().onSettingsChanged();
                }
            }
        }

        private function loadThemes() as Void {
            self.Items = [];
            self.setTitle(Application.loadResource(Rez.Strings.SelTheme));

            var theme = Helper.Properties.Get(Helper.Properties.THEME, 0);
            var itemIcon = $.getTheme().DarkTheme ? Application.loadResource(Rez.Drawables.Item) : Application.loadResource(Rez.Drawables.bItem);
            var itemIconDone = $.getTheme().DarkTheme ? Application.loadResource(Rez.Drawables.ItemDone) : Application.loadResource(Rez.Drawables.bItemDone);

            var keys = self._themes.keys();
            for (var i = 0; i < keys.size(); i++) {
                var key = keys[i];
                var name = self._themes.get(key);
                if (name == null) {
                    continue;
                }

                self.addItem(name, null, key, key == theme ? itemIconDone : itemIcon, i);
            }

            //no lone below the last items
            if (self.Items.size() > 0) {
                self.Items[self.Items.size() - 1].DrawLine = false;
            }
        }
    }
}
