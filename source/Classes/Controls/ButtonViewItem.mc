import Toybox.Lang;
import Toybox.Graphics;
import Gfx;

module Views { module Controls
{
    class ButtonViewItem extends ViewItem
    {
        private var _textPadding = 10;
        private static var TitlePadding = 0.1;

        function initialize(dc as Dc, title as String, identifier as Object, padding as Number)
        {
            self._textPadding = dc.getWidth() * 0.03;
            self.Title = new MultilineLabel(dc, title, dc.getWidth() - self._X - (2 * dc.getWidth() * self.TitlePadding) - CustomView.ScrollbarSpace - (2 * self._textPadding), Fonts.get(Gfx.FONT_NORMAL));
            self.Title.Justification = Graphics.TEXT_JUSTIFY_CENTER;

            ViewItem.initialize(dc, title, null, identifier, null, padding, -1, null);
        }

        function draw(dc as Dc, ytop as Number, drawline as Boolean) as Number
        {
            var y = ytop + self._verticalPadding;

            self.drawBackground(dc, y);

            var marginX = self._X + (dc.getWidth() * self.TitlePadding) + self._textPadding;

            y += self._textPadding;
            y += self.Title.drawText(dc, marginX, y, (self.ColorOverride != null ? self.ColorOverride : getTheme().MainColor));
            y += self._textPadding;
            y += self._verticalPadding;

            if (drawline)
            {
                y = self.drawLine(dc, y);
            }

            self.setBoundaries(ytop, y);
            self._Visible = true;
            return y;
        }

        function getHeight() as Number
        {
            if (self._Height < 0)
            {
                self._Height = ViewItem.getHeight() + (2 * self._textPadding);
            }

            return self._Height;
        }

        private function drawBackground(dc as Dc, ytop as Number) as Void
        {
            var marginX = self._X + (dc.getWidth() * self.TitlePadding);
            dc.setColor(getTheme().ButtonBackground, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(marginX, ytop, dc.getWidth() - self._X - (2 * dc.getWidth() * self.TitlePadding) - CustomView.ScrollbarSpace, self.Title.getHeight() + (2 * self._textPadding) + Graphics.getFontDescent(Fonts.get(Gfx.FONT_NORMAL)), self._textPadding * 0.5);

            dc.setColor(getTheme().ButtonBorder, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(2);
            dc.drawRoundedRectangle(marginX, ytop, dc.getWidth() - self._X - (2 * dc.getWidth() * self.TitlePadding) - CustomView.ScrollbarSpace, self.Title.getHeight() + (2 * self._textPadding) + Graphics.getFontDescent(Fonts.get(Gfx.FONT_NORMAL)), self._textPadding * 0.5);
        }
    }
}}