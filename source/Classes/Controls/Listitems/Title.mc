import Toybox.Lang;
import Toybox.Graphics;

module Controls {
    module Listitems {
        class Title extends Item {
            private static var _lineHeight = 2;

            function initialize(layer as LayerDef?, title as String) {
                Item.initialize(layer, title, null, null, null, 10, -1, null);
                self.TitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
                self.DrawLine = false;
                self.isSelectable = false;
                if ($.screenHeight < 300) {
                    self._lineHeight = 1;
                }
            }

            function Clicked(tapy as Number, scrollOffset as Number) as Boolean {
                return false;
            }

            function draw(dc as Dc, scrollOffset as Number, isSelected as Boolean) as Number {
                var height = Item.draw(dc, scrollOffset, false);
                var theme = $.getTheme();
                dc.setColor(theme.TitleSeparatorColor, theme.TitleSeparatorColor);
                dc.fillRectangle(0, self._listY - scrollOffset + self._layer.getY() + height - self._lineHeight, dc.getWidth(), self._lineHeight);
                return height;
            }
        }
    }
}
