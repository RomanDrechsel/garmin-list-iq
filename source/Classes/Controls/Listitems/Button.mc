import Toybox.Lang;
import Toybox.Graphics;
import Helper;

module Controls {
    module Listitems {
        class Button extends Item {
            private var _marginFactor = 0.05;
            private var _paddingFactor = 0.05;

            function initialize(layer as LayerDef?, title as String, identifier as Object, margin as Number, drawline as Boolean) {
                Item.initialize(layer, null, null, identifier, null, margin, -1, null);
                self.Title = title;
                self.Subtitle = null;
                self.DrawLine = drawline;
                if ($.isRoundDisplay == true) {
                    //double on round displays
                    self._marginFactor += self._marginFactor;
                }
            }

            /** returns height of the item */
            function draw(dc as Dc, yOffset as Number) as Number {
                if (self._layer == null) {
                    return 0;
                }
                self.validate(dc);

                var viewport_y = self._listY - yOffset + self._layer.getY();
                self._viewportY = viewport_y;
                viewport_y += self._verticalMargin;

                if (self.isVisible() == false) {
                    return self.getHeight(dc);
                }

                var x = self._layer.getX() + self._layer.getWidth() * self._marginFactor;

                //background
                var button_width = self.getButtonWidth();
                var padding = self.getPadding();
                var button_height = self.Title.getHeight(dc) + 2 * padding + Graphics.getFontDescent(self._font);
                dc.setColor(getTheme().ButtonBackground, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(x, viewport_y, button_width, button_height, padding * 0.5);

                dc.setColor(getTheme().ButtonBorder, Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(2);
                dc.drawRoundedRectangle(x, viewport_y, button_width, button_height, padding * 0.5);

                //text
                self.Title.drawText(dc, x + padding, viewport_y + padding, self._color, Graphics.TEXT_JUSTIFY_CENTER);
                viewport_y += button_height;

                if (self.DrawLine == true) {
                    viewport_y = self.drawLine(dc, viewport_y);
                }

                self._height = viewport_y - self._viewportY;
                return self._height;
            }

            function getHeight(dc as Dc?) as Number {
                if (dc != null && self._layer != null) {
                    self.validate(dc);
                    if (self.Title instanceof String) {
                        return dc.getFontHeight(self._font);
                    }
                    if (self._height == null || self._height <= 0) {
                        self._height = self._verticalMargin + self.Title.getHeight(dc) + 2 * self.getPadding() + Graphics.getFontDescent(self._font);
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
                var x = self._layer.getWidth() * self._marginFactor;
                return self._layer.getWidth() - 2 * x;
            }

            private function getPadding() {
                return self.getButtonWidth() * self._paddingFactor;
            }

            protected function validate(dc as Dc) {
                if (self.Title instanceof String) {
                    var maxwidth = self.getButtonWidth() - 2 * self.getPadding();
                    self.Title = new MultilineLabel(self.Title, maxwidth.toNumber(), self._font);
                } else if (self.Title instanceof MultilineLabel) {
                    var maxwidth = self.getButtonWidth() - 2 * self.getPadding();
                    self.Title.Invalidate(maxwidth);
                }
            }
        }
    }
}
