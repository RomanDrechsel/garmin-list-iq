module Themes {
    class WhiteAndBlack extends ThemeSettingsBase {
        function initialize() {
            self.LineBitmap = Application.loadResource(Rez.Drawables.LineBlack);

            self.MainColor = 0x000000;
            self.SecondColor = 0x000000;
            self.DisabledColor = 0x5e5e5e;

            self.BackgroundColor = 0xffffff;
            self.LineSeparatorColor = 0x000000;

            self.ListBackground = 0xffffff;

            self.ScrollbarBackground = 0x525252;
            self.ScrollbarThumbColor = 0x737373;
            self.ScrollbarThumbBorder = 0xbfbfbf;

            self.ButtonBorder = 0x000000;
            self.ButtonBackground = 0xe6e6e6;

            self.DarkTheme = false;
        }
    }
}
