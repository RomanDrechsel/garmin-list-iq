import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;

module Helper {
    class FontsService {
        private var _fontLarge as FontType;
        private var _fontNormal as FontType;
        private var _fontSmall as FontType;
        private var _fontIcons = null as FontType;

        function initialize() {
            self._fontLarge = Graphics.FONT_SMALL;
            self._fontNormal = Graphics.FONT_TINY;
            self._fontSmall = Graphics.FONT_XTINY;
        }

        function Large() {
            return self._fontLarge;
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
}

var Fonts = new Helper.FontsService();
