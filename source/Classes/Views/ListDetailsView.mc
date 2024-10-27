import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Time;
import Toybox.System;
import Lists;
import Controls;
import Controls.Listitems;
import Helper;

module Views {
    class ListDetailsView extends Controls.CustomView {
        var ScrollMode = SCROLL_DRAG;

        var ListUuid as String? = null;
        private var _listFound = false;
        private var _listOptimized = false;

        private var _noListLabel as MultilineLabel? = null;
        private var _itemIcon as Listitems.ViewItemIcon;
        private var _itemIconDone as Listitems.ViewItemIcon;

        protected var _fontoverride = Fonts.Large();

        function initialize(uuid as String) {
            CustomView.initialize();
            self.ListUuid = uuid;
            self._itemIcon = $.getTheme().DarkTheme ? Application.loadResource(Rez.Drawables.Item) : Application.loadResource(Rez.Drawables.bItem);
            self._itemIconDone = $.getTheme().DarkTheme ? Application.loadResource(Rez.Drawables.ItemDone) : Application.loadResource(Rez.Drawables.bItemDone);
        }

        function onLayout(dc as Dc) {
            CustomView.onLayout(dc);
        }

        function onShow() as Void {
            CustomView.onShow();
            $.getApp().ListsManager.OnListsChanged.add(self);
            self.publishItems(true);
        }

        function onHide() as Void {
            CustomView.onHide();
            $.getApp().ListsManager.OnListsChanged.remove(self);
        }

        function onUpdate(dc as Dc) as Void {
            CustomView.onUpdate(dc);
            dc.setColor(getTheme().BackgroundColor, getTheme().BackgroundColor);
            dc.clear();

            if (self._listFound == false || self.Items.size() == 0) {
                self.noLists(dc);
            } else {
                self.drawList(dc);

                //store the wraped text
                if (self._listOptimized == false) {
                    var optimized1 = ({}) as Dictionary<Number, Array<String> >;
                    var optimized2 = ({}) as Dictionary<Number, Array<String> >;
                    for (var i = 0; i < self.Items.size(); i++) {
                        var item = self.Items[i];
                        if (item instanceof Listitems.Item) {
                            var text = item.Title instanceof MultilineLabel ? item.Title.getText() : null;
                            var note = item.Subtitle instanceof MultilineLabel ? item.Subtitle.getText() : null;
                            if (text instanceof Array) {
                                if (text.size() == 1) {
                                    text = text[0];
                                }
                                optimized1.put(item.ItemPosition, text);
                            }
                            if (note instanceof Array) {
                                if (note.size() == 1) {
                                    note = note[0];
                                }
                                optimized2.put(item.ItemPosition, note);
                            }
                        }
                    }
                    if (optimized1.size() > 0) {
                        $.getApp().ListsManager.Optimize(self.ListUuid, optimized1, optimized2);
                    }
                    self._listOptimized = true;
                }
            }
        }

        function onListTap(position as Number, item as Item, doubletap as Boolean) as Void {
            var prop = Helper.Properties.Get(Helper.Properties.DOUBLETAPFORDONE, 1);
            if (doubletap || prop == 0 || prop == false) {
                if (item.BoundObject == false) {
                    item.setColor(getTheme().DisabledColor);
                    item.setIcon(self._itemIconDone);
                } else {
                    item.setColor(null);
                    item.setIcon(self._itemIcon);
                }
                item.BoundObject = !item.BoundObject;

                $.getApp().ListsManager.updateList(self.ListUuid, item.ItemPosition, item.BoundObject);
                self.publishItems(false);

                WatchUi.requestUpdate();
            }
        }

        function onListsChanged(index as ListIndex) as Void {
            self.publishItems(false);
        }

        function showSettings() as Void {
            var view = new ListSettingsView(self.ListUuid);
            var delegate = new ListSettingsViewDelegate(view);
            WatchUi.pushView(view, delegate, WatchUi.SLIDE_BLINK);
        }

        function onSettingsChanged() as Void {
            self._itemIcon = $.getTheme().DarkTheme ? Application.loadResource(Rez.Drawables.Item) : Application.loadResource(Rez.Drawables.bItem);
            self._itemIconDone = $.getTheme().DarkTheme ? Application.loadResource(Rez.Drawables.ItemDone) : Application.loadResource(Rez.Drawables.bItemDone);
            self.publishItems(false);
        }

        private function publishItems(initialize as Boolean) as Void {
            self.Items = [];

            var list = getApp().ListsManager.getList(self.ListUuid) as List?;

            //check if the time for an autoreset is come
            if (initialize) {
                self.checkAutoreset(list);
            }

            if (list == null) {
                self._listFound = false;
            } else {
                Helper.Properties.Store(Helper.Properties.LASTLIST, self.ListUuid);
                var show_notes = Helper.Properties.Get(Helper.Properties.SHOWNOTES, true);
                var move_down = Helper.Properties.Get(Helper.Properties.LISTMOVEDOWN, true);
                self._listFound = true;
                if (list.hasKey("name")) {
                    self.setTitle(list.get("name"));
                }

                self._listOptimized = list.hasKey("opt");

                if (list.hasKey("items")) {
                    var ordered = [];
                    var done = [];

                    for (var i = 0; i < list["items"].size(); i++) {
                        var item = list["items"][i];
                        item.put("pos", i);
                        if ((move_down == true || move_down == 1) && item.get("d") == true) {
                            done.add(item);
                        } else {
                            ordered.add(item);
                        }
                    }

                    if (done.size() > 0) {
                        ordered.addAll(done);
                    }

                    for (var i = 0; i < ordered.size(); i++) {
                        var item = ordered[i];
                        var icon, obj;

                        if (item.hasKey("d") && item.get("d") == true) {
                            icon = self._itemIconDone;
                            obj = true;
                        } else {
                            icon = self._itemIcon;
                            obj = false;
                        }

                        var text = item.get("i");
                        var note = show_notes == true ? item.get("n") : null;

                        if (text != null) {
                            self.addItem(text, note, obj, icon, item.get("pos"));
                            if (obj == true) {
                                self.Items[self.Items.size() - 1].setColor(getTheme().DisabledColor);
                            }
                        }
                    }
                }
                if (initialize) {
                    Debug.Log("Displaying list " + self.ListUuid + " (" + list.get("name") + ")");
                }
            }

            //no lone below the last items
            if (self.Items.size() > 0) {
                self.Items[self.Items.size() - 1].DrawLine = false;
            }

            if (initialize == false) {
                WatchUi.requestUpdate();
            }
        }

        private function checkAutoreset(list as List?) as Void {
            if (list == null) {
                return;
            }

            var list_items = list.get("items");
            if (list_items == null || !(list_items instanceof Array) || list_items.size() <= 0) {
                return;
            }

            var do_reset = false;

            var active = list.get("r_a") as Boolean?;
            var interval = list.get("r_i") as String?;
            var reset_hour = list.get("r_h") as Number?;
            var reset_minute = list.get("r_m") as Number?;
            var reset_weekday = list.get("r_wd") as Number?;
            var reset_day = list.get("r_d") as Number?;
            if (active != null && active == true && interval != null && reset_hour != null && reset_minute != null) {
                reset_hour = reset_hour.toNumber();
                reset_minute = reset_minute.toNumber();
                var last_reset = list.get("r_last") as Number?;
                if (last_reset == null) {
                    list.put("r_last", Time.now().value());
                    $.getApp().ListsManager.saveList(self.ListUuid, list);
                    return;
                }

                var last_reset_moment = new Time.Moment(last_reset);
                var last_reset_info = Time.Gregorian.info(last_reset_moment, Time.FORMAT_SHORT);
                Debug.Log("Last reset for list " + self.ListUuid + " was " + Helper.DateUtil.toLogString(last_reset_info, true) + " (" + last_reset_moment.value() + ")");

                var next_reset = null;
                if (interval.equals("w")) {
                    if (reset_weekday == null) {
                        Debug.Log("Could not reset list " + self.ListUuid + " weekly doe to missing parameter: weekday");
                    } else {
                        //weekly reset
                        reset_weekday = reset_weekday.toNumber();
                        if (Time.now().value() - last_reset > Time.Gregorian.SECONDS_PER_DAY * 7) {
                            //last reset is more than 7 days ago ...
                            Debug.Log("Next weekly reset for list " + self.ListUuid + " is NOW, 7+ days ago");
                            do_reset = true;
                        } else {
                            next_reset = Time.Gregorian.moment({ :year => last_reset_info.year, :month => last_reset_info.month, :day => last_reset_info.day, :hour => reset_hour, :minute => reset_minute, :second => 0 });
                            next_reset = Helper.DateUtil.ShiftTimezoneToGMT(next_reset);
                            var days_diff = (7 - last_reset_info.day_of_week + reset_weekday) % 7;
                            if (days_diff != 0) {
                                next_reset = next_reset.add(new Time.Duration(days_diff * Time.Gregorian.SECONDS_PER_DAY));
                            }
                        }
                    }
                } else if (interval.equals("m")) {
                    //monthly reset
                    if (reset_day == null) {
                        Debug.Log("Could not reset list " + self.ListUuid + " monthly doe to missing parameter: day");
                    }
                    reset_day = reset_day.toNumber();
                    if (Time.now().value() - last_reset > Time.Gregorian.SECONDS_PER_DAY * 31) {
                        //last reset is more than 31 days ago ...
                        Debug.Log("Next monthly reset for list " + self.ListUuid + " is NOW, 31+ days ago");
                        do_reset = true;
                    } else {
                        //How many days does the month of the last reset have...
                        var day = Helper.DateUtil.NumDaysForMonth(last_reset_info.month, last_reset_info.year);
                        if (reset_day < day) {
                            //the month of the last reset does not have this many days, so we just reset on the last of the month
                            day = reset_day;
                        }

                        next_reset = Time.Gregorian.moment({ :year => last_reset_info.year, :month => last_reset_info.month, :day => day, :hour => reset_hour, :minute => reset_minute, :second => 0 });
                        next_reset = Helper.DateUtil.ShiftTimezoneToGMT(next_reset);
                        if (next_reset.compare(last_reset_moment) < 0) {
                            //the last reset is newer than the next reset, so we add 1 month
                            var next_reset_info = Time.Gregorian.info(next_reset, Time.FORMAT_SHORT);
                            var year = next_reset_info.year;
                            var month = next_reset_info.month + 1;
                            if (month > 12) {
                                month = 1;
                                year += 1;
                            }
                            var new_day = Helper.DateUtil.NumDaysForMonth(month, year);
                            if (day > new_day) {
                                day = new_day;
                            }
                            next_reset = Time.Gregorian.moment({ :year => year, :month => month, :day => day, :hour => reset_hour, :minute => reset_minute, :second => 0 });
                            next_reset = Helper.DateUtil.ShiftTimezoneToGMT(next_reset);
                        }
                    }
                } else {
                    //daily reset
                    if (Time.now().value() - last_reset > Time.Gregorian.SECONDS_PER_DAY) {
                        //last reset is more than 1 day ago...
                        Debug.Log("Next daily reset for list " + self.ListUuid + " is NOW, 1+ day ago");
                        do_reset = true;
                    } else {
                        //this is the moment, when the reset should happen today...
                        next_reset = Helper.DateUtil.ShiftTimezoneToGMT(Time.Gregorian.moment({ :hour => reset_hour, :minute => reset_minute }));
                    }
                }

                //check, if the last reset was before this moment, and the moment has passed
                if (next_reset != null) {
                    var interval_str = "";
                    switch (interval) {
                        case "d":
                            interval_str = "daily";
                            break;
                        case "w":
                            interval_str = "weekly";
                            break;
                        case "m":
                            interval_str = "monthly";
                            break;
                    }
                    Debug.Log("Next scheduled " + interval_str + " reset for list " + self.ListUuid + " is " + Helper.DateUtil.toLogString(next_reset, true) + " (" + next_reset.value() + ")");
                    if (Time.now().compare(next_reset) >= 0 && last_reset_moment.compare(next_reset) < 0) {
                        do_reset = true;
                    }
                }
            } else if (active != null && active == true) {
                var missing = [];
                if (interval == null) {
                    missing.add("interval");
                }
                if (reset_hour == null) {
                    missing.add("hour");
                }
                if (reset_minute == null) {
                    missing.add("minute");
                }
                Debug.Log("Could not reset list " + self.ListUuid + " doe to missing parameters: " + missing);
            }

            if (do_reset) {
                var count = 0;
                for (var i = 0; i < list_items.size(); i++) {
                    var done = list_items[i].get("d");
                    if (done != null && done instanceof Lang.Boolean && done == true) {
                        list_items[i]["d"] = false;
                        count++;
                    }
                }
                list.put("r_last", Time.now().value());
                if (count > 0) {
                    list.put("items", list_items);
                }
                $.getApp().ListsManager.saveList(self.ListUuid, list);
                Debug.Log("List " + self.ListUuid + " reseted, changed " + count + " item(s) to undone");
            }
        }

        private function noLists(dc as Dc) as Void {
            if (self._noListLabel == null) {
                var text;
                if (self._listFound == false) {
                    text = Application.loadResource(Rez.Strings.ListNotFound);
                } else {
                    text = Application.loadResource(Rez.Strings.ListEmpty);
                }
                self._noListLabel = new MultilineLabel(text, (dc.getWidth() * 0.8).toNumber(), Fonts.Normal());
            }

            var y = (dc.getHeight() - self._noListLabel.getHeight(dc)) / 2;
            self._noListLabel.drawText(dc, (dc.getWidth() * 0.1).toNumber(), y, $.getTheme().MainColor, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
}
