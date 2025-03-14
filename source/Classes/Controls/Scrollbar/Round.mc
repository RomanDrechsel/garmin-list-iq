import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

module Controls {
    (:roundVersion)
    class Scrollbar {
        private var _scrollbarWidth = 10;
        private var _layer as LayerDef;
        private static var _startDegree = 35;

        function initialize(layer as LayerDef, width as Number) {
            self._scrollbarWidth = width;
            self._layer = layer;
        }

        function draw(dc as Dc, value as Number, maxvalue as Number, viewport_height as Number) as Void {
            if (maxvalue <= viewport_height) {
                return;
            }

            //background
            var radius = self._layer.getWidth() - self._scrollbarWidth / 2;
            dc.setPenWidth(self._scrollbarWidth);
            dc.setColor(getTheme().ScrollbarBackground, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(self._layer.getX(), self._layer.getY() + self._layer.getHeight() / 2, radius, Graphics.ARC_CLOCKWISE, self._startDegree, -self._startDegree);
            self.drawDot(dc, self._startDegree, radius, self._scrollbarWidth);
            self.drawDot(dc, -self._startDegree, radius, self._scrollbarWidth);

            //calculate thumb
            var scrollbarheight = self._startDegree * 2;
            var thumbHeight = (scrollbarheight * scrollbarheight) / (maxvalue - viewport_height);
            if (thumbHeight < 12) {
                thumbHeight = 12;
            } else if (thumbHeight > scrollbarheight) {
                thumbHeight = scrollbarheight;
            }

            var thumbTop = (value.toFloat() / (maxvalue - viewport_height).toFloat()) * (scrollbarheight - thumbHeight);

            //thumb background
            var startdegree = self._startDegree - thumbTop;
            var enddegree = startdegree - thumbHeight;
            var drawY = thumbTop;

            dc.setColor(getTheme().ScrollbarThumbBorder, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(self._layer.getX(), self._layer.getY() + self._layer.getHeight() / 2, radius, Graphics.ARC_CLOCKWISE, startdegree, enddegree);
            self.drawDot(dc, startdegree, radius, self._scrollbarWidth);
            self.drawDot(dc, enddegree, radius, self._scrollbarWidth);

            //thumb
            var borderwidth = self._scrollbarWidth / 4;
            if (borderwidth < 1) {
                borderwidth = 1;
            }

            thumbHeight -= 2 * borderwidth;
            if (thumbHeight < 4) {
                thumbHeight = 4;
            }

            drawY += borderwidth;

            startdegree = self._startDegree - drawY;
            enddegree = startdegree - thumbHeight;

            var pen = self._scrollbarWidth - 2 * borderwidth;
            dc.setPenWidth(pen);
            dc.setColor(getTheme().ScrollbarThumbColor, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(self._layer.getX(), self._layer.getY() + self._layer.getHeight() / 2, radius, Graphics.ARC_CLOCKWISE, startdegree, enddegree);

            self.drawDot(dc, startdegree, radius, pen);
            self.drawDot(dc, enddegree, radius, pen);
        }

        private function drawDot(dc as Dc, degree as Float, radius as Number, penwidth as Number) as Void {
            var yStart = dc.getHeight() / 2;
            var y = Math.sin(Math.toRadians(degree)) * radius;
            var x = Math.cos(Math.toRadians(degree)) * radius;
            dc.fillCircle(self._layer.getX() + x, self._layer.getY() + yStart - y, penwidth / 2 - 1);
        }
    }
}
