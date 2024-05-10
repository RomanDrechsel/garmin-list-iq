import Toybox.Lang;
import Toybox.Graphics;

module Controls {
    class TitleViewItem extends ViewItem {
        function initialize(layer as LayerDef, title as String) {
            ViewItem.initialize(layer, title, null, null, null, 10, -1, null);
        }

        function draw(dc as Dc, ytop as Number, drawline as Boolean) as Number {
            return ViewItem.draw(dc, ytop, false);
        }

        function Clicked(tapy as Number) as Boolean {
            return false;
        }

        protected function validate(dc as Dc) {
            ViewItem.validate(dc);
            if (self.Title instanceof MultilineLabel) {
                self.Title.Justification = Graphics.TEXT_JUSTIFY_CENTER;
            }
        }
    }
}
