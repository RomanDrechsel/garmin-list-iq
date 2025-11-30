import Toybox.Graphics;
import Toybox.Lang;

(:regularVersion)
module Controls {
    class Scrollbar {
        private var _layer as LayerDef;

        function initialize(layer as LayerDef, width as Number) {
            self._layer = layer;
        }

        function draw(dc as Dc, value as Number, maxvalue as Number, viewport_height as Number) {
            if (maxvalue <= viewport_height) {
                return;
            }

            //background
            dc.setColor(getTheme().ScrollbarBackground, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(self._layer.X, self._layer.Y, self._layer.Width, self._layer.Height);

            var thumbHeight = (self._layer.Height * self._layer.Height) / maxvalue;
            if (thumbHeight < 10) {
                thumbHeight = 10;
            } else if (thumbHeight > self._layer.Height) {
                thumbHeight = self._layer.Height;
            }

            var thumbTop = (value.toFloat() / (maxvalue - viewport_height).toFloat()) * (self._layer.Height - thumbHeight);

            //thumb background
            dc.setColor(getTheme().ScrollbarThumbBorder, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(self._layer.X, self._layer.Y + thumbTop, self._layer.Width, thumbHeight, self._layer.Width / 3);

            //thumb
            var borderwidth_y = thumbHeight / 8;
            if (borderwidth_y < 1) {
                borderwidth_y = 1;
            }
            var borderwidth_x = self._layer.Width / 5;
            if (borderwidth_x < 1) {
                borderwidth_x = 1;
            }

            dc.setColor(getTheme().ScrollbarThumbColor, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(self._layer.X + borderwidth_x, self._layer.Y + thumbTop + borderwidth_y, self._layer.Width - borderwidth_x * 2, thumbHeight - borderwidth_y * 2, self._layer.Width / 3);
        }
    }
}
