import Toybox.Graphics;
import Toybox.Lang;
module Controls {
    module Scrollbar {
        class Rectangle {
            private var _layer as LayerDef;

            function initialize(layer as LayerDef) {
                self._layer = layer;
            }

            function draw(dc as Dc, value as Number, maxvalue as Number) {
                if (maxvalue <= 0) {
                    return;
                }

                //background
                dc.setColor(getTheme().ScrollbarBackground, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(self._layer.getX(), self._layer.getY(), self._layer.getWidth(), self._layer.getHeight());

                var thumbHeight = (self._layer.getHeight() * self._layer.getHeight()) / maxvalue;
                if (thumbHeight < 10) {
                    thumbHeight = 10;
                } else if (thumbHeight > self._layer.getHeight()) {
                    thumbHeight = self._layer.getHeight();
                }

                var thumbTop = (value.toFloat() / maxvalue.toFloat()) * (self._layer.getHeight() - thumbHeight);

                //thumb background
                dc.setColor(getTheme().ScrollbarThumbBorder, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(self._layer.getX(), self._layer.getY() + thumbTop, self._layer.getWidth(), thumbHeight, self._layer.getWidth() / 3);

                //thumb
                var borderwidth_y = thumbHeight / 8;
                if (borderwidth_y < 1) {
                    borderwidth_y = 1;
                }
                var borderwidth_x = self._layer.getWidth() / 5;
                if (borderwidth_x < 1) {
                    borderwidth_x = 1;
                }

                dc.setColor(getTheme().ScrollbarThumbColor, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(self._layer.getX() + borderwidth_x, self._layer.getY() + thumbTop + borderwidth_y, self._layer.getWidth() - borderwidth_x * 2, thumbHeight - borderwidth_y * 2, self._layer.getWidth() / 3);
            }
        }
    }
}
