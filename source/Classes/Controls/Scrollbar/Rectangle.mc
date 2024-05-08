import Toybox.Graphics;
import Toybox.Lang;
module Controls {
    module Scrollbar {
        class Rectangle {
            private var _layer as LayerDef;

            function initialize(layer as LayerDef) {
                self._layer = layer;
            }

            function draw(dc as Dc, value as Float, maxvalue as Float, totalheight as Float, viewport as Number) as Void {
                if (totalheight <= viewport) {
                    return;
                }

                //background
                dc.setColor(getTheme().ScrollbarBackground, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(self._layer.getX(), self._layer.getY(), self._layer.getWidth(), self._layer.getHeight());

                var viewratio = viewport / totalheight;
                var thumbHeight = (self._layer.getHeight() * viewratio).toNumber();
                if (thumbHeight < 10) {
                    thumbHeight = 10;
                } else if (thumbHeight > self._layer.getHeight()) {
                    thumbHeight = self._layer.getHeight();
                }

                var posratio = value / maxvalue;
                var thumbY = posratio * self._layer.getHeight();
                thumbY -= thumbHeight * posratio;

                //thumb background
                dc.setColor(getTheme().ScrollbarThumbBorder, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(self._layer.getX(), self._layer.getY() + thumbY, self._layer.getWidth(), thumbHeight, self._layer.getWidth() / 3);

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
                dc.fillRoundedRectangle(self._layer.getX() + borderwidth_x, self._layer.getY() + thumbY + borderwidth_y, self._layer.getWidth() - borderwidth_x * 2, thumbHeight - borderwidth_y * 2, self._layer.getWidth() / 3);
            }
        }
    }
}
