import Toybox.Lang;
import Toybox.Application;

module Themes
{
    var CurrentTheme = null;

    class ThemesLoader
    {
        static function loadTheme() as Void
        {
            var theme = Application.Properties.getValue("Th") as Number;
            switch (theme)
            {
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

            if (CurrentTheme == null)
            {
                CurrentTheme = new ThemeSettingsBase();
            }
        }
    }
}

function getTheme() as Themes.ThemeSettingsBase
{
    if (Themes.CurrentTheme == null)
    {
        Themes.ThemesLoader.loadTheme();
    }
    return Themes.CurrentTheme;
}