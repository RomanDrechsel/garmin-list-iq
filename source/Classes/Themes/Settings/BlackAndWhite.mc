module Themes {
    class BlackAndWhite extends ThemeSettingsBase {
        function initialize() {
            self.LineBitmap = Application.loadResource(Rez.Drawables.LineWhite);

            self.MainColor = 0xffffff;
            self.SecondColor = 0xffffff;
            self.DisabledColor = 0x5e5e5e;

            self.BackgroundColor = 0;
            self.LineSeparatorColor = 0xffffff;

            self.ListBackground = 0;

            self.ScrollbarBackground = 0x525252;
            self.ScrollbarThumbColor = 0x999999;
            self.ScrollbarThumbBorder = 0xdcdcdc;

            self.ButtonBorder = 0xffffff;
            self.ButtonBackground = 0;
        }
    }
}
