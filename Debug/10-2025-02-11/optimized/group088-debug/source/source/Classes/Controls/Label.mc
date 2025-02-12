using Helper;
import Toybox.Graphics;
import Toybox.Lang;

(:glance)
module Controls {
    class Label {
        private var _height = -1;
        private var _width as Number;
        private var _needValidation = true;
        private var _text as String;
        private var _font as FontType;
        private var _maxHeight = 9999;

        function initialize(text as String or Array<String>, font as FontType, width as Number) {
            self._width = width;
            self._font = font;
            if (text instanceof Array) {
                text = Helper.StringUtil.join(text, "\n");
            }
            self._text = text;
        }

        function draw(dc as Dc, x as Number, topY as Number, color as Number, justification as TextJustification) as Number {
            var pre__width;
            pre__width = self._width;
            self.validate(dc);

            if (justification == 1) {
                x += (pre__width / 2).toNumber();
            } else if (justification == 0) {
                x += pre__width;
            }

            dc.setColor(color, -1 as Toybox.Graphics.ColorValue);
            dc.drawText(x, topY, self._font, self._text, justification);
            return self._height;
        }

        function SetMaxHeight(maxHeight as Number) as Void {
            self._maxHeight = maxHeight;
            self._needValidation = true;
        }

        function getFont() as FontType {
            return self._font;
        }

        function getHeight(dc as Dc) as Number {
            self.validate(dc);
            return self._height;
        }

        function validate(dc as Dc) as Void {
            if (self._needValidation) {
                if (self._text.length() > 0) {
                    self._text = Graphics.fitTextToArea(self._text, self._font, self._width, self._maxHeight, true);
                    self._height = dc.getTextDimensions(self._text, self._font)[1];
                } else {
                    self._height = 0;
                }
                self._needValidation = false;
            }
        }
    }
}
