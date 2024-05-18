import Toybox.Lang;
import Toybox.Graphics;

(:debug)
module Debug {
    function Log(str as String) {
        Toybox.System.println(str);
    }

    function Box(dc as Dc, x as Number, y as Number, w as Number, h as Number, c as ColorValue?) {
        if (c == null) {
            c = Graphics.COLOR_RED;
        }
        dc.setColor(c, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawRectangle(x, y, w, h);
    }
}

(:release)
module Debug {
    function Log(str as String) {}
    function Box(dc as Dc, x as Number, y as Number, w as Number, h as Number, c as Number) {}
}
