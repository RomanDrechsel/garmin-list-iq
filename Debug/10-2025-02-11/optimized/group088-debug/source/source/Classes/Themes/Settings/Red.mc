using Rez;
using Toybox.Application;
module Themes {
    class Red extends ThemeSettingsBase {
        function initialize() {
            var pre_0xff0055, pre_0xff0000;
            self.LineBitmap = Application.loadResource(Rez.Drawables.LineRed);

            if (ThemesLoader.LowColors()) {
                pre_0xff0055 = 0xff0055;
                pre_0xff0000 = 0xff0000;
                self.MainColor = pre_0xff0000;
                self.MainColorSelected = pre_0xff0000;
                self.SecondColor = pre_0xff0055;
                self.SecondColorSelected = pre_0xff0055;
                self.DisabledColor = 0xff5555;

                self.BackgroundColor = 0x000000;
                self.SelectedItemBackground = 0xaaaaaa;
                self.LineSeparatorColor = pre_0xff0000;
                self.TitleSeparatorColor = pre_0xff0000;

                self.ScrollbarBackground = 0xaa5555;
                self.ScrollbarThumbColor = 0x550000;
                self.ScrollbarThumbBorder = pre_0xff0055;

                self.ButtonColor = 0x550000;
                self.ButtonBorder = pre_0xff0000;
                self.ButtonBackground = 0xffaaaa;
            } else {
                pre_0xff0055 /*>pre_0xff2121<*/ = 16720161;
                self.MainColor = pre_0xff0055 /*>pre_0xff2121<*/;
                self.MainColorSelected = 0x750707;
                self.SecondColor = 0xd90404;
                self.SecondColorSelected = 0xb50303;
                self.DisabledColor = 0x8f2f2f;
                self.DisabledColorSelected = 9383727;

                self.BackgroundColor = 0x590202;
                self.SelectedItemBackground = 0xe36666;
                self.LineSeparatorColor = 0xe61b1b;
                self.TitleSeparatorColor = pre_0xff0055 /*>pre_0xff2121<*/;

                self.ScrollbarBackground = 0x4a0000;
                self.ScrollbarThumbColor = 0x610000;
                self.ScrollbarThumbBorder = 0xa60000;

                self.ButtonColor = pre_0xff0055 /*>pre_0xff2121<*/;
                self.ButtonBorder = 0xe61b1b;
                self.ButtonBackground = 0x420000;
            }
        }
    }
}
