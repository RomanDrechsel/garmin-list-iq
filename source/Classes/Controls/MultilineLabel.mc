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
        private static const linewrappers = ['-'] as Array<Char>;

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
                if (self._maxHeight != null) {
                    while (self._height > self._maxHeight) {
                        self._height -= Graphics.getFontAscent(self._font);
                    }
                }

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
                text += self._lines[i];
                if (i < self._lines.size() - 1) {
                    text += "\n";
                }
            }

            return text;
        }

        function getText() as String or Array<String> or Null {
            return self._lines;
        }

        function SetMaxHeight(height as Number) as Void {
            self._maxHeight = height;
        }

        function wrapText(dc as Dc, fulltext as String) as Array<String> {
            var ret = [] as Array<String>;
            var _lines = Helper.StringUtil.splitLines(fulltext);
            for (var j = 0; j < _lines.size(); j++) {
                if (dc.getTextWidthInPixels(_lines[j], self._font) <= self._maxWidth) {
                    ret.add(Helper.StringUtil.cleanString(_lines[j]));
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
                if (self._lines instanceof Array == false) {
                    if (self._lines instanceof Lang.String) {
                        self._lines = self.wrapText(dc, self._lines);
                    } else {
                        self._lines = self.wrapText(dc, self.getFullText());
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
            while (dc.getTextWidthInPixels(text, font) + add > max_width) {
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
