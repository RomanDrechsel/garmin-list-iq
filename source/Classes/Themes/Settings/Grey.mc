module Themes
{
    class Grey extends ThemeSettingsBase
    {
        function initialize()
        {
            self.LineBitmap = Application.loadResource(Rez.Drawables.LineBlue);

            self.MainColor = 0xd7d7d7;
            self.SecondColor = 0xbdbdbd;
            self.DisabledColor = 0x5e5e5e;

            self.ListBackground = 0x383838;
            self.BackgroundColor = 0x282828;
            self.ButtonBorder = 0x12a1ff;
            self.LineSeparatorColor = 0x667cff;;

            self.ScrollbarBackground = 0x525252;
            self.ScrollbarThumbColor = 0x999999;
            self.ScrollbarThumbBorder = 0xdcdcdc;

            self.ButtonBorder = 0x1255ff;
            self.ButtonBackground = 0x6b6b6b;
        }
    }
}