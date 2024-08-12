import Toybox.Lang;
import Toybox.Graphics;

module Controls {
    class MultilineLabel {
        private var _lines as Array<String> or String or Null = null;
        private var _maxWidth as Number;
        private var _font as FontType;
        private var _height as Number = -1;
        private var _needValidation = true;

        private static const linewrappers = ['-'] as Array<Char>;

        function initialize(text as String, _maxWidth as Number, font as FontType) {
            self._maxWidth = _maxWidth;
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
                dc.drawText(xdraw, y, self._font, self._lines[i], justification);
                y += Graphics.getFontAscent(self._font);
            }

            y += Graphics.getFontDescent(self._font);

            self._height = y - topY;
            return self._height;
        }

        function getHeight(dc as Dc?) as Number {
            if (self._lines instanceof Lang.String) {
                self._lines = self.wrapText(dc, self._lines);
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
                self._height += Graphics.getFontDescent(self._font);
            }
            return self._height;
        }

        function getFullText() as String {
            if (self._lines instanceof String) {
                return self._lines;
            }

            var text = "";
            for (var i = 0; i < self._lines.size(); i++) {
                text += self._lines[i] + "\n";
            }

            return text;
        }

        function wrapText(dc as Dc, fulltext as String) as Array<String> {
            var ret = [] as Array<String>;
            var _lines = Helper.StringUtil.splitLines(fulltext);
            for (var j = 0; j < _lines.size(); j++) {
                if (dc.getTextWidthInPixels(_lines[j], self._font) <= self._maxWidth) {
                    ret.add(_lines[j]);
                    continue;
                }
                var parts = Helper.StringUtil.split(_lines[j], self.linewrappers);
                var curr_line = "" as String;
                var curr_line_width = 0;
                for (var i = 0; i < parts.size(); i++) {
                    var str = parts[i] as String;
                    var part_width = dc.getTextWidthInPixels(str, self._font) as Number;

                    if (curr_line.length() == 0) {
                        //no white-spaces at line start ...
                        if (Helper.StringUtil.isWhitespace(str)) {
                            continue;
                        }

                        curr_line = str;
                        curr_line_width = part_width;
                    } else {
                        if (curr_line_width + part_width < self._maxWidth) {
                            //line-break not reached,
                            curr_line += str;
                            curr_line_width += part_width;
                        } else {
                            //line-break
                            curr_line = Helper.StringUtil.trim(curr_line);
                            if (curr_line.length() > 0) {
                                ret.add(curr_line);
                            }
                            if (Helper.StringUtil.isWhitespace(str)) {
                                curr_line = "";
                                curr_line_width = 0;
                            } else {
                                curr_line = str;
                                curr_line_width = part_width;
                            }
                        }
                    }
                }
                if (curr_line.length() > 0) {
                    ret.add(curr_line);
                }
            }

            return ret;
        }

        function Invalidate(maxwidth as Number) {
            if (maxwidth != self._maxWidth) {
                self._maxWidth = maxwidth;
                self._needValidation = true;
            }
        }

        private function validate(dc as Dc) {
            if (self._needValidation == true) {
                if (self._lines instanceof Lang.String) {
                    self._lines = self.wrapText(dc, self._lines);
                } else {
                    self._lines = self.wrapText(dc, self.getFullText());
                    self._height = -1;
                }

                self._needValidation = false;
            }
        }
    }
}
