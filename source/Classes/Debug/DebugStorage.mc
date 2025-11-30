import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Time;
import Toybox.Application;

module Debug {
    class DebugStorage {
        private var _logs as Array<String>? = null;
        private var _persistentLogs = false;
        private var _storeLogs = false;

        public function initialize() {
            self.onSettingsChanged();
            if (self._persistentLogs) {
                try {
                    self._logs = Application.Storage.getValue("logs") as Array<String>?;
                } catch (ex instanceof Lang.Exception) {
                    self._logs = [] as Array<String>;
                }
                if (!(self._logs instanceof Array)) {
                    self._logs = [] as Array<String>;
                }
            }
        }

        public function AddLog(log as String or Array<String>) {
            if (self._storeLogs == true) {
                if (self._logs == null) {
                    self._logs = [];
                }
                if (log instanceof String) {
                    self._logs.add(log);
                } else {
                    self._logs.addAll(log);
                }

                var logCount = 50;
                if (self._logs.size() > logCount) {
                    self._logs = self._logs.slice(-logCount, null);
                }

                if (self._persistentLogs == true) {
                    Application.Storage.setValue("logs", self._logs);
                }
            } else {
                self._logs = null;
            }
        }

        public function GetLogs() as Array<String> {
            if (self._storeLogs == false) {
                return ["Logs disabled"];
            } else {
                return $.getApp()
                    .getInfo()
                    .addAll(self._logs == null ? [] : self._logs);
            }
        }

        public function SendLogs() {
            var phone = $.getApp().Phone;
            if (phone != null) {
                self.Log("Sent logs to smartphone");
                var send = ["type=logs"];
                var logs = self.GetLogs();
                for (var i = 0; i < logs.size(); i++) {
                    send.add(i + "=" + logs[i]);
                }
                phone.SendToPhone(send);
            }
        }

        public function onSettingsChanged() {
            self._storeLogs = Helper.Properties.Get(Helper.Properties.LOGS, true) as Boolean;
            self._persistentLogs = Helper.Properties.Get(Helper.Properties.PERSISTENTLOGS, false) as Boolean;
            if (self._storeLogs == false || self._persistentLogs == false) {
                Application.Storage.deleteValue("logs");
            }

            if (self._storeLogs == false) {
                self._logs = null;
            }
        }
    }

    (:glance,:background)
    function Log(obj as Lang.Object) {
        var info = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var date = Helper.DateUtil.toLogString(info, null);
        var app = $.getApp();
        var prefix = "";

        if (app.AppType == ListsApp.BACKGROUND) {
            prefix = "[B] ";
        } else if (app.AppType == ListsApp.GLANCE) {
            prefix = "[G] ";
        }

        var debug = $.getApp().Debug;
        if (obj instanceof Lang.Array) {
            for (var i = 0; i < obj.size(); i++) {
                if (obj[i] instanceof Lang.String) {
                    obj[i] = date + ": " + prefix + obj[i];
                }
                Toybox.System.println(obj[i]);
            }
        } else {
            obj = date + ": " + prefix + obj.toString();
            Toybox.System.println(obj);
        }
        if (debug != null) {
            debug.AddLog(obj);
        }
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
    function Box(dc as Dc, x as Number, y as Number, w as Number, h as Number, c as ColorValue?) {}

    (:debug)
    var isDebug = true;
    (:release)
    var isDebug = false;
}
