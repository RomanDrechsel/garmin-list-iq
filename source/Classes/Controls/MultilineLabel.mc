import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

module Controls {
    (:glance)
    class MultilineLabel {
        private var _lines as Array<String> or String or Null = null;
        private var _maxWidth as Number;
        private var _font as FontType;
        private var _height as Number = -1;
        private var _maxHeight as Number? = null;
        private var _needValidation = true;

        function initialize(text as String or Array<String>, maxWidth as Number, font as FontType) {
            self._maxWidth = maxWidth;
            self._font = font;
            self._lines = text;
        }

        function drawText(dc as Dc, x as Number, topY as Number, color as Number, justification as TextJustification) as Number {
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            self.validate(dc);

            var y = topY;
            for (var i = 0; i < self._lines.size(); i++) {
                var xdraw = x;
                if (justification == Graphics.TEXT_JUSTIFY_CENTER) {
                    xdraw += self._maxWidth / 2;
                } else if (justification == Graphics.TEXT_JUSTIFY_RIGHT) {
                    xdraw += self._maxWidth;
                }

                var line = self._lines[i];
                var ellipsis = " " + (8230).toChar().toString();
                if (self._maxHeight != null && self._maxHeight > 0 && y + Graphics.getFontAscent(self._font) > self._maxHeight) {
                    line = self.abbreviate(dc, line, self._font, ellipsis, self._maxWidth);
                    if (i < self._lines.size() - 1 && line.equals(self._lines[i])) {
                        line += ellipsis;
                    }
                }
                dc.drawText(xdraw, y, self._font, line, justification);
                y += Graphics.getFontAscent(self._font);

                if (self._maxHeight != null && self._maxHeight > 0 && y >= self._maxHeight) {
                    break;
                }
            }

            y += Graphics.getFontDescent(self._font);

            self._height = y - topY;
            return self._height;
        }

        function getHeight(dc as Dc?) as Number {
            if (self._lines instanceof Lang.String) {
                self._lines = Helper.StringUtil.splitToFixedWidth(dc, self._lines, self._maxWidth, self._font);
            } else if (self._lines == null) {
                return 0;
            }

            if (self._height < 0) {
                if (dc != null) {
                    self.validate(dc);
                }
                if (self._lines == null) {
                    return 0;
                }
                self._height = Graphics.getFontAscent(self._font) * self._lines.size();
                if (self._maxHeight != null) {
                    while (self._height > self._maxHeight) {
                        self._height -= Graphics.getFontAscent(self._font);
                    }
                }

                self._height += Graphics.getFontDescent(self._font);
            }
            return self._height;
        }

        function getText() as String or Array<String> or Null {
            return self._lines;
        }

        function SetMaxHeight(height as Number) as Void {
            self._maxHeight = height;
        }

        function Invalidate(maxwidth as Number) {
            if (maxwidth != self._maxWidth) {
                self._maxWidth = maxwidth;
                self._needValidation = true;
            }
        }

        private function validate(dc as Dc) {
            if (self._needValidation == true) {
                if (self._lines instanceof Array == false) {
                    if (self._lines instanceof Lang.String) {
                        self._lines = Helper.StringUtil.splitToFixedWidth(dc, self._lines, self._maxWidth, self._font);
                    } else {
                        self._height = -1;
                    }
                }

                self._needValidation = false;
            }
        }

        private function abbreviate(dc as Dc, text as String, font as FontResource, add as String?, max_width as Number) as String {
            if (dc.getTextWidthInPixels(text, font) < max_width) {
                return text;
            }
            while (dc.getTextWidthInPixels(text + add, font) > max_width) {
                var count = 0;
                for (var i = text.length() - 1; i >= 0; i--) {
                    count--;
                    var index = text.length() - i - 1;
                    if (Helper.StringUtil.isWhitespace(text.substring(index, index + 1)) == true) {
                        break;
                    }
                }

                text = text.substring(0, text.length() - count);
            }

            return text + add;
        }
    }
}
