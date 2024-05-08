import Toybox.Lang;
import Toybox.Graphics;
import Helper;

module Controls {
    class ButtonViewItem extends ViewItem {
        private var _padding as Number = 10;
        private static var TitlePaddingFactor = 0.1;

        function initialize(layer as LayerDef, title as String, identifier as Object, padding as Number) {
            self._padding = (layer.getWidth() * 0.03).toNumber();
            var maxwidth = layer.getWidth() - 2 * layer.getWidth() * self.TitlePaddingFactor - CustomView.ScrollbarSpace - 2 * self._padding;
            self.Title = new MultilineLabel(title, maxwidth.toNumber(), Fonts.Normal());
            self.Title.Justification = Graphics.TEXT_JUSTIFY_CENTER;

            ViewItem.initialize(layer, title, null, identifier, null, padding, -1, null);
        }

        function draw(dc as Dc, ytop as Number, drawline as Boolean) as Number {
            var y = ytop + self._verticalPadding;

            self.drawBackground(dc, y);

            var marginX = self._Layer.getWidth() * self.TitlePaddingFactor + self._padding;

            y += self._padding;
            y += self.Title.drawText(dc, marginX, y, self.ColorOverride != null ? self.ColorOverride : getTheme().MainColor);
            y += self._padding;
            y += self._verticalPadding;

            if (drawline) {
                y = self.drawLine(dc, y);
            }

            self.setBoundaries(ytop, y);
            self._Visible = true;
            return y;
        }

        function getHeight(dc as Dc) as Number {
            if (self._Height < 0) {
                self._Height = ViewItem.getHeight(dc) + 2 * self._padding;
            }

            return self._Height;
        }

        private function drawBackground(dc as Dc, ytop as Number) as Void {
            var marginX = self._Layer.getWidth() * self._padding;
            dc.setColor(getTheme().ButtonBackground, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(marginX, ytop, self._Layer.getWidth() - 2 * self._Layer.getWidth() * self.TitlePaddingFactor, self.Title.getHeight(dc) + 2 * self._padding + Graphics.getFontDescent(Fonts.Normal()), self._padding * 0.5);

            dc.setColor(getTheme().ButtonBorder, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(2);
            dc.drawRoundedRectangle(marginX, ytop, self._Layer.getWidth() - 2 * self._Layer.getWidth() * self.TitlePaddingFactor, self.Title.getHeight(dc) + 2 * self._padding + Graphics.getFontDescent(Fonts.Normal()), self._padding * 0.5);
        }
    }
}
