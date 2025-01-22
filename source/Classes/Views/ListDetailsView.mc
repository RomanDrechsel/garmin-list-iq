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
    class ListDetailsView extends IconItemView {
        private var _listUuid as String?;
        private var _startScroll as Number?;
        private var _listOptimized = true;
        protected var _fontoverride = Helper.Fonts.Large();

        function initialize(uuid as String, scrollTo as Number?) {
            ItemView.initialize();
            self._listUuid = uuid;
            self._startScroll = scrollTo;
            self.loadIcons();
        }

        function onShow() as Void {
            ItemView.onShow();
            if ($.getApp().ListsManager != null) {
                $.getApp().ListsManager.OnListsChanged.add(self);
            }
            self.publishItems(true);
        }

        function onHide() as Void {
            ItemView.onHide();
            if ($.getApp().ListsManager != null) {
                $.getApp().ListsManager.OnListsChanged.remove(self);
            }
        }

        function onUpdate(dc as Dc) as Void {
            ItemView.onUpdate(dc);

            //store the wraped text
            if (self._listOptimized == false && self._listUuid != null && $.getApp().ListsManager != null) {
                var optimized1 = ({}) as Dictionary<Number, Array<String> >;
                var optimized2 = ({}) as Dictionary<Number, Array<String> >;
                for (var i = 0; i < self.Items.size(); i++) {
                    var item = self.Items[i];
                    if (item instanceof Listitems.Item) {
                        var text = item.Title instanceof Controls.MultilineLabel ? item.Title.getText() : null;
                        var note = item.Subtitle instanceof Controls.MultilineLabel ? item.Subtitle.getText() : null;
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
                    $.getApp().ListsManager.Optimize(self._listUuid, optimized1, optimized2);
                }
                self._listOptimized = true;
            }
        }

        protected function interactItem(item as Listitems.Item, doubletap as Boolean) as Void {
            if ($.getApp().ListsManager == null) {
                self.goBack();
            } else if (item.BoundObject instanceof Boolean) {
                var prop = Helper.Properties.Get(Helper.Properties.DOUBLETAPFORDONE, false);
                if (doubletap || prop == 0 || prop == false) {
                    if (item.BoundObject == false) {
                        item.isDisabled = true;
                        item.setIcon(self._itemIconDone);
                        item.setIconInvert(self._itemIconDoneInvert);
                    } else {
                        item.isDisabled = false;
                        item.setIcon(self._itemIcon);
                        item.setIconInvert(self._itemIconInvert);
                    }
                    item.BoundObject = !item.BoundObject;

                    $.getApp().ListsManager.updateList(self._listUuid, item.ItemPosition, item.BoundObject);
                    //self.publishItems(false);
                    WatchUi.requestUpdate();
                }
            } else if (item.BoundObject instanceof String) {
                if (item.BoundObject.equals("settings")) {
                    self.openSettings();
                } else if (item.BoundObject.equals("back")) {
                    self.goBack();
                }
            }
        }

        function onKeyEnter() as Boolean {
            if (self._listUuid == null) {
                self.goBack();
                return true;
            }

            return ItemView.onKeyEnter();
        }

        function onKeyMenu() as Boolean {
            ItemView.onKeyMenu();
            self.openSettings();
        }

        function onTap(x as Number, y as Number) as Boolean {
            if (ItemView.onTap(x, y) == false && self._listUuid == null) {
                self.goBack();
                return true;
            }
            return false;
        }

        function onListsChanged(index as ListIndex) as Void {
            self.publishItems(false);
        }

        function openSettings() as Void {
            if (self._listUuid != null) {
                var view = new ListSettingsView(self._listUuid);
                WatchUi.pushView(view, new ItemViewDelegate(view), WatchUi.SLIDE_LEFT);
            }
        }

        function onSettingsChanged() as Void {
            ItemView.onSettingsChanged();
            self.loadIcons();
            self.publishItems(false);
        }

        function onScroll(delta as Number) as Void {
            ItemView.onScroll(delta);
            Helper.Properties.Store(Helper.Properties.LASTLISTSCROLL, self._scrollOffset);
        }

        private function publishItems(initialize as Boolean) as Void {
            self.Items = [];

            if (self._listUuid == null || $.getApp().ListsManager == null) {
                self.errorLoadingList();
            } else {
                var list = getApp().ListsManager.getList(self._listUuid) as List?;
                if (list == null) {
                    self.errorLoadingList();
                } else {
                    //check if the time for an autoreset is come
                    if (initialize) {
                        self.checkAutoreset(list);
                    }

                    Helper.Properties.Store(Helper.Properties.LASTLIST, self._listUuid);
                    var show_notes = Helper.Properties.Get(Helper.Properties.SHOWNOTES, true);
                    var move_down = Helper.Properties.Get(Helper.Properties.LISTMOVEDOWN, true);
                    if (list.hasKey("name")) {
                        self.setTitle(list.get("name") as String);
                    }

                    self._listOptimized = list.hasKey("opt") && list.get("opt") == true;

                    if (list.hasKey("items")) {
                        var ordered = [];
                        var done = [];

                        var count = 0;

                        for (var i = 0; i < list["items"].size(); i++) {
                            count++;
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
                            var icon, iconInvert, obj;

                            if (item.hasKey("d") && item.get("d") == true) {
                                icon = self._itemIconDone;
                                iconInvert = self._itemIconDoneInvert;
                                obj = true;
                            } else {
                                icon = self._itemIcon;
                                iconInvert = self._itemIconInvert;
                                obj = false;
                            }

                            var text = item.get("i");
                            var note = show_notes == true ? item.get("n") : null;

                            if (text != null) {
                                var itemObj = self.addItem(text, note, obj, icon, item.get("pos"));
                                itemObj.setIconInvert(iconInvert);
                                itemObj.isDisabled = obj;
                            }
                        }

                        if (count <= 0) {
                            self._listOptimized = true;
                            var item = new Listitems.Item(self._mainLayer, null, Application.loadResource(Rez.Strings.ListEmpty), null, null, null, 0, null);
                            item.SubtitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
                            item.isSelectable = false;
                            item.DrawLine = false;
                            self.Items.add(item);
                        }
                        if (self.DisplayButtonSupport()) {
                            self.addSettingsButton();
                        }
                    }

                    if (initialize) {
                        Debug.Log("Displaying list '" + list.get("name") + "' (" + self._listUuid + ")");
                    }

                    //no lone below the last items
                    if (self.Items.size() > 0) {
                        self.Items[self.Items.size() - 1].DrawLine = false;
                    }

                    if (self._startScroll != null && self._startScroll > 0) {
                        self._scrollOffset = self._startScroll;
                        self._startScroll = null;
                    }
                }
            }
            self._needValidation = true;
            if (initialize == false) {
                WatchUi.requestUpdate();
            }
        }

        private function checkAutoreset(list as List) as Void {
            if ($.getApp().ListsManager == null) {
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
                    $.getApp().ListsManager.saveList(self._listUuid, list);
                    return;
                }

                var last_reset_moment = new Time.Moment(last_reset);
                var last_reset_info = Time.Gregorian.info(last_reset_moment, Time.FORMAT_SHORT);
                Debug.Log("Last reset for list " + self._listUuid + " was " + Helper.DateUtil.toLogString(last_reset_info, true) + " (" + last_reset_moment.value() + ")");

                var next_reset = null;
                if (interval.equals("w")) {
                    if (reset_weekday == null) {
                        Debug.Log("Could not reset list " + self._listUuid + " weekly doe to missing parameter: weekday");
                    } else {
                        //weekly reset
                        reset_weekday = reset_weekday.toNumber();
                        if (Time.now().value() - last_reset > Time.Gregorian.SECONDS_PER_DAY * 7) {
                            //last reset is more than 7 days ago ...
                            Debug.Log("Next weekly reset for list " + self._listUuid + " is NOW, 7+ days ago");
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
                        Debug.Log("Could not reset list " + self._listUuid + " monthly doe to missing parameter: day");
                    }
                    reset_day = reset_day.toNumber();
                    if (Time.now().value() - last_reset > Time.Gregorian.SECONDS_PER_DAY * 31) {
                        //last reset is more than 31 days ago ...
                        Debug.Log("Next monthly reset for list " + self._listUuid + " is NOW, 31+ days ago");
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
                        Debug.Log("Next daily reset for list " + self._listUuid + " is NOW, 1+ day ago");
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
                    Debug.Log("Next scheduled " + interval_str + " reset for list " + self._listUuid + " is " + Helper.DateUtil.toLogString(next_reset, true) + " (" + next_reset.value() + ")");
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
                Debug.Log("Could not reset list " + self._listUuid + " doe to missing parameters: " + missing);
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
                $.getApp().ListsManager.saveList(self._listUuid, list);
                Debug.Log("List " + self._listUuid + " reseted, changed " + count + " item(s) to undone");
            }
        }

        private function errorLoadingList() as Void {
            self._listUuid = null;
            self.Items = [];
            var item = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.ListNotFound), null, "back", null, null, 0, null);
            item.TitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
            item.isSelectable = false;
            item.DrawLine = false;
            self.Items.add(item);
        }
    }
}
