module Themes {
    class WhiteAndBlack extends ThemeSettingsBase {
        function initialize() {
            self.LineBitmap = Application.loadResource(Rez.Drawables.LineBlack);

            self.MainColor = 0x000000;
            self.MainColorSelected = 0xffffff;
            self.SecondColor = self.MainColor;
            self.SecondColorSelected = self.MainColorSelected;
            self.DisabledColor = self.MainColor;
            self.DisabledColorSelected = self.MainColorSelected;

            self.LineSeparatorColor = 0x000000;
            self.SelectedItemBackground = 0x00000;
            self.BackgroundColor = 0xffffff;
            self.TitleSeparatorColor = self.MainColor;

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
