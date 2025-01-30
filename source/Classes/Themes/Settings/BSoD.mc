module Themes {
    class BSoD extends ThemeSettingsBase {
        function initialize() {
            self.LineBitmap = Application.loadResource(Rez.Drawables.LineWhite);

            self.MainColor = 0xffffff;
            self.MainColorSelected = 0x0827f5;
            self.SecondColor = self.MainColor;
            self.SecondColorSelected = self.MainColorSelected;
            self.DisabledColor = self.MainColor;
            self.DisabledColorSelected = self.MainColorSelected;

            self.LineSeparatorColor = self.MainColor;
            self.SelectedItemBackground = self.MainColor;
            self.BackgroundColor = 0x0827f5;
            self.TitleSeparatorColor = self.MainColor;

            self.ScrollbarBackground = self.MainColor;
            self.ScrollbarThumbColor = self.MainColor;
            self.ScrollbarThumbBorder = 0x5e5e5e;

            self.ButtonColor = self.MainColor;
            self.ButtonBorder = self.MainColor;
            self.ButtonBackground = self.MainColorSelected;
            self.InvertSelectedItemIcon = true;
        }
    }
}
