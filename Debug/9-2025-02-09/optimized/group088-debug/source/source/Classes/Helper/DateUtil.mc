using Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Application;
import Toybox.System;

(:glance)
module Helper {
    class DateUtil {
        public static function DatetoString(timestamp as Number or Time.Moment, date_separator as String?) as String {
            var pre____, pre___02d_, pre___ampm_, pre_0, pre_12;
            timestamp /*>moment<*/ = timestamp instanceof Time.Moment ? timestamp : new Time.Moment(timestamp);
            pre_0 = 0;
            var greg = Gregorian /*>Time.Gregorian<*/.info(timestamp /*>moment<*/, pre_0 as Toybox.Time.DateFormat);
            timestamp /*>greg_long<*/ = Gregorian /*>Time.Gregorian<*/.info(timestamp /*>moment<*/, 2 as Toybox.Time.DateFormat);
            var date;
            if (greg.year == Gregorian /*>Time.Gregorian<*/.info(Time.now(), pre_0 as Toybox.Time.DateFormat).year) {
                date = Application.loadResource(Rez.Strings.ListDateFormatShort);
            } else {
                date = Application.loadResource(Rez.Strings.ListDateFormat);
            }

            pre___ampm_ = "%ampm";
            pre___02d_ = "%02d";
            pre____ = " ";
            var nbsp = (0x00a0).toChar().toString();

            date = StringUtil.stringReplace(
                StringUtil.stringReplace(
                    StringUtil.stringReplace(
                        StringUtil.stringReplace(StringUtil.stringReplace(StringUtil.stringReplace(date, "%y", greg.year.toString()), "%M", timestamp /*>greg_long<*/.month), "%m", greg.month.format(pre___02d_)),
                        "%d",
                        greg.day.format(pre___02d_)
                    ),
                    "%D",
                    timestamp /*>greg_long<*/.day_of_week
                ),
                pre____,
                nbsp
            );

            timestamp /*>time<*/ = Application.loadResource(Rez.Strings.ListTimeFormat);

            if (System.getDeviceSettings().is24Hour == true) {
                timestamp /*>time<*/ = StringUtil.stringReplace(StringUtil.stringReplace(timestamp /*>time<*/, "%h", greg.hour.format(pre___02d_)), pre___ampm_, Application.loadResource(Rez.Strings.oclock) as String);
            } else {
                pre_12 = 12;
                var hour = greg.hour % pre_12;
                if (hour == pre_0) {
                    hour = pre_12;
                }
                timestamp /*>time<*/ = StringUtil.stringReplace(timestamp /*>time<*/, "%h", hour.toNumber().toString());
                if (greg.hour < pre_12) {
                    timestamp /*>time<*/ = StringUtil.stringReplace(timestamp /*>time<*/, pre___ampm_, "AM");
                } else {
                    timestamp /*>time<*/ = StringUtil.stringReplace(timestamp /*>time<*/, pre___ampm_, "PM");
                }
            }
            if (date_separator == null) {
                date_separator = pre____;
            }

            return date + date_separator + StringUtil.stringReplace(StringUtil.stringReplace(StringUtil.stringReplace(timestamp /*>time<*/, "%i", greg.min.format(pre___02d_)), "%s", greg.sec.format(pre___02d_)), pre____, nbsp);
        }

        public static function toLogString(time as Number or Time.Moment or Time.Gregorian.Info, offset_seconds as Boolean or Number or Null) as String {
            var pre___02d_;
            if (time instanceof Lang.Number) {
                time = new Time.Moment(time);
            }
            if (time instanceof Time.Moment) {
                time = Gregorian /*>Time.Gregorian<*/.info(time, 0 as Toybox.Time.DateFormat);
            }

            pre___02d_ = "%02d";
            var timezone = "";
            if (offset_seconds != null && (offset_seconds instanceof Lang.Number || offset_seconds == true)) {
                if (offset_seconds instanceof Lang.Boolean) {
                    offset_seconds = self.TimezoneOffset();
                }

                if (offset_seconds != null) {
                    timezone = ((offset_seconds / 3600) % 24).format(pre___02d_) + ((offset_seconds / 60) % 60).format(pre___02d_);
                    if (offset_seconds < 0) {
                        timezone = " -" + timezone;
                    } else {
                        timezone = " +" + timezone;
                    }
                }
            }

            return time.year + "-" + time.month.format(pre___02d_) + "-" + time.day.format(pre___02d_) + "T" + time.hour.format(pre___02d_) + ":" + time.min.format(pre___02d_) + ":" + time.sec.format(pre___02d_) + timezone;
        }

        public static function ShiftTimezoneToGMT(moment as Time.Moment) as Time.Moment {
            var offset_seconds = self.TimezoneOffset();
            if (offset_seconds != null && offset_seconds != 0) {
                return moment.subtract(new Time.Duration(offset_seconds));
            }
            return moment;
        }

        public static function TimezoneOffset() as Number? {
            var offset_seconds = System.getClockTime().timeZoneOffset;
            if (offset_seconds == null && $.isDebug) {
                offset_seconds = 7200;
            }
            return offset_seconds;
        }

        public static function NumDaysForMonth(month as Number, year as Number?) as Number {
            var pre_31, pre_0, pre_1;
            pre_31 = 31;
            pre_0 /*>pre_30<*/ = 30;
            pre_1 = 1;
            month -= pre_1;
            pre_31 /*>days<*/ = [pre_31, 28, pre_31, pre_0 /*>pre_30<*/, pre_31, pre_0 /*>pre_30<*/, pre_31, pre_31, pre_0 /*>pre_30<*/, pre_31, pre_0 /*>pre_30<*/, pre_31];
            if (month == pre_1) {
                pre_0 = 0;
                if (year == null) {
                    year = Gregorian /*>Time.Gregorian<*/.info(Time.now(), pre_0 as Toybox.Time.DateFormat).year;
                }
                return pre_31 /*>days<*/[pre_1] + (year % 4 == pre_0 && (year % 100 != pre_0 || year % 400 == pre_0) ? pre_1 : pre_0);
            } else {
                return pre_31 /*>days<*/[month];
            }
        }
    }
}
