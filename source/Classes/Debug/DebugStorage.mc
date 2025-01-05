import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Time;
import Toybox.Application;

module Debug {
    class DebugStorage {
        private var _logs as Array<String> = [];
        public var LogCount = 100;
        public var _totalCount = 0;
        private var _persistentLogs = false;
        private var _storeLogs = false;

        public function initialize() {
            self.onSettingsChanged();
            if (self._persistentLogs) {
                try {
                    self._logs = Application.Storage.getValue("logs");
                } catch (ex instanceof Lang.Exception) {
                    self._logs = [] as Array<String>;
                }
                if (!(self._logs instanceof Array)) {
                    self._logs = [] as Array<String>;
                }
                self._totalCount = self._logs.size();
            }
        }

        public function AddLog(log as String or Array<String>) {
            if (self._storeLogs == true) {
                if (log instanceof String) {
                    self._logs.add(log);
                    self._totalCount++;
                } else {
                    self._logs.addAll(log);
                    self._totalCount += log.size();
                }

                if (self._logs.size() > self.LogCount) {
                    self._logs = self._logs.slice(self._logs.size() - self.LogCount, self._logs.size());
                }

                if (self._persistentLogs == true) {
                    Application.Storage.setValue("logs", self._logs);
                }
            } else {
                self._logs = [];
                self._totalCount = 0;
            }
        }

        public function GetLogs() as Array<String> {
            if (self._totalCount > self.LogCount) {
                return $.getApp().getInfo().addAll(self._logs);
            } else {
                if (self._storeLogs == false) {
                    return ["Logs disabled"];
                } else {
                    return self._logs;
                }
            }
        }

        public function SendLogs() {
            $.getApp().Phone.SendToPhone({ "type" => "logs", "logs" => self.GetLogs() });
            self.Log("Sent logs to smartphone");
        }

        public function onSettingsChanged() {
            self._storeLogs = Helper.Properties.Get(Helper.Properties.LOGS, true) as Boolean;
            self._persistentLogs = Helper.Properties.Get(Helper.Properties.PERSISTENTLOGS, true) as Boolean;
            if (self._storeLogs == false || self._persistentLogs == false) {
                Application.Storage.deleteValue("logs");
            }

            if (self._storeLogs == false) {
                self._logs = [] as Array<String>;
            }
        }
    }

    function Log(obj as Lang.Object) {
        var info = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var date = Helper.DateUtil.toLogString(info, null);

        if (obj instanceof Lang.Array) {
            for (var i = 0; i < obj.size(); i++) {
                if (obj[i] instanceof Lang.String) {
                    obj[i] = date + ": " + obj[i];
                }
                Toybox.System.println(obj[i]);
            }
            $.getApp().Debug.AddLog(obj);
        } else {
            Toybox.System.println(date + ": " + obj);
            $.getApp().Debug.AddLog(date + ": " + obj);
        }
    }

    (:debug,:glance)
    function Box(dc as Dc, x as Number, y as Number, w as Number, h as Number, c as ColorValue?) {
        if (c == null) {
            c = Graphics.COLOR_RED;
        }
        dc.setColor(c, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawRectangle(x, y, w, h);
    }
    (:release,:glance)
    function Box(dc as Dc, x as Number, y as Number, w as Number, h as Number, c as Number) {}
}
