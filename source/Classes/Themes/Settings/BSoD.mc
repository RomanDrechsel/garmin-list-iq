module Themes
{
    class BSoD extends ThemeSettingsBase
    {
        function initialize()
        {
            self.LineBitmap = Application.loadResource(Rez.Drawables.LineWhite);

            self.MainColor = 0xffffff;
            self.SecondColor = 0xffffff;
            self.DisabledColor = 0x707070;

            self.BackgroundColor = 0x0827F5;
            self.LineSeparatorColor = 0xffffff;

            self.ListBackground = 0x0827F5;
            self.LineSeparatorColor = 0xffffff;

            self.ScrollbarBackground = 0xffffff;
            self.ScrollbarThumbColor = 0xffffff;
            self.ScrollbarThumbBorder = 0x5e5e5e;

            self.ButtonBorder = 0xffffff;
            self.ButtonBackground = 0x0827F5;
        }
    }
}