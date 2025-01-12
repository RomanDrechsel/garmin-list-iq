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
        }
    }
}
