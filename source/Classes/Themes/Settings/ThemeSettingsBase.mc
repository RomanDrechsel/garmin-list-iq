import Toybox.Lang;
import Toybox.Application;
import Controls;

(:glance)
module Themes {
    class ThemeSettingsBase {
        var MainColor = 0xd7d7d7;
        var MainColorSelected = 0xd7d7d7;
        var SecondColor = 0xbdbdbd;
        var SecondColorSelected = 0xbdbdbd;
        var DisabledColor = 0x5e5e5e;

        var BackgroundColor = 0x383838;
        var LineSeparatorColor = 0x667cff;
        var LineBitmap = null;

        var ListBackground = 0x383838;

        var SelectedItemBackground = 0x595959;

        var ScrollbarBackground = 0x525252;
        var ScrollbarThumbColor = 0x999999;
        var ScrollbarThumbBorder = 0xdcdcdc;

        var ButtonColor = 0xd7d7d7;
        var ButtonBorder = 0x6b6b6b;
        var ButtonBackground = 0x000055;

        var DarkTheme = true;
        var InvertSelectedItemIcon = false;

        protected var _icon as Listitems.ViewItemIcon? = null;
        protected var _iconDone as Listitems.ViewItemIcon? = null;
        protected var _iconInvert as Listitems.ViewItemIcon? = null;
        protected var _iconDoneInvert as Listitems.ViewItemIcon? = null;

        function getItemIcon(done as Lang.Boolean) as Listitems.ViewItemIcon {
            if (done) {
                if (self._iconDone == null) {
                    self._iconDone = self.DarkTheme ? Application.loadResource(Rez.Drawables.ItemDone) : Application.loadResource(Rez.Drawables.bItemDone);
                }
                return self._iconDone;
            } else {
                if (self._icon == null) {
                    self._icon = self.DarkTheme ? Application.loadResource(Rez.Drawables.Item) : Application.loadResource(Rez.Drawables.bItem);
                }
                return self._icon;
            }
        }

        function getItemIconInvert(done as Lang.Boolean) as Listitems.ViewItemIcon? {
            if (self.InvertSelectedItemIcon) {
                if (done) {
                    if (self._iconDoneInvert == null) {
                        self._iconDoneInvert = self.DarkTheme ? Application.loadResource(Rez.Drawables.bItemDone) : Application.loadResource(Rez.Drawables.ItemDone);
                    }
                    return self._iconDoneInvert;
                } else {
                    if (self._iconInvert == null) {
                        self._iconInvert = self.DarkTheme ? Application.loadResource(Rez.Drawables.bItem) : Application.loadResource(Rez.Drawables.Item);
                    }
                    return self._iconInvert;
                }
            }
            return null;
        }
    }
}
