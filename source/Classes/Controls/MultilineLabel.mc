import Toybox.Lang;
import Toybox.Graphics;

module Controls {
    class MultilineLabel {
        private var _lines as Array<String> or String or Null = null;
        private var _maxWidth as Number;
        private var _font as FontDefinition;
        private var _height = -1;

        private static const linewrappers = ['-'] as Array<Char>;

        var Justification = Graphics.TEXT_JUSTIFY_LEFT;

        function initialize(text as String, _maxWidth as Number, font as FontDefinition) {
            self._maxWidth = _maxWidth;
            self._font = font;
            self._lines = text;
        }

        function drawText(dc as Dc, x as Number, topY as Number, color as Number) as Number {
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);

            if (self._lines instanceof Lang.String) {
                self._lines = self.wrapText(dc, self._lines);
            }

            var y = topY;
            for (var i = 0; i < self._lines.size(); i++) {
                var xdraw = x;
                if (self.Justification == Graphics.TEXT_JUSTIFY_CENTER) {
                    xdraw += self._maxWidth / 2;
                } else if (self.Justification == Graphics.TEXT_JUSTIFY_RIGHT) {
                    xdraw += self._maxWidth;
                }
                dc.drawText(xdraw, y, self._font, self._lines[i], self.Justification);
                y += Graphics.getFontAscent(self._font);
            }

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
                self._height = Graphics.getFontAscent(self._font) * self._lines.size();
            }

            return self._height;
        }

        function getFullText() as String {
            var text = "";
            for (var i = 0; i < self._lines.size(); i++) {
                text += self._lines[i];
            }

            return text;
        }

        private function wrapText(dc as Dc, fulltext as String) as Array<String> {
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
                            ret.add(curr_line);
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
                ret.add(curr_line);
            }

            return ret;
        }
    }
}
