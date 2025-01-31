using Rez;
using Toybox.Application;
module Themes {
    class BSoD extends ThemeSettingsBase {
        function initialize() {
            var pre_0x0827f5, pre_0xffffff;
            pre_0xffffff = 16777215;
            pre_0x0827f5 = 534517;
            self.LineBitmap = Application.loadResource(Rez.Drawables.LineWhite);

            self.MainColor = pre_0xffffff;
            self.MainColorSelected = pre_0x0827f5;
            self.SecondColor = pre_0xffffff;
            self.SecondColorSelected = pre_0x0827f5;
            self.DisabledColor = pre_0xffffff;
            self.DisabledColorSelected = pre_0x0827f5;

            self.LineSeparatorColor = pre_0xffffff;
            self.SelectedItemBackground = pre_0xffffff;
            self.BackgroundColor = pre_0x0827f5;
            self.TitleSeparatorColor = pre_0xffffff;

            self.ScrollbarBackground = pre_0xffffff;
            self.ScrollbarThumbColor = pre_0xffffff;
            self.ScrollbarThumbBorder = 0x5e5e5e;

            self.ButtonColor = pre_0xffffff;
            self.ButtonBorder = pre_0xffffff;
            self.ButtonBackground = pre_0x0827f5;
            self.InvertSelectedItemIcon = true;
        }
    }
}
