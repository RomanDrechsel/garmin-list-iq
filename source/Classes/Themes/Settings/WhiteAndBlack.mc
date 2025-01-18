module Themes {
    class WhiteAndBlack extends ThemeSettingsBase {
        function initialize() {
            self.LineBitmap = Application.loadResource(Rez.Drawables.LineBlack);

            self.MainColor = 0x000000;
            self.MainColorSelected = 0xffffff;
            self.SecondColor = 0x000000;
            self.SecondColorSelected = self.MainColorSelected;
            self.DisabledColor = 0x5e5e5e;

            self.BackgroundColor = 0xffffff;
            self.LineSeparatorColor = 0x000000;
            self.SelectedItemBackground = 0x00000;
            self.ListBackground = self.BackgroundColor;

            self.ScrollbarBackground = 0x555555;
            self.ScrollbarThumbColor = 0x555555;
            self.ScrollbarThumbBorder = 0xaaaaaa;

            self.ButtonColor = 0xffffff;
            self.ButtonBorder = 0x000000;
            self.ButtonBackground = 0x000000;

            self.DarkTheme = false;
            self.InvertSelectedItemIcon = true;
        }
    }
}
