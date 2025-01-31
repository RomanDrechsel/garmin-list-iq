using Views;
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

            var TitleJustification as TextJustification = 2 as Toybox.Graphics.TextJustification;
            var SubtitleJustification as TextJustification = 2 as Toybox.Graphics.TextJustification;

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

            function initialize(
                layer as LayerDef?,
                title as String or Array<String> or Null,
                subtitle as String or Array<String> or Null,
                obj as Object?,
                icon as Number or BitmapResource or Null,
                vert_margin as Number?,
                position as Number,
                fontoverride as FontType?
            ) {
                var pre_Fonts;
                pre_Fonts = Helper.Fonts;
                self._font = fontoverride != null ? fontoverride : pre_Fonts.Normal();
                fontoverride /*>pre_screenHeight<*/ = $.screenHeight;
                self._subFont = pre_Fonts.Small();
                self.ItemPosition = position;
                self._layer = layer;
                if (vert_margin != null) {
                    self._verticalMargin = vert_margin;
                } else {
                    self._verticalMargin = (fontoverride /*>pre_screenHeight<*/ * 0.02).toNumber();
                }
                self._verticalPadding = (fontoverride /*>pre_screenHeight<*/ * 0.03).toNumber();
                self.Title = title;
                self.Subtitle = subtitle;
                self.BoundObject = obj;
                self.setIcon(icon);
                self._needValidation = true;
            }

            /** returns height of the item */
            function draw(dc as Dc, scrollOffset as Number, isSelected as Boolean) as Number {
                var pre_2;
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

                scrollOffset /*>theme<*/ = $.getTheme();

                isSelected /*>specialColor<*/ = isSelected && self.isSelectable && Views.ItemView.DisplayButtonSupport();
                var color = isSelected /*>specialColor<*/ ? scrollOffset /*>theme<*/.MainColorSelected : scrollOffset /*>theme<*/.MainColor;
                var colorSub = isSelected /*>specialColor<*/ ? scrollOffset /*>theme<*/.SecondColorSelected : scrollOffset /*>theme<*/.SecondColor;
                if (self.isDisabled) {
                    color = isSelected /*>specialColor<*/ ? scrollOffset /*>theme<*/.DisabledColorSelected : scrollOffset /*>theme<*/.DisabledColor;
                    colorSub = color;
                }

                if (isSelected /*>specialColor<*/) {
                    self.drawSelectedBackground(dc, viewport_y);
                }

                pre_2 = 2;
                scrollOffset /*>pre__icon<*/ = self._icon;
                viewport_y += self._verticalPadding;
                var x = self._layer.getX();

                if (scrollOffset /*>pre__icon<*/ instanceof String && scrollOffset /*>pre__icon<*/.length() > 0) {
                    scrollOffset /*>iconoffsety<*/ = (Graphics.getFontHeight(self._font) - dc.getFontHeight(Helper.Fonts.Icons())) / pre_2;
                    dc.setColor(color, -1 as Toybox.Graphics.ColorValue);
                    dc.drawText(x, viewport_y + scrollOffset /*>iconoffsety<*/, Helper.Fonts.Icons(), self._icon, pre_2 as Toybox.Graphics.TextJustification);
                } else if (self.isBitmap(self._icon)) {
                    scrollOffset /*>icon<*/ = isSelected /*>specialColor<*/ && self._iconInvert != null ? self._iconInvert : self._icon;
                    dc.drawBitmap(x, viewport_y + (Graphics.getFontHeight(self._font) - scrollOffset /*>icon<*/.getHeight()) / pre_2, scrollOffset /*>icon<*/);
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

                self._height = viewport_y + self._verticalMargin - viewport_yTop;

                return self._height;
            }

            function setListY(y as Number) {
                self._listY = y;
            }

            function getListY() as Number {
                var pre__listY;
                pre__listY = self._listY;
                return pre__listY != null ? pre__listY : 0;
            }

            function getHeight(dc as Dc?) as Number {
                var pre_Subtitle, pre_0;
                pre_0 = 0;
                if (dc != null) {
                    self.validate(dc);
                    pre_Subtitle /*>pre__height<*/ = self._height;
                    if (pre_Subtitle /*>pre__height<*/ == null || pre_Subtitle /*>pre__height<*/ <= pre_0) {
                        pre_Subtitle /*>pre_Title<*/ = self.Title;
                        self._height = self._verticalMargin + self._verticalPadding;
                        if (pre_Subtitle /*>pre_Title<*/ != null) {
                            //self._height += self.Title.getHeight(dc);
                            self._height += pre_Subtitle /*>pre_Title<*/.getHeight(dc);
                        }
                        pre_Subtitle = self.Subtitle;
                        if (pre_Subtitle != null) {
                            self._height += (Graphics.getFontAscent(pre_Subtitle.getFont()) / 8).toNumber();
                            self._height += self.Subtitle.getHeight(dc);
                        }
                        self._height += self._verticalMargin + self._verticalPadding;
                        self._height += self.getLineHeight();
                    }
                    return self._height;
                } else if (self._height != null && self._height >= pre_0) {
                    return self._height;
                } else {
                    return pre_0;
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
                if (self._height == null || self._listY == null || self.isVisible(scrollOffset, null) == false) {
                    //not visible or not validated
                    return false;
                }

                scrollOffset /*>viewportY<*/ = self._listY - scrollOffset + self._layer.getY();
                if (tapy >= scrollOffset /*>viewportY<*/ && tapy <= scrollOffset /*>viewportY<*/ + self._height) {
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
                scrollOffset /*>viewportY<*/ = self.getViewportYTop(scrollOffset);
                if (scrollOffset /*>viewportY<*/ == null) {
                    return true;
                }

                if (scrollOffset /*>viewportY<*/ + self._height <= 0) {
                    //above the top edge of the display
                    return false;
                } else if (scrollOffset /*>viewportY<*/ > $.screenHeight) {
                    //below the bottom edge of the display
                    return false;
                } else {
                    return true;
                }
            }

            protected function drawLine(dc as Dc, y as Number) as Number {
                var pre_2;
                pre_2 = 2;
                var line = $.getTheme().LineBitmap;
                if (line != null) {
                    y += self._verticalMargin;
                    dc.drawBitmap((dc.getWidth() - line.getWidth()) / pre_2, y, line);
                    y += line.getHeight();
                } else if ($.getTheme().LineSeparatorColor != null) {
                    y += self._verticalMargin;
                    dc.setColor($.getTheme().LineSeparatorColor, -1 as Toybox.Graphics.ColorValue);
                    dc.setPenWidth(pre_2);
                    dc.drawLine(0, y, dc.getWidth(), y);
                    y += pre_2;
                }

                return y;
            }

            protected function getLineHeight() {
                if (self.DrawLine == true) {
                    var line = $.getTheme().LineBitmap;
                    if (line != null) {
                        return line.getHeight() + self._verticalMargin;
                    } else if ($.getTheme().LineSeparatorColor != null) {
                        return self._verticalMargin + 2;
                    }
                }
                return 0;
            }

            protected function validate(dc as Dc) {
                var pre_Title;
                if (self._layer != null && self._needValidation) {
                    pre_Title = self.Title;
                    self._height = -1;
                    if (pre_Title instanceof Label) {
                        pre_Title.validate(dc);
                    } else if (pre_Title instanceof String) {
                        self.Title = new Label(pre_Title, self._font, self.getTextWidth(dc, true));
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
                iconwidth /*>pre__icon<*/ = self._icon;
                if (iconwidth /*>pre__icon<*/ instanceof String && iconwidth /*>pre__icon<*/.length() > 0) {
                    iconwidth = dc.getTextWidthInPixels(self._icon, Helper.Fonts.Icons());
                } else if (self._icon != null) {
                    iconwidth = self._icon.getWidth();
                } else {
                    iconwidth = 0;
                }

                return iconwidth + iconwidth * self._iconPaddingFactor;
            }

            protected function drawSelectedBackground(dc as Dc, viewport_y as Number) as Void {
                var theme = $.getTheme();
                var height = self.getHeight(dc) - self._verticalMargin * 2 - self.getLineHeight();
                dc.setColor(theme.SelectedItemBackground, theme.SelectedItemBackground);
                dc.fillRectangle(0, viewport_y, dc.getWidth(), height);
            }

            protected function getViewportYTop(scrollOffset as Number) as Number? {
                var pre__listY;
                pre__listY = self._listY;
                if (pre__listY == null) {
                    return null;
                }
                return pre__listY - scrollOffset + self._layer.getY();
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
