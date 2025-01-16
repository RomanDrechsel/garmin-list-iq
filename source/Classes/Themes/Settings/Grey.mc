module Themes {
    class Grey extends ThemeSettingsBase {
        function initialize() {
            self.LineBitmap = Application.loadResource(Rez.Drawables.LineBlue);

            self.MainColor = 0xffffff;
            self.MainColorSelected = 0xffffff;
            self.SecondColor = 0xaaaaaa;
            self.SecondColorSelected = 0x555555;
            self.DisabledColor = 0xaaaaaa;

            self.ListBackground = 0x555555;
            self.SelectedItemBackground = 0xaaaaaa;
            self.BackgroundColor = 0x555555;
            self.LineSeparatorColor = 0x0055ff;

            self.ScrollbarBackground = 0xaaaaaa;
            self.ScrollbarThumbColor = 0x555555;
            self.ScrollbarThumbBorder = 0xffffff;

            self.ButtonBorder = 0x0055ff;
            self.ButtonBackground = 0x0000aa;
        }
    }
}
