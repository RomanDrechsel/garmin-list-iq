using Rez;
using Toybox.Application;
module Themes {
    class Grey extends ThemeSettingsBase {
        function initialize() {
            var pre_0xbdbdbd, pre_0x555555, pre_0xffffff;
            pre_0xffffff = 16777215;
            self.LineBitmap = Application.loadResource(Rez.Drawables.LineBlue);

            if (ThemesLoader.LowColors()) {
                pre_0xbdbdbd /*>pre_0xaaaaaa<*/ = 0xaaaaaa;
                pre_0x555555 = 0x555555;
                self.MainColor = pre_0xffffff;
                self.MainColorSelected = pre_0xffffff;
                self.SecondColor = pre_0xbdbdbd /*>pre_0xaaaaaa<*/;
                self.SecondColorSelected = pre_0x555555;
                self.DisabledColor = pre_0xbdbdbd /*>pre_0xaaaaaa<*/;
                self.DisabledColorSelected = pre_0x555555;

                self.BackgroundColor = pre_0x555555;
                self.SelectedItemBackground = pre_0xbdbdbd /*>pre_0xaaaaaa<*/;
                self.LineSeparatorColor = 0x0055ff;
                self.TitleSeparatorColor = pre_0xffffff;

                self.ScrollbarBackground = pre_0xbdbdbd /*>pre_0xaaaaaa<*/;
                self.ScrollbarThumbColor = pre_0x555555;
                self.ScrollbarThumbBorder = pre_0xffffff;

                self.ButtonColor = pre_0xffffff;
                self.ButtonBorder = 0x0000ff;
                self.ButtonBackground = 0x0055aa;
            } else {
                pre_0xbdbdbd = 12434877;
                self.MainColor = 0xd7d7d7;
                self.MainColorSelected = 14145495;
                self.SecondColor = pre_0xbdbdbd;
                self.SecondColorSelected = pre_0xbdbdbd;
                self.DisabledColor = 0x808080;
                self.DisabledColorSelected = pre_0xbdbdbd;

                self.BackgroundColor = 0x383838;
                self.SelectedItemBackground = 0x4f4f4f;
                self.LineSeparatorColor = 0x667cff;
                self.TitleSeparatorColor = pre_0xbdbdbd;

                self.ScrollbarBackground = 0x808080;
                self.ScrollbarThumbColor = 0x999999;
                self.ScrollbarThumbBorder = 0xdcdcdc;

                self.ButtonColor = pre_0xffffff;
                self.ButtonBorder = 0x0000ff;
                self.ButtonBackground = 0x0077ff;
            }
            self.InvertSelectedItemIcon = false;
        }
    }
}
