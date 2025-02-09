using Rez;
using Toybox.Application;
module Themes {
    class BlackAndWhite extends ThemeSettingsBase {
        function initialize() {
            var pre_0x000000, pre_0xffffff;
            pre_0xffffff = 0xffffff;
            pre_0x000000 = 0;
            self.LineBitmap = Application.loadResource(Rez.Drawables.LineWhite);

            self.MainColor = pre_0xffffff;
            self.MainColorSelected = pre_0x000000;
            self.SecondColor = pre_0xffffff;
            self.SecondColorSelected = pre_0x000000;
            self.DisabledColor = 0x555555;

            self.LineSeparatorColor = pre_0xffffff;
            self.SelectedItemBackground = pre_0xffffff;
            self.BackgroundColor = pre_0x000000;
            self.TitleSeparatorColor = pre_0xffffff;

            self.ScrollbarBackground = 0xaaaaaa;
            self.ScrollbarThumbColor = 0x555555;
            self.ScrollbarThumbBorder = pre_0xffffff;

            self.ButtonColor = pre_0xffffff;
            self.ButtonBorder = pre_0xffffff;
            self.ButtonBackground = pre_0x000000;

            self.InvertSelectedItemIcon = true;
        }
    }
}
