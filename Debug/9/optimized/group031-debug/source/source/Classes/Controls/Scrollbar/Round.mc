import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

(:roundVersion)
module Controls {
    class Scrollbar {
        private var _scrollbarWidth = 10;
        private var _layer as LayerDef;
        private static var _startDegree = 35;

        function initialize(layer as LayerDef, width as Number) {
            self._scrollbarWidth = width;
            self._layer = layer;
        }

        function draw(dc as Dc, value as Number, maxvalue as Number, viewport_height as Number) as Void {
            var pen, pre__1, pre_1, pre_2, pre_4;
            if (maxvalue <= viewport_height) {
                return;
            }

            //background
            pre_2 = 2;
            pre_1 = 1;
            pre__1 = -1;
            var radius = self._layer.getWidth() - self._scrollbarWidth / pre_2;
            dc.setPenWidth(self._scrollbarWidth);
            dc.setColor(getTheme().ScrollbarBackground, pre__1 as Toybox.Graphics.ColorValue);
            dc.drawArc(self._layer.getX(), self._layer.getY() + self._layer.getHeight() / pre_2, radius, pre_1 as Toybox.Graphics.ArcDirection, self._startDegree, -self._startDegree);
            self.drawDot(dc, self._startDegree, radius, self._scrollbarWidth);
            self.drawDot(dc, -self._startDegree, radius, self._scrollbarWidth);

            //calculate thumb
            pen /*>scrollbarheight<*/ = self._startDegree * pre_2;
            var thumbHeight = (pen /*>scrollbarheight<*/ * pen /*>scrollbarheight<*/) / (maxvalue - viewport_height);
            if (thumbHeight < 12) {
                thumbHeight = 12;
            } else if (thumbHeight > pen /*>scrollbarheight<*/) {
                thumbHeight = pen /*>scrollbarheight<*/;
            }

            pre_4 = 4;
            value /*>thumbTop<*/ = (value.toFloat() / (maxvalue - viewport_height).toFloat()) * (pen /*>scrollbarheight<*/ - thumbHeight);

            //thumb background
            maxvalue /*>startdegree<*/ = self._startDegree - value /*>thumbTop<*/;
            viewport_height /*>enddegree<*/ = maxvalue /*>startdegree<*/ - thumbHeight;
            dc.setColor(getTheme().ScrollbarThumbBorder, pre__1 as Toybox.Graphics.ColorValue);
            dc.drawArc(self._layer.getX(), self._layer.getY() + self._layer.getHeight() / pre_2, radius, pre_1 as Toybox.Graphics.ArcDirection, maxvalue /*>startdegree<*/, viewport_height /*>enddegree<*/);
            self.drawDot(dc, maxvalue /*>startdegree<*/, radius, self._scrollbarWidth);
            self.drawDot(dc, viewport_height /*>enddegree<*/, radius, self._scrollbarWidth);

            //thumb
            pen /*>borderwidth<*/ = self._scrollbarWidth / pre_4;
            if (pen /*>borderwidth<*/ < pre_1) {
                pen /*>borderwidth<*/ = pre_1;
            }

            thumbHeight -= pen /*>borderwidth<*/ * pre_2;
            if (thumbHeight < pre_4) {
                thumbHeight = pre_4;
            }

            maxvalue /*>startdegree<*/ = self._startDegree - (value /*>thumbTop<*/ + pen /*>borderwidth<*/);
            viewport_height /*>enddegree<*/ = maxvalue /*>startdegree<*/ - thumbHeight;

            pen = self._scrollbarWidth - pen /*>borderwidth<*/ * pre_2;
            dc.setPenWidth(pen);
            dc.setColor(getTheme().ScrollbarThumbColor, pre__1 as Toybox.Graphics.ColorValue);
            dc.drawArc(self._layer.getX(), self._layer.getY() + self._layer.getHeight() / pre_2, radius, pre_1 as Toybox.Graphics.ArcDirection, maxvalue /*>startdegree<*/, viewport_height /*>enddegree<*/);

            self.drawDot(dc, maxvalue /*>startdegree<*/, radius, pen);
            self.drawDot(dc, viewport_height /*>enddegree<*/, radius, pen);
        }

        private function drawDot(dc as Dc, degree as Float, radius as Number, penwidth as Number) as Void {
            dc.fillCircle(self._layer.getX() + Math.cos(Math.toRadians(degree)) * radius, self._layer.getY() + dc.getHeight() / 2 - Math.sin(Math.toRadians(degree)) * radius, penwidth / 2 - 1);
        }
    }
}
