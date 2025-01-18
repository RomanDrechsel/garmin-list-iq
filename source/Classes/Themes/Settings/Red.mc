module Themes {
    class Red extends ThemeSettingsBase {
        function initialize() {
            self.LineBitmap = Application.loadResource(Rez.Drawables.LineRed);

            self.MainColor = 0xff0000;
            self.MainColorSelected = 0xff0000;
            self.SecondColor = 0xff0055;
            self.SecondColorSelected = 0xff0055;
            self.DisabledColor = 0xff5555;

            self.ListBackground = 0x000000;
            self.BackgroundColor = 0x000000;
            self.SelectedItemBackground = 0xaaaaaa;
            self.LineSeparatorColor = 0xff0000;

            self.ScrollbarBackground = 0xaa5555;
            self.ScrollbarThumbColor = 0x550000;
            self.ScrollbarThumbBorder = 0xff0055;

            self.ButtonColor = 0x550000;
            self.ButtonBorder = 0xff0000;
            self.ButtonBackground = 0xffaaaa;
        }
    }
}
