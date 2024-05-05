module Themes
{
    class Red extends ThemeSettingsBase
    {
        function initialize()
        {
            self.LineBitmap = Application.loadResource(Rez.Drawables.LineRed);

            self.MainColor = 0xff2121;
            self.SecondColor = 0xd90404;
            self.DisabledColor = 0x8f5050;

            self.ListBackground = 0x280000;
            self.BackgroundColor = 0x590202;

            self.LineSeparatorColor = 0xe61b1b;

            self.ScrollbarBackground = 0x4a0000;
            self.ScrollbarThumbColor = 0x610000;
            self.ScrollbarThumbBorder = 0xa60000;

            self.ButtonBorder = 0xe61b1b;
            self.ButtonBackground = 0x420000;
        }
    }
}