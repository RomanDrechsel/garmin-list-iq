module Themes {
    class Grey extends ThemeSettingsBase {
        function initialize() {
            self.LineBitmap = Application.loadResource(Rez.Drawables.LineBlue);

            if (ThemesLoader.LowColors()) {
                self.MainColor = 0xffffff;
                self.MainColorSelected = self.MainColor;
                self.SecondColor = 0xaaaaaa;
                self.SecondColorSelected = 0x555555;
                self.DisabledColor = self.SecondColor;
                self.DisabledColorSelected = self.SecondColorSelected;

                self.BackgroundColor = 0x555555;
                self.SelectedItemBackground = 0xaaaaaa;
                self.LineSeparatorColor = 0x0055ff;
                self.TitleSeparatorColor = self.MainColor;

                self.ScrollbarBackground = 0xaaaaaa;
                self.ScrollbarThumbColor = 0x555555;
                self.ScrollbarThumbBorder = 0xffffff;

                self.ButtonColor = self.MainColor;
                self.ButtonBorder = 0x0000ff;
                self.ButtonBackground = 0x0055aa;
            } else {
                self.MainColor = 0xd7d7d7;
                self.MainColorSelected = self.MainColor;
                self.SecondColor = 0xbdbdbd;
                self.SecondColorSelected = self.SecondColor;
                self.DisabledColor = 0x808080;
                self.DisabledColorSelected = self.SecondColorSelected;

                self.BackgroundColor = 0x383838;
                self.SelectedItemBackground = 0x4f4f4f;
                self.LineSeparatorColor = 0x667cff;
                self.TitleSeparatorColor = self.SecondColor;

                self.ScrollbarBackground = 0x808080;
                self.ScrollbarThumbColor = 0x999999;
                self.ScrollbarThumbBorder = 0xdcdcdc;

                self.ButtonColor = 0xffffff;
                self.ButtonBorder = 0x0000ff;
                self.ButtonBackground = 0x0077ff;
            }
            self.InvertSelectedItemIcon = false;
        }
    }
}
