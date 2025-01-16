import Toybox.Lang;
import Toybox.Graphics;
import Helper;

module Controls {
    module Listitems {
        class Button extends Item {
            private var _horMarginFactor = 0.05;
            private var _horPaddingFactor = 0.05;

            function initialize(layer as LayerDef?, title as String, identifier as Object, margin as Number?, drawline as Boolean) {
                Item.initialize(layer, null, null, identifier, null, margin, -1, null);
                self.Title = title;
                self.Subtitle = null;
                self.DrawLine = drawline;
                if ($.isRoundDisplay == true) {
                    //double on round displays
                    self._horMarginFactor *= 2;
                }
            }

            /** returns height of the item */
            function draw(dc as Dc, scrollOffset as Number, isSelected as Boolean) as Number {
                if (self._layer == null) {
                    return 0;
                }
                self.validate(dc);

                var viewport_y = self._listY - scrollOffset + self._layer.getY();

                if (self.isVisible(scrollOffset) == false) {
                    return self.getHeight(dc);
                }

                var viewport_yTop = viewport_y;
                viewport_y += self._verticalMargin;

                if (isSelected && self.isSelectable && !$.TouchControls) {
                    self.drawSelectedBackground(dc, viewport_y);
                }

                //Debug.Box(dc, 0, viewport_y - self._verticalMargin, dc.getWidth(), 1, Graphics.COLOR_RED);
                //Debug.Box(dc, 0, viewport_y, dc.getWidth(), 1, Graphics.COLOR_BLUE);

                viewport_y += self._verticalPadding;
                var x = self._layer.getX() + self._layer.getWidth() * self._horMarginFactor;
                //Debug.Box(dc, 0, viewport_y, dc.getWidth(), 1, Graphics.COLOR_BLUE);

                //background
                var button_width = self.getButtonWidth();
                var padding = self.getHorizontalPadding();
                var button_height = self.Title.getHeight(dc) + 2 * padding + Graphics.getFontDescent(self._font);
                dc.setColor(getTheme().ButtonBackground, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(x, viewport_y, button_width, button_height, padding * 0.5);

                dc.setColor(getTheme().ButtonBorder, Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(2);
                dc.drawRoundedRectangle(x, viewport_y, button_width, button_height, padding * 0.5);

                //text
                self.Title.drawText(dc, x + padding, viewport_y + padding, $.getTheme().MainColor, Graphics.TEXT_JUSTIFY_CENTER);
                viewport_y += button_height;

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

            function getHeight(dc as Dc?) as Number {
                if (dc != null && self._layer != null) {
                    self.validate(dc);
                    if (self._height == null || self._height <= 0) {
                        self._height = self._verticalMargin + 2 * self.getHorizontalPadding() + Graphics.getFontDescent(self._font);
                        if (self.Title instanceof String) {
                            self._height += dc.getFontHeight(self._font);
                        } else {
                            self._height += self.Title.getHeight(dc);
                        }
                        self._height += 2 * self._verticalPadding;
                        self._height += self.getLineHeight();
                    }
                } else if (self._height == null) {
                    self._height = 0;
                }

                return self._height;
            }

            private function getButtonWidth() as Number {
                if (self._layer == null) {
                    return 0;
                }
                var x = self._layer.getWidth() * self._horMarginFactor;
                return self._layer.getWidth() - 2 * x;
            }

            private function getHorizontalPadding() {
                return self.getButtonWidth() * self._horPaddingFactor;
            }

            protected function validate(dc as Dc) {
                if (self.Title instanceof String) {
                    var maxwidth = self.getButtonWidth() - 2 * self.getHorizontalPadding();
                    self.Title = new MultilineLabel(self.Title, maxwidth.toNumber(), self._font);
                } else if (self.Title instanceof MultilineLabel) {
                    var maxwidth = self.getButtonWidth() - 2 * self.getHorizontalPadding();
                    self.Title.Invalidate(maxwidth);
                }
            }
        }
    }
}
