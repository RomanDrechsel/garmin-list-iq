import Toybox.Lang;
import Toybox.Graphics;

module Controls {
    class LayerDef {
        public var X as Number;
        public var Y as Number;
        public var Width as Number;
        public var Height as Number;

        public function initialize(x as Number, y as Number, w as Number, h as Number) {
            self.X = x;
            self.Y = y;
            self.Width = w;
            self.Height = h;
        }
    }
}
