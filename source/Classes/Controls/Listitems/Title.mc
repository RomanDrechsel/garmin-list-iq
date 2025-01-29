import Toybox.Lang;
import Toybox.Graphics;

module Controls {
    module Listitems {
        class Title extends Item {
            function initialize(layer as LayerDef?, title as String) {
                Item.initialize(layer, title, null, null, null, 10, -1, null);
                self.TitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
                self.DrawLine = false;
                self.isSelectable = false;
            }

            function Clicked(tapy as Number, scrollOffset as Number) as Boolean {
                return false;
            }

            function draw(dc as Dc, scrollOffset as Number, isSelected as Boolean) as Number {
                var height = Item.draw(dc, scrollOffset, false);
                dc.setColor($.getTheme().TitleSeparatorColor, $.getTheme().TitleSeparatorColor);
                dc.fillRectangle(0, self._listY - scrollOffset + self._layer.getY() + height - 2, dc.getWidth(), 2);
            }
        }
    }
}
