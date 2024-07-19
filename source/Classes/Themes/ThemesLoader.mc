import Toybox.Lang;
import Toybox.Application;

module Themes {
    var CurrentTheme = null;

    class ThemesLoader {
        static function loadTheme() as Void {
            switch (Helper.Properties.Number(Helper.Properties.THEME, 0)) {
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
                case 666:
                    CurrentTheme = new BSoD();
                    break;
            }
        }
    }
}

function getTheme() as Themes.ThemeSettingsBase {
    if (Themes.CurrentTheme == null) {
        Themes.ThemesLoader.loadTheme();
    }
    return Themes.CurrentTheme;
}
