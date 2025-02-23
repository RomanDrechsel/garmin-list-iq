import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;

(:glance,:background)
module Helper {
    class FontsService {
        private var _fontBig as FontType;
        private var _fontNormal as FontType;
        private var _fontSmall as FontType;
        private var _fontIcons = null as FontType;

        function initialize() {
            self._fontBig = Graphics.FONT_LARGE;
            self._fontNormal = Graphics.FONT_TINY;
            self._fontSmall = Graphics.FONT_XTINY;
        }

        function Big() {
            return self._fontBig;
        }

        function Normal() {
            return self._fontNormal;
        }

        function Small() {
            return self._fontSmall;
        }

        function Icons() {
            if (self._fontIcons == null) {
                self._fontIcons = WatchUi.loadResource(Rez.Fonts.Icons);
            }
            return self._fontIcons;
        }
    }

    var Fonts = new FontsService();
}
