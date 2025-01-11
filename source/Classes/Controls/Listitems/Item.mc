import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Helper;

module Controls {
    module Listitems {
        typedef ViewItemIcon as WatchUi.BitmapResource or Graphics.BitmapReference;

        class Item {
            var Title as MultilineLabel or String or Array<String> or Null = null;
            var TitleJustification as TextJustification = Graphics.TEXT_JUSTIFY_LEFT;
            var Subtitle as MultilineLabel or String or Array<String> or Null = null;
            var SubtitleJustification as TextJustification = Graphics.TEXT_JUSTIFY_LEFT;
            var BoundObject as Object? = null;
            var ItemPosition as Number = -1;
            var DrawLine as Boolean = true;

            protected static var _horizonalPaddingFactor = 0.05;
            protected static var _iconPaddingFactor = 0.3;

            protected var _needValidation as Boolean = true;
            protected var _font as FontType;
            protected var _color as ColorType;
            protected var _colorSub as ColorType;
            protected var _verticalMargin as Number = 0;
            protected var _icon as String or ViewItemIcon or Null = null;
            protected var _listY as Number? = null;
            protected var _height as Number? = null;
            protected var _viewportY as Number? = null;
            protected var _layer as LayerDef? = null;
            protected var _textOffsetX as Number = 0;

            function initialize(layer as LayerDef?, title as String or Array<String> or Null, subtitle as String or Array<String> or Null, obj as Object?, icon as Number or BitmapResource or Null, vert_margin as Number, position as Number, fontoverride as FontType?) {
                self._font = fontoverride != null ? fontoverride : Helper.Fonts.Normal();
                self._color = getTheme().MainColor;
                self._colorSub = getTheme().SecondColor;
                self.ItemPosition = position;
                self._layer = layer;
                self._verticalMargin = vert_margin;
                self.Title = title;
                self.Subtitle = subtitle;
                self.BoundObject = obj;
                self.setIcon(icon);
                self._needValidation = true;
            }

            /** returns height of the item */
            function draw(dc as Dc, yOffset as Number) as Number {
                if (self._layer == null) {
                    return 0;
                }
                self.validate(dc);
                var viewport_y = self._listY - yOffset + self._layer.getY();
                self._viewportY = viewport_y;
                if (self.isVisible() == false) {
                    return self.getHeight(dc);
                }

                viewport_y += self._verticalMargin;
                var hor_padding = self._layer.getWidth() * self._horizonalPaddingFactor;
                var x = self._layer.getX() + hor_padding;

                if (self._icon instanceof String && self._icon.length() > 0) {
                    var iconoffsety = (Graphics.getFontHeight(self._font) - dc.getFontHeight(Helper.Fonts.Icons())) / 2;
                    dc.setColor(getTheme().MainColor, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(x, viewport_y + iconoffsety, Helper.Fonts.Icons(), self._icon, Graphics.TEXT_JUSTIFY_LEFT);
                } else if (self.isBitmap(self._icon)) {
                    var iconoffsety = (Graphics.getFontHeight(self._font) - self._icon.getHeight()) / 2;
                    dc.drawBitmap(x, viewport_y + iconoffsety, self._icon);
                }

                if (self.Title instanceof MultilineLabel) {
                    viewport_y += self.Title.drawText(dc, x + self.getIconWidth(dc), viewport_y, self._color, self.TitleJustification);
                }

                if (self.Subtitle instanceof MultilineLabel) {
                    viewport_y += Graphics.getFontAscent(Helper.Fonts.Small()) / 8; //little space between title and subtitle
                    viewport_y += self.Subtitle.drawText(dc, x, viewport_y, self._colorSub, self.SubtitleJustification);
                }

                if (self.DrawLine == true) {
                    viewport_y = self.drawLine(dc, viewport_y);
                }

                self._height = viewport_y - self._viewportY;

                return self._height;
            }

            function setListY(y as Number) {
                self._listY = y;
            }

            function getListY() as Number {
                return self._listY != null ? self._listY : 0;
            }

            function setColor(color as ColorType?) {
                self._color = color != null ? color : getTheme().MainColor;
                self._colorSub = color != null ? color : getTheme().SecondColor;
            }

            function getHeight(dc as Dc?) as Number {
                if (dc != null) {
                    self.validate(dc);
                    if (self._height == null || self._height <= 0) {
                        self._height = self._verticalMargin;
                        if (self.Title != null) {
                            self._height += self.Title.getHeight(dc);
                        }
                        if (self.Subtitle != null) {
                            self._height += Graphics.getFontAscent(Helper.Fonts.Small()) / 8;
                            self._height += self.Subtitle.getHeight(dc);
                        }
                        self._height += self.getLineHeight();
                    }
                    return self._height;
                } else if (self._height != null && self._height >= 0) {
                    return self._height;
                } else {
                    return 0;
                }
            }

            function setIcon(icon as Number or ViewItemIcon or Null) {
                if (icon instanceof Number && icon >= 0) {
                    self._icon = icon.toChar().toString();
                } else if (self.isBitmap(icon)) {
                    self._icon = icon;
                }
            }

            function getIcon() as Number or ViewItemIcon or Null {
                return self._icon;
            }

            function Clicked(tapy as Number) as Boolean {
                if (self._viewportY == null || self._height == null || self.isVisible() == false) {
                    //not visible or not validated
                    return false;
                }

                if (tapy >= self._viewportY && tapy <= self._viewportY + self._height) {
                    return true;
                }

                return false;
            }

            function Invalidate() {
                self._needValidation = true;
                self._height = -1;
            }

            function setLayer(layer as LayerDef) {
                self._layer = layer;
            }

            protected function isVisible() as Boolean {
                if (self._viewportY == null || self._height == null) {
                    return true;
                }
                if (self._layer == null) {
                    return false;
                }

                if (self._viewportY + self._height <= 0) {
                    //above the top edge of the display
                    return false;
                } else if (self._viewportY > self._layer.getDc().getHeight()) {
                    //below the bottom edge of the display
                    return false;
                } else {
                    return true;
                }
            }

            protected function drawLine(dc as Dc, y as Number) as Number {
                var line = getTheme().LineBitmap;
                if (line != null) {
                    y += self._verticalMargin;
                    var x = (dc.getWidth() - line.getWidth()) / 2;
                    dc.drawBitmap(x, y, line);
                    y += line.getHeight();
                } else if (getTheme().LineSeparatorColor != null) {
                    y += self._verticalMargin;
                    dc.setColor(getTheme().LineSeparatorColor, Graphics.COLOR_TRANSPARENT);
                    dc.setPenWidth(2);
                    dc.drawLine(0, y, dc.getWidth(), y);
                    y += 2;
                }

                return y;
            }

            protected function getLineHeight() {
                if (self.DrawLine == true) {
                    var line = $.getTheme().LineBitmap;
                    if (line != null) {
                        return line.getHeight() + self._verticalMargin;
                    } else if ($.getTheme().LineSeparatorColor != null) {
                        return 2 + self._verticalMargin;
                    }
                }
                return 0;
            }

            protected function validate(dc as Dc) {
                if (self._layer != null) {
                    var padding = self._layer.getWidth() * self._horizonalPaddingFactor;
                    var width = self._layer.getWidth() - 2 * padding;
                    if (self._needValidation == true) {
                        self._height = -1;
                        if (self.Title != null && self.Title instanceof MultilineLabel == false) {
                            self.Title = new MultilineLabel(self.Title, width - self.getIconWidth(dc), self._font);
                        } else if (self.Title instanceof MultilineLabel == false) {
                            self.Title = null;
                        }

                        if (self.Subtitle != null && self.Subtitle instanceof MultilineLabel == false) {
                            self.Subtitle = new MultilineLabel(self.Subtitle, width, Helper.Fonts.Small());
                        } else if (self.Subtitle instanceof MultilineLabel == false) {
                            self.Subtitle = null;
                        }
                        self._needValidation = false;
                    }

                    if (self.Title instanceof MultilineLabel) {
                        self.Title.Invalidate(width - self.getIconWidth(dc));
                    }

                    if (self.Subtitle instanceof MultilineLabel) {
                        self.Subtitle.Invalidate(width);
                    }
                }
            }

            protected function getIconWidth(dc as Dc) as Number {
                var iconwidth;
                if (self._icon instanceof String && self._icon.length() > 0) {
                    iconwidth = dc.getTextWidthInPixels(self._icon, Helper.Fonts.Icons());
                } else if (self._icon != null) {
                    iconwidth = self._icon.getWidth();
                } else {
                    iconwidth = 0;
                }

                return iconwidth + iconwidth * self._iconPaddingFactor;
            }

            protected function isBitmap(obj as Object) as Boolean {
                if (obj instanceof WatchUi.BitmapResource || (Graphics has :BitmapReference && obj instanceof Graphics.BitmapReference)) {
                    return true;
                } else {
                    return false;
                }
            }
        }
    }
}
