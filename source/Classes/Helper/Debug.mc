import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Time;

module Debug {
    class DebugStorage {
        private static var _lastLogs as Array<String> = [];

        public static function AddLog(log as String) {
            self._lastLogs.add(log);
            if (self._lastLogs.size() > 50) {
                self._lastLogs.remove(self._lastLogs[0]);
            }
        }

        public static function GetLogs() as Array<String> {
            return self._lastLogs.addAll($.getApp().getInfo());
        }
    }

    function Log(obj as Object) {
        var info = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var str = info.year + "-" + info.month.format("%02d") + "-" + info.day.format("%02d") + " " + info.hour.format("%02d") + ":" + info.min.format("%02d") + ":" + info.sec.format("%02d");
        Toybox.System.println(str + ": " + obj);
        DebugStorage.AddLog(str + ": " + obj);
    }

    (:debug)
    function Box(dc as Dc, x as Number, y as Number, w as Number, h as Number, c as ColorValue?) {
        if (c == null) {
            c = Graphics.COLOR_RED;
        }
        dc.setColor(c, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawRectangle(x, y, w, h);
    }
    (:release)
    function Box(dc as Dc, x as Number, y as Number, w as Number, h as Number, c as Number) {}
}
