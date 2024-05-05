import Toybox.Lang;
import Toybox.Graphics;

module Views { module Controls
{
    class TitleViewItem extends ViewItem
    {
        function initialize(dc as Dc, title as String)
        {
            ViewItem.initialize(dc, title, null, null, null, 10, -1, null);
            self.Title.Justification = Graphics.TEXT_JUSTIFY_CENTER;
        }

        function draw(dc as Dc, ytop as Number, drawline as Boolean) as Number
        {
            return ViewItem.draw(dc, ytop, false);
        }

        function Clicked(tapy as Number) as Boolean
        {
            return false;
        }
    }
}}