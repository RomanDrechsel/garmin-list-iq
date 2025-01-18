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
            var isSelectable as Boolean = true;
            var isDisabled as Boolean = false;

            protected static var _horizonalPaddingFactor = 0.05;
            protected static var _iconPaddingFactor = 0.3;

            protected var _needValidation as Boolean = true;
            protected var _font as FontType;
            protected var _verticalMargin as Number = 0;
            protected var _verticalPadding as Number;
            protected var _icon as String or ViewItemIcon or Null = null;
            protected var _iconInvert as ViewItemIcon? = null;
            protected var _listY as Number? = null;
            protected var _height as Number? = null;
            protected var _layer as LayerDef? = null;
            protected var _textOffsetX as Number = 0;

            function initialize(layer as LayerDef?, title as String or Array<String> or Null, subtitle as String or Array<String> or Null, obj as Object?, icon as Number or BitmapResource or Null, vert_margin as Number?, position as Number, fontoverride as FontType?) {
                self._font = fontoverride != null ? fontoverride : Helper.Fonts.Normal();
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
                if (self.isVisible(scrollOffset) == false) {
                    return self.getHeight(dc);
                }

                var viewport_yTop = viewport_y;
                viewport_y += self._verticalMargin;

                var specialColor = isSelected && self.isSelectable && !$.TouchControls;
                var color = specialColor ? $.getTheme().MainColorSelected : $.getTheme().MainColor;
                var colorSub = specialColor ? $.getTheme().SecondColorSelected : $.getTheme().SecondColor;
                if (self.isDisabled) {
                    color = $.getTheme().DisabledColor;
                    colorSub = color;
                }

                if (specialColor) {
                    self.drawSelectedBackground(dc, viewport_y);
                }

                //Debug.Box(dc, 0, viewport_y - self._verticalMargin, dc.getWidth(), 1, Graphics.COLOR_RED);
                //Debug.Box(dc, 0, viewport_y, dc.getWidth(), 1, Graphics.COLOR_BLUE);

                viewport_y += self._verticalPadding;

                //Debug.Box(dc, 0, viewport_y, dc.getWidth(), 1, Graphics.COLOR_BLUE);

                var hor_padding = self._layer.getWidth() * self._horizonalPaddingFactor;
                var x = self._layer.getX() + hor_padding;

                if (self._icon instanceof String && self._icon.length() > 0) {
                    var iconoffsety = (Graphics.getFontHeight(self._font) - dc.getFontHeight(Helper.Fonts.Icons())) / 2;
                    dc.setColor(color, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(x, viewport_y + iconoffsety, Helper.Fonts.Icons(), self._icon, Graphics.TEXT_JUSTIFY_LEFT);
                } else if (self.isBitmap(self._icon)) {
                    var icon = specialColor && self._iconInvert != null ? self._iconInvert : self._icon;
                    var iconoffsety = (Graphics.getFontHeight(self._font) - icon.getHeight()) / 2;
                    dc.drawBitmap(x, viewport_y + iconoffsety, icon);
                }

                if (self.Title instanceof MultilineLabel) {
                    viewport_y += self.Title.drawText(dc, x + self.getIconWidth(dc), viewport_y, color, self.TitleJustification);
                }

                if (self.Subtitle instanceof MultilineLabel) {
                    viewport_y += Graphics.getFontAscent(Helper.Fonts.Small()) / 8; //little space between title and subtitle
                    viewport_y += self.Subtitle.drawText(dc, x, viewport_y, colorSub, self.SubtitleJustification);
                }

                //Debug.Box(dc, 0, viewport_y, dc.getWidth(), 1, Graphics.COLOR_BLUE);
                viewport_y += self._verticalPadding;
                //Debug.Box(dc, 0, viewport_y, dc.getWidth(), 1, Graphics.COLOR_BLUE);

                if (self.DrawLine == true) {
                    viewport_y = self.drawLine(dc, viewport_y);
                }

                viewport_y += self._verticalMargin;
                //Debug.Box(dc, 0, viewport_y, dc.getWidth(), 1, Graphics.COLOR_YELLOW);
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
                            self._height += self.Title.getHeight(dc);
                        }
                        if (self.Subtitle != null) {
                            self._height += Graphics.getFontAscent(Helper.Fonts.Small()) / 8;
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
                if (icon instanceof Number && icon >= 0) {
                    self._icon = icon.toChar().toString();
                } else if (self.isBitmap(icon)) {
                    self._icon = icon;
                }
            }

            function getIcon() as Number or ViewItemIcon or Null {
                return self._icon;
            }

            function setIconInvert(icon as ViewItemIcon?) as Void {
                self._iconInvert = icon;
            }

            function Clicked(tapy as Number, scrollOffset as Number) as Boolean {
                if (self._height == null || self.isVisible(scrollOffset) == false) {
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

            function setLayer(layer as LayerDef) as Void {
                self._layer = layer;
            }

            protected function isVisible(scrollOffset as Number) as Boolean {
                if (self._height == null) {
                    return true;
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
                } else if (viewportY > self._layer.getDc().getHeight()) {
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

            protected function drawSelectedBackground(dc as Dc, viewport_y as Number) as Void {
                var height = self.getHeight(dc) - 2 * self._verticalMargin - self.getLineHeight();
                dc.setColor($.getTheme().SelectedItemBackground, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(0, viewport_y, dc.getWidth(), height);
            }

            protected function getViewportYTop(scrollOffset as Number) as Number? {
                if (self._listY == null) {
                    return null;
                }
                return self._listY - scrollOffset;
            }
        }
    }
}
