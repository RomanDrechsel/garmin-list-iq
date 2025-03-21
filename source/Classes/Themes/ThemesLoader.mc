import Toybox.Lang;
import Toybox.Application;

module Themes {
    var CurrentTheme = null;

    class ThemesLoader {
        static var _lowColors as Boolean? = null;

        static function loadTheme() as Void {
            switch (Helper.Properties.Get(Helper.Properties.THEME, 0)) {
                default:
                case 0:
                    CurrentTheme = new Grey();
                    break;
                case 1:
                    CurrentTheme = new Red();
                    break;
                case 2:
                    CurrentTheme = new BlackAndWhite();
                    break;
                case 3:
                    CurrentTheme = new WhiteAndBlack();
                    break;
                case 666:
                    CurrentTheme = new BSoD();
                    break;
            }
        }
    }
}

(:glance)
function getTheme() as Themes.ThemeSettingsBase {
    if ($.getApp().isGlanceView) {
        return new Themes.ThemeSettingsBase();
    }

    if (Themes.CurrentTheme == null) {
        Themes.ThemesLoader.loadTheme();
    }
    return Themes.CurrentTheme;
}
