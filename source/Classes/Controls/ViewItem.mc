import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Helper;

module Controls {
    typedef ViewItemIcon as WatchUi.BitmapResource or Graphics.BitmapReference;

    class ViewItem {
        var Title as MultilineLabel? = null;
        var Subtitle as MultilineLabel? = null;
        var BoundObject as Object = null;
        var ItemPosition = -1;
        var ColorOverride = null;

        static var TitlePaddingFactor = 0.01;
        static var SubtitlePaddingFactor = 0.05;
        static var IconPaddingFactor = 0.4;

        private var _fontOverride = null;
        protected var _verticalPadding = 0;
        protected var _Icon as String or ViewItemIcon or Null = null;
        protected var _yTop = -1;
        protected var _Height = -1;
        protected var _Visible = false;
        protected var _Layer as LayerDef = null;
        protected var _textOffsetX as Number = 0;

        function initialize(layer as LayerDef, title as String?, subtitle as String?, obj as Object?, icon as Number or BitmapResource or Null, vert_padding as Number, position as Number, fontoverride as FontResource?) {
            self._fontOverride = fontoverride;

            self.ItemPosition = position;
            self._Layer = layer;
            self._verticalPadding = vert_padding;
            self.Title = title;
            self.Subtitle = subtitle;
            self.BoundObject = obj;
            self.setIcon(icon);

            if (title != null && title.length() > 0) {
                var padding = self._Layer.getWidth() * self.TitlePaddingFactor;
                self.Title = new MultilineLabel(title, self._Layer.getWidth() - 2 * padding, self._fontOverride != null ? self._fontOverride : Fonts.Normal());
            }

            if (subtitle != null && subtitle.length() > 0) {
                var padding = self._Layer.getWidth() * self.SubtitlePaddingFactor;
                self.Subtitle = new MultilineLabel(subtitle, self._Layer.getWidth() - 2 * padding, Fonts.Small());
            }
        }

        function draw(dc as Dc, ytop as Number, drawline as Boolean) as Number {
            var iconwidth;
            var y = ytop + self._verticalPadding;
            var mainfont = self._fontOverride != null ? self._fontOverride : Fonts.Normal();

            if (self._Icon instanceof String && self._Icon.length() > 0) {
                var offsety = (Graphics.getFontHeight(mainfont) - dc.getFontHeight(Fonts.Icons())) / 2;
                iconwidth = dc.getTextWidthInPixels(self._Icon, Fonts.Icons());
                dc.setColor(getTheme().MainColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(iconwidth * self.IconPaddingFactor, y + offsety, Fonts.Icons(), self._Icon, Graphics.TEXT_JUSTIFY_LEFT);
            } else if (self._Icon != null) {
                var offsety = (Graphics.getFontHeight(mainfont) - self._Icon.getHeight()) / 2;
                dc.drawBitmap(self._Icon.getWidth() * self.IconPaddingFactor, y + offsety, self._Icon);
                iconwidth = self._Icon.getWidth();
            } else {
                iconwidth = 0;
            }

            var x = iconwidth + iconwidth * 2 * self.IconPaddingFactor;

            if (self.Title instanceof MultilineLabel) {
                y += self.Title.drawText(dc, x, y, self.ColorOverride != null ? self.ColorOverride : getTheme().MainColor);
            }

            if (self.Subtitle != null) {
                y += Graphics.getFontAscent(Fonts.Small()) / 3; //space between title and subtitle
                y += self.Subtitle.drawText(dc, x, y, self.ColorOverride != null ? self.ColorOverride : getTheme().SecondColor);
                y += 12; //space between subtitle and lower line
            } else {
                y += 5;
            }

            y += self._verticalPadding;
            if (drawline) {
                y = self.drawLine(dc, y);
            }

            self.setBoundaries(ytop, y);
            self._Visible = true;

            //return lower y of lower edge of item
            return y;
        }

        function setBoundaries(top as Number, bottom as Number) {
            self._yTop = top;
            if (bottom > top) {
                self._Height = bottom - top;
            } else if (top == bottom) {
                self._Visible = false;
            }
        }

        function getHeight(dc as Dc) as Number {
            if (self._Height < 0) {
                self._Height = 0;
                if (self.Title != null) {
                    self._Height += self.Title.getHeight(dc);
                }
                if (self.Subtitle != null) {
                    self._Height += Graphics.getFontAscent(Fonts.Small()) / 3;
                    self._Height += self.Subtitle.getHeight(dc);
                    self._Height += 12;
                } else {
                    self._Height += 5;
                }
                self._Height += self._verticalPadding * 2;

                if (getTheme().LineBitmap != null) {
                    self._Height += getTheme().LineBitmap.getHeight();
                } else if (getTheme().LineSeparatorColor != null) {
                    self._Height += 2;
                }
            }

            return self._Height;
        }

        function setIcon(icon as Number or BitmapResource or Graphics.BitmapReference or Null) as Void {
            if (icon instanceof Number && icon >= 0) {
                self._Icon = icon.toChar().toString();
            } else {
                self._Icon = icon;
            }
        }

        function Clicked(tapy as Number) as Boolean {
            if (self._Visible == false) {
                //not visible, null or negative height
                return false;
            }

            if (tapy >= self._yTop && tapy <= self._yTop + self._Height) {
                return true;
            }

            return false;
        }

        protected function drawLine(dc as Dc, y as Number) as Number {
            var line = getTheme().LineBitmap;
            if (line != null) {
                var x = (dc.getWidth() - line.getWidth()) / 2;
                dc.drawBitmap(x, y, line);
                y += line.getHeight();
            } else if (getTheme().LineSeparatorColor != null) {
                dc.setColor(getTheme().LineSeparatorColor, Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(2);
                dc.drawLine(0, y, dc.getWidth(), y);
                y += 2;
            }

            return y;
        }
    }
}
