import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Helper;

module Controls {
    module Listitems {
        typedef ViewItemIcon as WatchUi.BitmapResource or Graphics.BitmapReference;

        class Item {
            var Title as String or Label or Null;
            var Subtitle as String or Label or Null;
            var BoundObject as Object? = null;
            var ItemPosition as Number = -1;
            var DrawLine as Boolean = true;
            var isSelectable as Boolean = true;
            var isDisabled as Boolean = false;

            var TitleJustification as TextJustification = Graphics.TEXT_JUSTIFY_LEFT;
            var SubtitleJustification as TextJustification = Graphics.TEXT_JUSTIFY_LEFT;

            protected static var _iconPaddingFactor = 0.3;

            protected var _needValidation as Boolean = true;
            protected var _font as FontType;
            protected var _subFont as FontType?;
            protected var _verticalMargin as Number = 0;
            protected var _verticalPadding as Number;
            protected var _icon as String or ViewItemIcon or Null = null;
            protected var _iconInvert as String or ViewItemIcon or Null = null;
            protected var _listY as Number? = null;
            protected var _height as Number? = null;
            protected var _layer as LayerDef? = null;
            protected var _textOffsetX as Number = 0;

            function initialize(layer as LayerDef?, title as String or Array<String> or Null, subtitle as String or Array<String> or Null, obj as Object?, icon as Number or BitmapResource or Null, vert_margin as Number?, position as Number, fontoverride as FontType?) {
                self._font = fontoverride != null ? fontoverride : Helper.Fonts.Normal();
                self._subFont = Helper.Fonts.Small();
                self.ItemPosition = position;
                self._layer = layer;
                if (vert_margin != null) {
                    self._verticalMargin = vert_margin;
                } else {
                    self._verticalMargin = ($.screenHeight * 0.02).toNumber();
                }
                self._verticalPadding = ($.screenHeight * 0.03).toNumber();
                self.Title = title;
                self.Subtitle = subtitle;
                self.BoundObject = obj;
                self.setIcon(icon);
                self._needValidation = true;
            }

            /** returns height of the item */
            function draw(dc as Dc, scrollOffset as Number, isSelected as Boolean) as Number {
                if (self._layer == null || self._listY == null) {
                    return 0;
                }
                self.validate(dc);
                var viewport_y = self._listY - scrollOffset + self._layer.getY();
                if (self.isVisible(scrollOffset, dc) == false) {
                    return self.getHeight(dc);
                }

                var viewport_yTop = viewport_y;
                viewport_y += self._verticalMargin;

                var theme = $.getTheme();

                var specialColor = isSelected && self.isSelectable && Views.ItemView.DisplayButtonSupport();
                var color = specialColor ? theme.MainColorSelected : theme.MainColor;
                var colorSub = specialColor ? theme.SecondColorSelected : theme.SecondColor;
                if (self.isDisabled) {
                    color = specialColor ? theme.DisabledColorSelected : theme.DisabledColor;
                    colorSub = color;
                }

                if (specialColor) {
                    self.drawSelectedBackground(dc, viewport_y);
                }

                viewport_y += self._verticalPadding;
                var x = self._layer.getX();

                if (self._icon instanceof String && self._icon.length() > 0) {
                    var iconoffsety = (Graphics.getFontHeight(self._font) - dc.getFontHeight(Helper.Fonts.Icons())) / 2;
                    dc.setColor(color, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(x, viewport_y + iconoffsety, Helper.Fonts.Icons(), self._icon, Graphics.TEXT_JUSTIFY_LEFT);
                } else if (self.isBitmap(self._icon)) {
                    var icon = specialColor && self._iconInvert != null ? self._iconInvert : self._icon;
                    var iconoffsety = (Graphics.getFontHeight(self._font) - icon.getHeight()) / 2;
                    dc.drawBitmap(x, viewport_y + iconoffsety, icon);
                }

                if (self.Title != null) {
                    viewport_y += self.Title.draw(dc, x + self.getIconWidth(dc), viewport_y, color, self.TitleJustification);
                }
                if (self.Subtitle != null) {
                    viewport_y += Graphics.getFontAscent(Helper.Fonts.Small()) / 8; //little space between title and subtitle
                    viewport_y += self.Subtitle.draw(dc, x, viewport_y, colorSub, self.SubtitleJustification);
                }

                viewport_y += self._verticalPadding;

                if (self.DrawLine == true) {
                    viewport_y = self.drawLine(dc, viewport_y);
                }

                viewport_y += self._verticalMargin;
                self._height = viewport_y - viewport_yTop;

                return self._height;
            }

            function setListY(y as Number) {
                self._listY = y;
            }

            function getListY() as Number {
                return self._listY != null ? self._listY : 0;
            }

            function getHeight(dc as Dc?) as Number {
                if (dc != null) {
                    self.validate(dc);
                    if (self._height == null || self._height <= 0) {
                        self._height = self._verticalMargin + self._verticalPadding;
                        if (self.Title != null) {
                            //self._height += self.Title.getHeight(dc);
                            self._height += self.Title.getHeight(dc);
                        }
                        if (self.Subtitle != null) {
                            self._height += (Graphics.getFontAscent(self.Subtitle.getFont()) / 8).toNumber();
                            self._height += self.Subtitle.getHeight(dc);
                        }
                        self._height += self._verticalMargin + self._verticalPadding;
                        self._height += self.getLineHeight();
                    }
                    return self._height;
                } else if (self._height != null && self._height >= 0) {
                    return self._height;
                } else {
                    return 0;
                }
            }

            function setIcon(icon as Number or ViewItemIcon or Null) as Void {
                if (self._icon != icon) {
                    if (icon instanceof Number && icon >= 0) {
                        self._icon = icon.toChar().toString();
                    } else {
                        self._icon = icon;
                    }
                    self.Invalidate();
                }
            }

            function getIcon() as Number or ViewItemIcon or Null {
                return self._icon;
            }

            function setSubFont(font as FontType?) as Void {
                if (font != self._subFont) {
                    if (font == null) {
                        font = Helper.Fonts.Small();
                    }
                    self._subFont = font;
                    self.Invalidate();
                }
            }

            function setIconInvert(icon as Number or ViewItemIcon or Null) as Void {
                if (self._iconInvert != icon) {
                    if (icon instanceof Number && icon >= 0) {
                        self._iconInvert = icon.toChar().toString();
                    } else {
                        self._iconInvert = icon;
                    }
                    self._needValidation = true;
                }
            }

            function Clicked(tapy as Number, scrollOffset as Number) as Boolean {
                if (self._height == null || self.isVisible(scrollOffset, null) == false) {
                    //not visible or not validated
                    return false;
                }

                var viewportY = self._listY - scrollOffset + self._layer.getY();
                if (tapy >= viewportY && tapy <= viewportY + self._height) {
                    return true;
                }

                return false;
            }

            function Invalidate() as Void {
                self._needValidation = true;
                self._height = -1;
            }

            protected function isVisible(scrollOffset as Number, dc as Dc?) as Boolean {
                if (self._height == null) {
                    if (dc != null) {
                        self._needValidation = true;
                        self.validate(dc);
                    } else {
                        return true;
                    }
                }
                if (self._layer == null) {
                    return false;
                }
                var viewportY = self.getViewportYTop(scrollOffset);
                if (viewportY == null) {
                    return true;
                }

                if (viewportY + self._height <= 0) {
                    //above the top edge of the display
                    return false;
                } else if (viewportY > $.screenHeight) {
                    //below the bottom edge of the display
                    return false;
                } else {
                    return true;
                }
            }

            protected function drawLine(dc as Dc, y as Number) as Number {
                var line = $.getTheme().LineBitmap;
                if (line != null) {
                    y += self._verticalMargin;
                    var x = (dc.getWidth() - line.getWidth()) / 2;
                    dc.drawBitmap(x, y, line);
                    y += line.getHeight();
                } else if ($.getTheme().LineSeparatorColor != null) {
                    y += self._verticalMargin;
                    dc.setColor($.getTheme().LineSeparatorColor, Graphics.COLOR_TRANSPARENT);
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
                if (self._layer != null && self._needValidation) {
                    self._height = -1;
                    if (self.Title instanceof Label) {
                        self.Title.validate(dc);
                    } else if (self.Title instanceof String) {
                        self.Title = new Label(self.Title, self._font, self.getTextWidth(dc, true));
                    }
                    if (self.Subtitle instanceof Label) {
                        self.Subtitle.validate(dc);
                    } else if (self.Subtitle instanceof String) {
                        self.Subtitle = new Label(self.Subtitle, self._subFont, self.getTextWidth(dc, false));
                    }
                    self._needValidation = false;
                }
            }

            protected function getTextWidth(dc as Dc, with_icon as Boolean) as Number {
                var width = self._layer.getWidth();
                if (with_icon) {
                    width -= self.getIconWidth(dc);
                }
                return width;
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

            protected function drawSelectedBackground(dc as Dc, viewport_y as Number) as Void {
                var height = self.getHeight(dc) - 2 * self._verticalMargin - self.getLineHeight();
                dc.setColor($.getTheme().SelectedItemBackground, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(0, viewport_y, dc.getWidth(), height);
            }

            protected function getViewportYTop(scrollOffset as Number) as Number? {
                if (self._listY == null) {
                    return null;
                }
                return self._listY - scrollOffset + self._layer.getY();
            }

            protected static function isBitmap(obj as Object) as Boolean {
                if (obj instanceof WatchUi.BitmapResource || (Graphics has :BitmapReference && obj instanceof Graphics.BitmapReference)) {
                    return true;
                } else {
                    return false;
                }
            }
        }
    }
}
