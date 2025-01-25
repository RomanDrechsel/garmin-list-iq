import Toybox.Graphics;
import Toybox.Lang;

module Controls {
    class Label {
        private var _height = -1;
        private var _width as Number;
        private var _needValidation = true;
        private var _text as String;
        private var _font as FontType;

        function initialize(text as String or Array<String>, font as FontType, width as Number) {
            self._width = width;
            self._font = font;
            if (text instanceof Array) {
                text = Helper.StringUtil.join(text, "\n");
            }
            self._text = text;
        }

        function draw(dc as Dc, x as Number, topY as Number, color as Number, justification as TextJustification) as Number {
            if (self._needValidation) {
                self.validate(dc);
            }

            //Debug.Box(dc, x, topY, self._width, self._height, Graphics.COLOR_RED);
            if (justification == Graphics.TEXT_JUSTIFY_CENTER) {
                x += (self._width / 2).toNumber();
            } else if (justification == Graphics.TEXT_JUSTIFY_RIGHT) {
                x += self._width;
            }

            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, topY, self._font, self._text, justification);
            return self._height;
        }

        function getFont() as FontType {
            return self._font;
        }

        function getHeight(dc as Dc) {
            if (self._needValidation) {
                self.validate(dc);
            }
            return self._height;
        }

        function validate(dc as Dc) {
            if (self._text.length() > 0) {
                self._text = Graphics.fitTextToArea(self._text, self._font, self._width, 999999999, false);
                self._height = dc.getTextDimensions(self._text, self._font)[1] + Graphics.getFontDescent(self._font);
            } else {
                self._height = 0;
            }
            self._needValidation = false;
        }
    }
}
