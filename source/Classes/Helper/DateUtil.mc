import Toybox.Lang;
import Toybox.Time;
import Toybox.Application;
import Toybox.System;

module Helper {
    class DateUtil {
        static function toString(timestamp as Number or Time.Moment, date_separator as String?) as String {
            var moment = timestamp instanceof Time.Moment ? timestamp : new Time.Moment(timestamp);
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
                var hour = greg.hour % 12;
                if (hour == 0) {
                    hour = 12;
                }
                time = StringUtil.stringReplace(time, "%h", hour.toNumber().toString());
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

        static function TimezoneOffset(moment as Time.Moment) as Time.Moment {
            var offset_seconds = System.ClockTime.timeZoneOffset;
            offset_seconds = 7200;
            if (offset_seconds != null && offset_seconds != 0) {
                return moment.subtract(new Time.Duration(offset_seconds));
            }
            return moment;
        }
    }
}
