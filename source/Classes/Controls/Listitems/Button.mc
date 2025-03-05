import Toybox.Lang;
import Toybox.Graphics;
import Exceptions;

module Controls {
    module Listitems {
        class Button extends Item {
            private var _paddingFactor = 0.05;
            private var _horMarginFactor = 0.03;

            function initialize(layer as LayerDef?, title as String, identifier as Object, margin as Number?, drawline as Boolean) {
                Item.initialize(layer, null, null, identifier, null, margin, -1, null);
                self.Title = title;
                self.Subtitle = null;
                self.DrawLine = drawline;
            }

            /** returns height of the item */
            function draw(dc as Dc, scrollOffset as Number, isSelected as Boolean) as Number {
                if (self._layer == null) {
                    return 0;
                }
                self.validate(dc);

                var viewport_y = self._listY - scrollOffset + self._layer.getY();

                if (self.isVisible(scrollOffset, dc) == false) {
                    return self.getHeight(dc);
                }

                var viewport_yTop = viewport_y;
                viewport_y += self._verticalMargin;

                if (isSelected && self.isSelectable && Views.ItemView.DisplayButtonSupport()) {
                    self.drawSelectedBackground(dc, viewport_y);
                }

                viewport_y += self._verticalPadding;
                var margin = (self._layer.getWidth() * self._horMarginFactor).toNumber();
                var x = self._layer.getX() + margin;

                //background
                var button_width = self.getButtonWidth();
                var padding = (button_width * self._paddingFactor).toNumber();
                var button_height = self.Title.getHeight(dc) + 2 * padding;
                dc.setColor($.getTheme().ButtonBackground, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(x, viewport_y, button_width, button_height, padding * 0.7);

                dc.setColor($.getTheme().ButtonBorder, Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(2);
                dc.drawRoundedRectangle(x, viewport_y, button_width, button_height, padding * 0.7);

                //text
                self.Title.draw(dc, x + padding, viewport_y + padding, $.getTheme().ButtonColor, Graphics.TEXT_JUSTIFY_CENTER);
                viewport_y += button_height + self._verticalPadding;

                if (self.DrawLine == true) {
                    viewport_y = self.drawLine(dc, viewport_y);
                }

                viewport_y += self._verticalMargin;

                self._height = viewport_y - viewport_yTop;
                return self._height;
            }

            function getHeight(dc as Dc?) as Number {
                if (dc != null && self._layer != null) {
                    self.validate(dc);
                    if (self._height == null || self._height <= 0) {
                        self._height = self._verticalMargin + self._verticalPadding;

                        var padding = (self.getButtonWidth() * self._paddingFactor).toNumber();
                        self._height += self.Title.getHeight(dc) + 2 * padding;
                        self._height += self._verticalPadding + self._verticalMargin;
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
                var margin = (self._layer.getWidth() * self._horMarginFactor).toNumber();
                return self._layer.getWidth() - 2 * margin;
            }

            protected function validate(dc as Dc) {
                if (self._needValidation) {
                    if (self.Title instanceof String) {
                        var buttonWidth = self.getButtonWidth();
                        var padding = (buttonWidth * self._paddingFactor).toNumber();
                        var maxwidth = (self.getButtonWidth() - 2 * padding).toNumber();
                        self.Title = new Label(self.Title, self._font, maxwidth);
                    }
                    self._needValidation = false;
                }
            }
        }
    }
}
