import Toybox.Graphics;
import Toybox.Lang;

module Views { module Controls
{
    class ScrollbarRectangle
    {
        function draw(dc as Dc, value as Float, maxvalue as Float, totalheight as Float, viewport as Number) as Void
        {
            dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
            dc.clear();

            if (totalheight <= viewport)
            {
                return;
            }

            dc.setAntiAlias(true);

            //background
            dc.setColor(getTheme().ScrollbarBackground, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());

            var viewratio = viewport / totalheight;        
            var thumbHeight = (dc.getHeight() * viewratio).toNumber();
            if (thumbHeight < 10)
            {
                thumbHeight = 10;
            }
            else if (thumbHeight > dc.getHeight())
            {
                thumbHeight = dc.getHeight();
            }

            var posratio = value / maxvalue;
            var thumbY = posratio * dc.getHeight();
            thumbY -= thumbHeight * posratio;

            //thumb background
            dc.setColor(getTheme().ScrollbarThumbBorder, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(0, thumbY, dc.getWidth(), thumbHeight, dc.getWidth() / 3);

            //thumb
            var borderwidth_y = thumbHeight / 8;
            if (borderwidth_y < 1)
            {
                borderwidth_y = 1;
            }
            var borderwidth_x = dc.getWidth() / 5;
            if (borderwidth_x < 1)
            {
                borderwidth_x = 1;
            }

            dc.setColor(getTheme().ScrollbarThumbColor, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(borderwidth_x, thumbY + borderwidth_y, dc.getWidth() - (borderwidth_x * 2), thumbHeight - (borderwidth_y * 2), dc.getWidth() / 3);
        }
    }
}}