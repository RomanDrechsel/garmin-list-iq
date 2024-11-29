import Toybox.Lang;
import Toybox.Time;
import Toybox.Application;
import Toybox.System;

module Helper {
    class DateUtil {
        public static function toString(timestamp as Number or Time.Moment, date_separator as String?) as String {
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
            date = StringUtil.stringReplace(date, "%m", greg.month.format("%02d"));
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

        public static function toLogString(time as Number or Time.Moment or Time.Gregorian.Info, offset_seconds as Boolean or Number or Null) as String {
            if (time instanceof Lang.Number) {
                time = new Time.Moment(time);
            }
            if (time instanceof Time.Moment) {
                time = Time.Gregorian.info(time, Time.FORMAT_SHORT);
            }

            var timezone = "";
            if (offset_seconds != null && (offset_seconds instanceof Lang.Number || offset_seconds == true)) {
                if (offset_seconds instanceof Lang.Boolean && offset_seconds == true) {
                    offset_seconds = self.TimezoneOffset();
                }

                if (offset_seconds != null) {
                    timezone = ((offset_seconds / 3600) % 24).format("%02d") + ((offset_seconds / 60) % 60).format("%02d");
                    if (offset_seconds < 0) {
                        timezone = " -" + timezone;
                    } else {
                        timezone = " +" + timezone;
                    }
                }
            }

            return time.year + "-" + time.month.format("%02d") + "-" + time.day.format("%02d") + "T" + time.hour.format("%02d") + ":" + time.min.format("%02d") + ":" + time.sec.format("%02d") + timezone;
        }

        public static function ShiftTimezoneToGMT(moment as Time.Moment) as Time.Moment {
            var offset_seconds = self.TimezoneOffset();
            if (offset_seconds != null && offset_seconds != 0) {
                return moment.subtract(new Time.Duration(offset_seconds));
            }
            return moment;
        }

        public static function TimezoneOffset() as Number? {
            var offset_seconds = System.ClockTime.timeZoneOffset;
            if (offset_seconds == null && $.isDebug) {
                offset_seconds = 7200;
            }
            return offset_seconds;
        }

        public static function NumDaysForMonth(month as Number, year as Number?) as Number {
            month -= 1;
            var days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
            if (month == 1) {
                if (year == null) {
                    year = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT).year;
                }
                var leap = year % 4 == 0 && (year % 100 != 0 || year % 400 == 0) ? 1 : 0;
                return days[month] + leap;
            } else {
                return days[month];
            }
        }
    }
}
