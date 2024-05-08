import Toybox.Lang;
import Toybox.Time;
import Toybox.Application;
import Toybox.System;

module Helper {
    class DateUtil {
        static function toString(timestamp as Number, date_separator as String?) as String {
            var moment = new Time.Moment(timestamp);
            var greg = Time.Gregorian.info(moment, Time.Gregorian.FORMAT_SHORT);
            var greg_long = Time.Gregorian.info(moment, Time.Gregorian.FORMAT_LONG);
            var greg_now = Time.Gregorian.info(Time.now(), Time.Gregorian.FORMAT_SHORT);

            var date;
            if (greg.year == greg_now.year) {
                date = Application.loadResource(Rez.Strings.ListDateFormatShort);
            } else {
                date = Application.loadResource(Rez.Strings.ListDateFormat);
            }

            var nbsp = (0x00a0).toChar().toString();

            date = StringUtil.stringReplace(date, "%y", greg.year.toString());
            date = StringUtil.stringReplace(date, "%M", greg_long.month);
            date = StringUtil.stringReplace(date, "%m", greg.month);
            date = StringUtil.stringReplace(date, "%d", greg.day.format("%02d"));
            date = StringUtil.stringReplace(date, "%D", greg_long.day_of_week);
            date = StringUtil.stringReplace(date, " ", nbsp);

            var time = Application.loadResource(Rez.Strings.ListTimeFormat);

            if (System.getDeviceSettings().is24Hour == true) {
                time = StringUtil.stringReplace(time, "%h", greg.hour.format("%02d"));
                var suffix = Application.loadResource(Rez.Strings.oclock) as String;
                time = StringUtil.stringReplace(time, "%ampm", suffix);
            } else {
                time = StringUtil.stringReplace(time, "%h", (greg.hour % 12).format("%02d"));
                if (greg.hour < 12) {
                    time = StringUtil.stringReplace(time, "%ampm", "AM");
                } else {
                    time = StringUtil.stringReplace(time, "%ampm", "PM");
                }
            }
            time = StringUtil.stringReplace(time, "%i", greg.min.format("%02d"));
            time = StringUtil.stringReplace(time, "%s", greg.sec.format("%02d"));
            time = StringUtil.stringReplace(time, " ", nbsp);

            if (date_separator == null) {
                date_separator = " ";
            }

            return date + date_separator + time;
        }

        private static function AMPM(hour as Number) as String {
            if (hour < 12) {
                return "AM";
            } else {
                return "PM";
            }
        }
    }
}
