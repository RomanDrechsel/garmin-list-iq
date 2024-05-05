import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Gfx;

module Views { module Controls
{
    class ViewItem
    {
        var Title as MultilineLabel;
        var Subtitle as MultilineLabel = null;
        var BoundObject as Object = null;
        var ItemPosition = -1;
        var ColorOverride = null;
        var VerticalPadding = 0;
       
        static var TitlePadding = 0.01;
        static var SubtitlePadding = 0.05;

        private var _fontOverride = null;
        protected var _verticalPadding = 0;
        protected var _Icon = null;
        protected var _IconWidth = null;
        protected var _X = 0;
        protected var _subX = 0;
        protected var _yTop = -1;
        protected var _Height = -1;
        protected var _Visible = false;

        function initialize(dc as Dc, title as String?, subtitle as String?, obj as Object?, icon as Number or BitmapResource or Null, padding as Number, position as Number, fontoverride as FontResource?)
        {
            var titlepadding = dc.getWidth() * self.TitlePadding;
            self._subX = dc.getWidth() * self.SubtitlePadding;
            self._fontOverride = fontoverride;
            
            self._verticalPadding = padding;
            self.ItemPosition = position;
            
            self.setIcon(dc, icon);

            if (self.Title == null && title != null && title.length() > 0)
            {
                self.Title = new MultilineLabel(dc, title, dc.getWidth() - self._X - (2 * titlepadding) - CustomView.ScrollbarSpace, fontoverride != null ? fontoverride : Fonts.get(Gfx.FONT_NORMAL));
            }
            
            if (subtitle != null && subtitle.length() > 0)
            {
                self.Subtitle = new MultilineLabel(dc, subtitle, dc.getWidth() - (2 * self._subX) - CustomView.ScrollbarSpace, Fonts.get(Gfx.FONT_SMALL));
            }
            self.BoundObject = obj;
        }

        function draw(dc as Dc, ytop as Number, drawline as Boolean) as Number
        {
            var y = ytop + self._verticalPadding;
            var mainfont = self._fontOverride != null ? self._fontOverride : Fonts.get(Gfx.FONT_NORMAL);
            if (self._Icon instanceof String && self._Icon.length() > 0) 
            {                
                var offsety = (Graphics.getFontHeight(mainfont) - dc.getFontHeight(Fonts.get(Gfx.FONT_ICON))) / 2;
                dc.setColor(getTheme().MainColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(self._IconWidth * 0.4, y + offsety, Fonts.get(Gfx.FONT_ICON), self._Icon, Graphics.TEXT_JUSTIFY_LEFT);
            }
            else if (self._Icon != null)
            {
                var offsety = (Graphics.getFontHeight(mainfont) - self._Icon.getHeight()) / 2;
                dc.drawBitmap(self._Icon.getWidth() * 0.4, y + offsety, self._Icon);
            }

            if (self.Title != null)
            {
                y += self.Title.drawText(dc, self._X, y, (self.ColorOverride != null ? self.ColorOverride : getTheme().MainColor));
            }

            if (self.Subtitle != null)
            {
                y += Graphics.getFontAscent(Fonts.get(Gfx.FONT_SMALL)) / 3; //space between title and subtitle
                y += self.Subtitle.drawText(dc, self._subX, y, (self.ColorOverride != null ? self.ColorOverride : getTheme().SecondColor));
                y += 12; //space between subtitle and lower line
            }
            else
            {
                y += 5;
            }

            y += self._verticalPadding;
            if (drawline)
            {
                y = self.drawLine(dc, y);
            }

            self.setBoundaries(ytop, y);
            self._Visible = true;

            //return lower y of lower edge of item
            return y;
        }

        function setBoundaries(top as Number, bottom as Number)
        {
            self._yTop = top;
            if (bottom > top)
            {
                self._Height = bottom - top;
            }
            else if (top == bottom)
            {
                self._Visible = false;
            }
        }

        function getHeight() as Number
        {
            if (self._Height < 0)
            {
                self._Height = 0;
                if (self.Title != null)
                {
                    self._Height += self.Title.getHeight();
                }
                if (self.Subtitle != null)
                {
                    self._Height += Graphics.getFontAscent(Fonts.get(Gfx.FONT_SMALL)) / 3;
                    self._Height += self.Subtitle.getHeight();
                    self._Height += 12;
                }
                else
                {
                    self._Height += 5;
                }
                self._Height += self._verticalPadding * 2;

                if (getTheme().LineBitmap != null)
                {
                    self._Height += getTheme().LineBitmap.getHeight();
                }
                else if (getTheme().LineSeparatorColor != null)
                {
                    self._Height += 2;
                }
            }
            
            return self._Height;
        }

        function setIcon(dc as Dc, icon as Number or BitmapResource or Null) as Void
        {
            if (icon instanceof Number && icon >= 0)
            {
                self._Icon = icon.toChar().toString();
                self._IconWidth = dc.getTextWidthInPixels(self._Icon, Fonts.get(Gfx.FONT_ICON));
                self._X = self._IconWidth * 1.8;
            }
            else if (icon != null)
            {
                self._Icon = icon;
                self._X = icon.getWidth() * 1.8;
            }
            else
            {
                self._Icon = null;
            }
        }

        function Clicked(tapy as Number) as Boolean
        {
            if (self._Visible == false)
            {
                //not visible, null or negative height
                return false;
            }
            
            if (tapy >= self._yTop && tapy <= self._yTop + self._Height)
            {
                return true;
            }

            return false;
        }

        protected function drawLine(dc as Dc, y as Number) as Number
        {
            var line = getTheme().LineBitmap;
            if (line != null)
            {
                var x = (dc.getWidth() - line.getWidth()) / 2;
                dc.drawBitmap(x, y, line);
                y += line.getHeight();
            }
            else if (getTheme().LineSeparatorColor != null)
            {
                dc.setColor(getTheme().LineSeparatorColor, Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(2);
                dc.drawLine(0, y, dc.getWidth(), y);
                y += 2;
            }

            return y;
        }
    }
}}