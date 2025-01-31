using Views;
import Toybox.Lang;
import Toybox.Graphics;
import Helper;

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
                var margin;
                margin /*>pre__layer<*/ = self._layer;
                if (margin /*>pre__layer<*/ == null) {
                    return 0;
                }
                self.validate(dc);

                var viewport_y = self._listY - scrollOffset + margin /*>pre__layer<*/.getY();

                if (self.isVisible(scrollOffset, dc) == false) {
                    return self.getHeight(dc);
                }

                var viewport_yTop = viewport_y;
                viewport_y += self._verticalMargin;

                if (isSelected && self.isSelectable && Views.ItemView.DisplayButtonSupport()) {
                    self.drawSelectedBackground(dc, viewport_y);
                }

                viewport_y += self._verticalPadding;
                margin = (self._layer.getWidth() * self._horMarginFactor).toNumber();
                margin /*>x<*/ = self._layer.getX() + margin;

                //background
                scrollOffset /*>button_width<*/ = self.getButtonWidth();
                isSelected /*>padding<*/ = (scrollOffset /*>button_width<*/ * self._paddingFactor).toNumber();
                var button_height = self.Title.getHeight(dc) + isSelected /*>padding<*/ * 2;
                dc.setColor($.getTheme().ButtonBackground, -1 as Toybox.Graphics.ColorValue);
                dc.fillRoundedRectangle(margin /*>x<*/, viewport_y, scrollOffset /*>button_width<*/, button_height, isSelected /*>padding<*/ * 0.7);

                dc.setColor($.getTheme().ButtonBorder, -1 as Toybox.Graphics.ColorValue);
                dc.setPenWidth(2);
                dc.drawRoundedRectangle(margin /*>x<*/, viewport_y, scrollOffset /*>button_width<*/, button_height, isSelected /*>padding<*/ * 0.7);

                //text
                self.Title.draw(dc, margin /*>x<*/ + isSelected /*>padding<*/, viewport_y + isSelected /*>padding<*/, $.getTheme().ButtonColor, 1 as Toybox.Graphics.TextJustification);
                viewport_y += button_height + self._verticalPadding;

                if (self.DrawLine == true) {
                    viewport_y = self.drawLine(dc, viewport_y);
                }

                self._height = viewport_y + self._verticalMargin - viewport_yTop;
                return self._height;
            }

            function getHeight(dc as Dc?) as Number {
                var pre__height;
                if (dc != null && self._layer != null) {
                    pre__height = self._height;
                    self.validate(dc);
                    if (pre__height == null || pre__height <= 0) {
                        self._height = self._verticalMargin + self._verticalPadding;

                        pre__height /*>padding<*/ = (self.getButtonWidth() * self._paddingFactor).toNumber();
                        self._height += self.Title.getHeight(dc) + pre__height /*>padding<*/ * 2;
                        self._height += self._verticalPadding + self._verticalMargin;
                        self._height += self.getLineHeight();
                    }
                } else if (self._height == null) {
                    self._height = 0;
                }

                return self._height;
            }

            private function getButtonWidth() as Number {
                var margin;
                margin /*>pre__layer<*/ = self._layer;
                if (margin /*>pre__layer<*/ == null) {
                    return 0;
                }
                margin = (margin /*>pre__layer<*/.getWidth() * self._horMarginFactor).toNumber();
                return self._layer.getWidth() - margin * 2;
            }

            protected function validate(dc as Dc) {
                if (self._needValidation) {
                    if (self.Title instanceof String) {
                        dc /*>padding<*/ = (self.getButtonWidth() * self._paddingFactor).toNumber();
                        dc /*>maxwidth<*/ = (self.getButtonWidth() - dc /*>padding<*/ * 2).toNumber();
                        self.Title = new Label(self.Title, self._font, dc /*>maxwidth<*/);
                    }
                    self._needValidation = false;
                }
            }
        }
    }
}
