using Rez;
using Toybox.Application;
module Themes {
    class WhiteAndBlack extends ThemeSettingsBase {
        function initialize() {
            var pre_0x000000, pre_0xffffff;
            pre_0xffffff = 0xffffff;
            pre_0x000000 = 0x000000;
            self.LineBitmap = Application.loadResource(Rez.Drawables.LineBlack);

            self.MainColor = pre_0x000000;
            self.MainColorSelected = pre_0xffffff;
            self.SecondColor = pre_0x000000;
            self.SecondColorSelected = pre_0xffffff;
            self.DisabledColor = pre_0x000000;
            self.DisabledColorSelected = pre_0xffffff;

            self.LineSeparatorColor = pre_0x000000;
            self.SelectedItemBackground = pre_0x000000;
            self.BackgroundColor = pre_0xffffff;
            self.TitleSeparatorColor = pre_0x000000;

            self.ScrollbarBackground = 0x555555;
            self.ScrollbarThumbColor = 0x555555;
            self.ScrollbarThumbBorder = 0xaaaaaa;

            self.ButtonColor = pre_0xffffff;
            self.ButtonBorder = pre_0x000000;
            self.ButtonBackground = pre_0x000000;

            self.DarkTheme = false;
            self.InvertSelectedItemIcon = true;
        }
    }
}
