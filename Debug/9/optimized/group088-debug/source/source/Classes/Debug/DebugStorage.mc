using Toybox.System;
using Toybox.Time.Gregorian;
using Helper;
using Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Time;
import Toybox.Application;

(:glance)
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
                    self._logs = Storage /*>Application.Storage<*/.getValue("logs");
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
            var pre__logs;
            if (self._storeLogs == true) {
                pre__logs = self._logs;
                if (log instanceof String) {
                    pre__logs.add(log);
                    self._totalCount += 1;
                } else {
                    pre__logs.addAll(log);
                    self._totalCount += log.size();
                }

                if (pre__logs.size() > self.LogCount) {
                    pre__logs = self._logs.slice(-self.LogCount, null);
                    self._logs = pre__logs;
                }

                if (self._persistentLogs == true) {
                    Storage /*>Application.Storage<*/.setValue("logs", pre__logs);
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
            if ($.getApp().Phone != null) {
                var send = ["type=logs"];
                var logs = self.GetLogs();
                for (var i = 0; i < logs.size(); i += 1) {
                    send.add(i + "=" + logs[i]);
                }
                $.getApp().Phone.SendToPhone(send);
                self.Log("Sent logs to smartphone");
            }
        }

        public function onSettingsChanged() {
            var pre__storeLogs;
            self._storeLogs = Helper.Properties.Get("Logs", true) as Boolean;
            self._persistentLogs = Helper.Properties.Get("PersistentLogs", true) as Boolean;
            pre__storeLogs = self._storeLogs;
            if (pre__storeLogs == false || self._persistentLogs == false) {
                Storage /*>Application.Storage<*/.deleteValue("logs");
            }

            if (pre__storeLogs == false) {
                self._logs = [] as Array<String>;
            }
        }
    }

    function Log(obj as Lang.Object) {
        var debug_0, pre_____;
        pre_____ = ": ";
        var date = Helper.DateUtil.toLogString(Gregorian /*>Time.Gregorian<*/.info(Time.now(), 0 as Toybox.Time.DateFormat), null);

        if (obj instanceof Lang.Array) {
            {
                debug_0 /*>i<*/ = 0;
                for (; debug_0 /*>i<*/ < obj.size(); debug_0 /*>i<*/ += 1) {
                    if (obj[debug_0 /*>i<*/] instanceof Lang.String) {
                        obj[debug_0 /*>i<*/] = date + pre_____ + obj[debug_0 /*>i<*/];
                    }
                    System /*>Toybox.System<*/.println(obj[debug_0 /*>i<*/]);
                }
            }
            debug_0 /*>debug<*/ = $.getApp().Debug;
            if (debug_0 /*>debug<*/ != null) {
                debug_0 /*>debug<*/.AddLog(obj);
            }
        } else {
            System /*>Toybox.System<*/.println(date + pre_____ + obj);
            debug_0 /*>debug<*/ = $.getApp().Debug;
            if (debug_0 /*>debug<*/ != null) {
                debug_0 /*>debug<*/.AddLog(date + pre_____ + obj);
            }
        }
    }
}
