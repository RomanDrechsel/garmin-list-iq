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
            var pre__1, pre_1;
            if (maxvalue <= viewport_height) {
                return;
            }

            //background
            pre__1 = -1;
            dc.setColor(getTheme().ScrollbarBackground, pre__1 as Toybox.Graphics.ColorValue);
            dc.fillRectangle(self._layer.getX(), self._layer.getY(), self._layer.getWidth(), self._layer.getHeight());

            var thumbHeight = (self._layer.getHeight() * self._layer.getHeight()) / maxvalue;
            if (thumbHeight < 10) {
                thumbHeight = 10;
            } else if (thumbHeight > self._layer.getHeight()) {
                thumbHeight = self._layer.getHeight();
            }

            pre_1 = 1;
            viewport_height /*>thumbTop<*/ = (value.toFloat() / (maxvalue - viewport_height).toFloat()) * (self._layer.getHeight() - thumbHeight);

            //thumb background
            dc.setColor(getTheme().ScrollbarThumbBorder, pre__1 as Toybox.Graphics.ColorValue);
            dc.fillRoundedRectangle(self._layer.getX(), self._layer.getY() + viewport_height /*>thumbTop<*/, self._layer.getWidth(), thumbHeight, self._layer.getWidth() / 3);

            //thumb
            maxvalue /*>borderwidth_y<*/ = thumbHeight / 8;
            if (maxvalue /*>borderwidth_y<*/ < pre_1) {
                maxvalue /*>borderwidth_y<*/ = pre_1;
            }
            value /*>borderwidth_x<*/ = self._layer.getWidth() / 5;
            if (value /*>borderwidth_x<*/ < pre_1) {
                value /*>borderwidth_x<*/ = pre_1;
            }

            dc.setColor(getTheme().ScrollbarThumbColor, pre__1 as Toybox.Graphics.ColorValue);
            dc.fillRoundedRectangle(
                self._layer.getX() + value /*>borderwidth_x<*/,
                self._layer.getY() + viewport_height /*>thumbTop<*/ + maxvalue /*>borderwidth_y<*/,
                self._layer.getWidth() - value /*>borderwidth_x<*/ * 2,
                thumbHeight - maxvalue /*>borderwidth_y<*/ * 2,
                self._layer.getWidth() / 3
            );
        }
    }
}
