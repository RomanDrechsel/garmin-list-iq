import Toybox.Lang;
import Toybox.Graphics;

module Controls {
    class LayerDef {
        private var _x as Number;
        private var _y as Number;
        private var _width as Number;
        private var _height as Number;

        public function initialize(x as Number, y as Number, w as Number, h as Number) {
            self._x = x;
            self._y = y;
            self._width = w;
            self._height = h;
        }

        public function getX() as Number {
            return self._x;
        }

        public function getY() as Number {
            return self._y;
        }

        public function getWidth() as Number {
            return self._width;
        }

        public function setWidth(width as Number) {
            self._width = width;
        }

        public function getHeight() as Number {
            return self._height;
        }
    }
}
