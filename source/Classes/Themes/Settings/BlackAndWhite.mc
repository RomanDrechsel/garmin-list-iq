module Themes {
    class BlackAndWhite extends ThemeSettingsBase {
        function initialize() {
            self.LineBitmap = Application.loadResource(Rez.Drawables.LineWhite);

            self.MainColor = 0xffffff;
            self.MainColorSelected = 0x000000;
            self.SecondColor = self.MainColor;
            self.SecondColorSelected = self.MainColorSelected;
            self.DisabledColor = 0x555555;

            self.BackgroundColor = 0x000000;
            self.LineSeparatorColor = self.MainColor;
            self.SelectedItemBackground = 0xffffff;
            self.ListBackground = self.BackgroundColor;

            self.ScrollbarBackground = 0xaaaaaa;
            self.ScrollbarThumbColor = 0x555555;
            self.ScrollbarThumbBorder = 0xffffff;

            self.ButtonColor = self.MainColor;
            self.ButtonBorder = 0xffffff;
            self.ButtonBackground = 0;

            self.InvertSelectedItemIcon = true;
        }
    }
}
