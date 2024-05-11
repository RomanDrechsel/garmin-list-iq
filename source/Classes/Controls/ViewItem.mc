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

        protected static var _horizonalPaddingFactor = 0.05;
        protected static var _iconPaddingFactor = 0.4;

        private var _fontOverride = null;
        private var _needValidation as Boolean = true;
        protected var _verticalPadding = 0;
        protected var _horizontalPadding = 0;
        protected var _Icon as String or ViewItemIcon or Null = null;
        protected var _listY as Number? = null;
        protected var _Height as Number? = null;
        protected var _isVisible = false;
        protected var _Layer as LayerDef? = null;
        protected var _textOffsetX as Number = 0;

        function initialize(layer as LayerDef, title as String?, subtitle as String?, obj as Object?, icon as Number or BitmapResource or Null, vert_padding as Number, position as Number, fontoverride as FontResource?) {
            self._fontOverride = fontoverride;

            self.ItemPosition = position;
            self._Layer = layer;
            self._verticalPadding = vert_padding;
            self._horizontalPadding = layer.getWidth() * 0.05;
            self.Title = title;
            self.Subtitle = subtitle;
            self.BoundObject = obj;
            self.setIcon(icon);
            self._needValidation = true;
        }

        /** return y-coordinate of the bottom */
        function draw(dc as Dc, yOffset as Number, drawline as Boolean) {
            self.validate(dc);
            self.calcVisible(dc, yOffset);

            if (self._isVisible == false) {
                Log("Item: " + self.ItemPosition + " is not visible");
                return self.getHeight(dc);
            }

            var viewport_y = self._listY - yOffset;

            var mainfont = self._fontOverride != null ? self._fontOverride : Fonts.Normal();
            var hor_padding = self._Layer.getWidth() * self._horizonalPaddingFactor;

            /*Log("Item: " + self.Title.getFullText());
            Log("ListY: " + self._listY);
            Log("Offset: " + yOffset);
            Log("ViewPort: " + viewport_y);
            Log("-----");*/
            if (self._Icon instanceof String && self._Icon.length() > 0) {
                var iconoffsety = (Graphics.getFontHeight(mainfont) - dc.getFontHeight(Fonts.Icons())) / 2;
                dc.setColor(getTheme().MainColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(self._Layer.getX() + hor_padding, viewport_y + iconoffsety, Fonts.Icons(), self._Icon, Graphics.TEXT_JUSTIFY_LEFT);
            } else if (self._Icon != null) {
                var offsety = (Graphics.getFontHeight(mainfont) - self._Icon.getHeight()) / 2;
                dc.drawBitmap(self._Layer.getX() + hor_padding, viewport_y + offsety, self._Icon);
            }
            var x = self._Layer.getX() + hor_padding + self.getIconWidth(dc);

            if (self.Title instanceof MultilineLabel) {
                viewport_y += self.Title.drawText(dc, x, viewport_y, self.ColorOverride != null ? self.ColorOverride : getTheme().MainColor);
            }

            if (self.Subtitle instanceof MultilineLabel) {
                viewport_y += Graphics.getFontAscent(Fonts.Small()) / 3; //little space between title and subtitle
                viewport_y += self.Subtitle.drawText(dc, self._Layer.getX() + hor_padding, viewport_y, self.ColorOverride != null ? self.ColorOverride : getTheme().SecondColor);
                viewport_y += 12; //space between subtitle and lower line
            } else {
                viewport_y += 5;
            }

            viewport_y += self._verticalPadding;
            if (drawline) {
                viewport_y = self.drawLine(dc, viewport_y);
            }
            return self._Height;
        }

        function setListY(y as Number) {
            self._listY = y;
        }

        function getListY() as Number {
            return self._listY != null ? self._listY : 0;
        }

        protected function calcVisible(dc as Dc, yOffset as Number) as Boolean {
            var height = self.getHeight(dc);
            if (self._listY + height < yOffset) {
                //above the top
                self._isVisible = false;
            } else if (self._listY > yOffset + self._Layer.getHeight()) {
                //below the bottom
                self._isVisible = false;
            } else {
                self._isVisible = true;
            }

            /*Log(self.Title.getFullText());
            Log("Height: " + height);
            Log("Offset: " + yOffset);
            Log("ListY: " + self._listY);
            Log("IsVisible: " + self._isVisible);
            Log("-----");*/

            return self._isVisible;
        }

        function getHeight(dc as Dc?) as Number {
            if (dc != null) {
                self.validate(dc);
                if (self._Height == null || self._Height < 0) {
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
            } else if (self._Height != null && self._Height >= 0) {
                return self._Height;
            } else {
                return 0;
            }
        }

        function setIcon(icon as Number or BitmapResource or Graphics.BitmapReference or Null) as Void {
            if (icon instanceof Number && icon >= 0) {
                self._Icon = icon.toChar().toString();
            } else {
                self._Icon = icon;
            }
        }

        function Clicked(tapy as Number) as Boolean {
            if (self._isVisible == false) {
                //not visible, null or negative height
                return false;
            }

            if (tapy >= self._listY && tapy <= self._listY + self._Height) {
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

        protected function validate(dc as Dc) {
            if (self._needValidation == true) {
                var padding = self._Layer.getWidth() * self._horizonalPaddingFactor;
                var title = self.Title instanceof MultilineLabel ? self.Title.getFullText() : self.Title;
                var subtitle = self.Subtitle instanceof MultilineLabel ? self.Subtitle.getFullText() : self.Subtitle;

                if (title != null && title.length() > 0) {
                    var width = self._Layer.getWidth() - 2 * padding - self.getIconWidth(dc);
                    self.Title = new MultilineLabel(title, width, self._fontOverride != null ? self._fontOverride : Fonts.Normal());
                }

                if (subtitle != null && subtitle.length() > 0) {
                    self.Subtitle = new MultilineLabel(subtitle, self._Layer.getWidth() - 2 * padding, Fonts.Small());
                }
                self._needValidation = false;
            }
        }

        private function getIconWidth(dc as Dc) as Number {
            var iconwidth;
            if (self._Icon instanceof String && self._Icon.length() > 0) {
                iconwidth = dc.getTextWidthInPixels(self._Icon, Fonts.Icons());
            } else if (self._Icon != null) {
                iconwidth = self._Icon.getWidth();
            } else {
                iconwidth = 0;
            }

            return iconwidth + iconwidth * self._iconPaddingFactor;
        }
    }
}
