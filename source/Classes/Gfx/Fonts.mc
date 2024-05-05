import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application;

module Gfx
{
    enum FontType { FONT_ICON, FONT_NORMAL, FONT_SMALL, FONT_LARGE }

    class Fonts
    {
        private static var _fonts as Dictionary<FontType, FontResource> = {};

        static function get(font as FontType) as FontResource
        {
            if (!self._fonts.hasKey(font))
            {
                switch (font)
                {
                    case FONT_ICON:
                        self._fonts.put(font, Application.loadResource(Rez.Fonts.Icons) as FontResource);
                        break;
                    case FONT_NORMAL:
                        self._fonts.put(font, Application.loadResource(Rez.Fonts.Normal) as FontResource);
                        break;
                    case FONT_SMALL:
                        self._fonts.put(font, Application.loadResource(Rez.Fonts.Small) as FontResource);
                        break;
                    case FONT_LARGE:
                        self._fonts.put(font, Application.loadResource(Rez.Fonts.Large) as FontResource);
                        break;
                }
            }

            return self._fonts.get(font);
        }

        static function remove(font as FontType) as Void
        {
            self._fonts.remove(font);
        }
    }
}

