import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Time;
import Toybox.System;
import Lists;
import Controls;
import Controls.Listitems;
import Exceptions;

module Views {
    class ListDetailsView extends IconItemView {
        private var _listUuid as String?;
        private var _startScroll as Number?;
        private var _moveDown as Boolean;
        private var _doubleTap as Boolean or Number;

        function initialize(uuid as String, scrollTo as Number?) {
            IconItemView.initialize();
            self._listUuid = uuid;
            self._startScroll = scrollTo;
            self._moveDown = Helper.Properties.Get(Helper.Properties.LISTMOVEDOWN, true);
            self._doubleTap = Helper.Properties.Get(Helper.Properties.DOUBLETAPFORDONE, false);
        }

        function onLayout(dc as Dc) as Void {
            IconItemView.onLayout(dc);
            if ($.getApp().ListsManager != null) {
                $.getApp().ListsManager.addListChangedListener(self);
            }
            self.publishItems(false, null);
        }

        protected function interactItem(item as Listitems.Item, doubletap as Boolean) as Boolean {
            if (!IconItemView.interactItem(item, doubletap)) {
                if ($.getApp().ListsManager == null) {
                    self.goBack();
                    return true;
                } else if (item.BoundObject instanceof Boolean && self._listUuid != null) {
                    var active = item.BoundObject as Boolean;
                    if (doubletap || self._doubleTap == 0 || self._doubleTap == false) {
                        active = !active;
                        if (active) {
                            item.isDisabled = true;
                            item.setIcon(self._itemIconDone);
                            item.setIconInvert(self._itemIconDoneInvert);
                        } else {
                            item.isDisabled = false;
                            item.setIcon(self._itemIcon);
                            item.setIconInvert(self._itemIconInvert);
                        }

                        item.BoundObject = active;
                        Debug.Log("Update Item: " + item.ItemPosition + " - " + active.toString());

                        $.getApp().ListsManager.updateListitem(self._listUuid, item.ItemPosition, active);
                        if (self._moveDown) {
                            self.publishItems(true, null);
                        } else {
                            WatchUi.requestUpdate();
                        }
                        return true;
                    }
                } else if (item.BoundObject instanceof Number) {
                    if (item.BoundObject == ItemView.SETTINGS) {
                        self.openSettings();
                        return true;
                    }
                }
                return false;
            }
            return true;
        }

        function onKeyEnter() as Boolean {
            if (!IconItemView.onKeyEnter()) {
                self.goBack();
            }
            return true;
        }

        function onKeyMenu() as Boolean {
            if (!IconItemView.onKeyMenu()) {
                self.openSettings();
            }
            return true;
        }

        function onListChanged(list as Lists.List?) as Void {
            if (list == null || list.equals(self._listUuid)) {
                self.publishItems(true, list);
            }
        }

        function openSettings() as Void {
            if (self._listUuid != null) {
                var view = new ListSettingsView(self._listUuid);
                WatchUi.pushView(view, new ItemViewDelegate(view), WatchUi.SLIDE_LEFT);
            }
        }

        function onSettingsChanged() as Void {
            IconItemView.onSettingsChanged();
            self._moveDown = Helper.Properties.Get(Helper.Properties.LISTMOVEDOWN, true);
            self._doubleTap = Helper.Properties.Get(Helper.Properties.DOUBLETAPFORDONE, false);
            self.publishItems(true, null);
        }

        function onScroll(delta as Number) as Void {
            ItemView.onScroll(delta);
            Helper.Properties.Store(Helper.Properties.LASTLISTSCROLL, self._scrollOffset);
        }

        private function publishItems(request_update as Boolean, list as Lists.List?) as Void {
            self.Items = [];

            if ($.getApp().ListsManager == null || self._listUuid == null) {
                self.errorLoadingList();
            } else {
                if (list == null) {
                    list = getApp().ListsManager.GetList(self._listUuid) as List?;
                }
                if (list == null) {
                    self.errorLoadingList();
                } else {
                    //check if the time for an autoreset is come
                    if (request_update) {
                        self.checkAutoreset(list);
                    }

                    Helper.Properties.Store(Helper.Properties.LASTLIST, list.Uuid);
                    var show_notes = Helper.Properties.Get(Helper.Properties.SHOWNOTES, true);
                    var move_down = Helper.Properties.Get(Helper.Properties.LISTMOVEDOWN, true);
                    self.setTitle(list.Title);
                    if (list.Items.size() > 0) {
                        var ordered = [] as Array<Listitem>;
                        var done = [] as Array<Listitem>;

                        var count = 0;
                        var listitem = list.ReduceItem();
                        while (listitem != null) {
                            count += 1;
                            if (!listitem.isValid()) {
                                continue;
                            }
                            if ((move_down == true || move_down == 1) && listitem.Done == true) {
                                done.add(listitem);
                            } else {
                                ordered.add(listitem);
                            }
                            listitem = list.ReduceItem();
                        }

                        if (done.size() > 0) {
                            ordered.addAll(done);
                        }
                        done = null;

                        for (var i = 0; i < ordered.size(); i++) {
                            var item = ordered[i];
                            var icon, iconInvert, bound;

                            if (item.Done == true) {
                                icon = self._itemIconDone;
                                iconInvert = self._itemIconDoneInvert;
                                bound = true;
                            } else {
                                icon = self._itemIcon;
                                iconInvert = self._itemIconInvert;
                                bound = false;
                            }
                            var itemObj = self.addItem(item.Text, show_notes ? item.Note : null, bound, icon, item.Order);
                            itemObj.setIconInvert(iconInvert);
                            itemObj.isDisabled = item.Done;
                        }
                        ordered = null;

                        if (count <= 0) {
                            var item = new Listitems.Item(self._mainLayer, null, Application.loadResource(Rez.Strings.ListEmpty), null, null, null, 0, null);
                            item.SubtitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
                            item.isSelectable = false;
                            item.DrawLine = false;
                            self.Items.add(item);
                        }
                    }

                    if (self.DisplayButtonSupport()) {
                        self.addSettingsButton();
                    }

                    if ($.getApp().NoBackButton) {
                        self.addBackButton(false);
                    }

                    if (request_update == false) {
                        Debug.Log("Displaying list " + list.toString());
                    }
                    list = null;

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
            if (request_update) {
                WatchUi.requestUpdate();
            }
        }

        private function checkAutoreset(list as List) as Void {
            if ($.getApp().ListsManager == null) {
                return;
            }

            if (list.Items.size() <= 0) {
                return;
            }

            var do_reset = false;
            var store_list = false;
            if (list.Reset == true && list.ResetInterval != null && list.ResetHour != null && list.ResetMinute != null) {
                if (list.ResetLast == null) {
                    list.ResetLast = Time.now().value();
                    $.getApp().ListsManager.StoreList(list);
                    return;
                }

                var last_reset_moment = new Time.Moment(list.ResetLast);
                var last_reset_info = Time.Gregorian.info(last_reset_moment, Time.FORMAT_SHORT);
                Debug.Log("Last reset for list " + list.toString() + " was " + Helper.DateUtil.toLogString(last_reset_info, true) + " (" + last_reset_moment.value() + ")");

                var next_reset = null;
                if (list.ResetInterval.equals("w")) {
                    if (list.ResetWeekday == null) {
                        store_list = true;
                        list.RemoveReset();
                        Debug.Log("Could not reset list " + list.toString() + " weekly doe to missing parameter: weekday");
                    } else {
                        //weekly reset
                        if (Time.now().value() - list.ResetLast > Time.Gregorian.SECONDS_PER_DAY * 7) {
                            //last reset is more than 7 days ago ...
                            Debug.Log("Next weekly reset for list " + list.Reset + " is NOW, 7+ days ago");
                            do_reset = true;
                        } else {
                            next_reset = Time.Gregorian.moment({ :year => last_reset_info.year, :month => last_reset_info.month, :day => last_reset_info.day, :hour => list.ResetHour, :minute => list.ResetMinute, :second => 0 });
                            next_reset = Helper.DateUtil.ShiftTimezoneToGMT(next_reset);
                            var days_diff = (7 - last_reset_info.day_of_week + list.ResetWeekday) % 7;
                            if (days_diff != 0) {
                                next_reset = next_reset.add(new Time.Duration(days_diff * Time.Gregorian.SECONDS_PER_DAY));
                            }
                        }
                    }
                } else if (list.ResetInterval.equals("m")) {
                    //monthly reset
                    if (list.ResetDay == null) {
                        Debug.Log("Could not reset list " + list.toString() + " monthly doe to missing parameter: day");
                        list.RemoveReset();
                        store_list = true;
                    }
                    if (Time.now().value() - list.ResetLast > Time.Gregorian.SECONDS_PER_DAY * 31) {
                        //last reset is more than 31 days ago ...
                        Debug.Log("Next monthly reset for list " + list.toString() + " is NOW, 31+ days ago");
                        do_reset = true;
                    } else {
                        //How many days does the month of the last reset have...
                        var day = Helper.DateUtil.NumDaysForMonth(last_reset_info.month, last_reset_info.year);
                        if (list.ResetDay < day) {
                            //the month of the last reset does not have this many days, so we just reset on the last of the month
                            day = list.ResetDay;
                        }

                        next_reset = Time.Gregorian.moment({ :year => last_reset_info.year, :month => last_reset_info.month, :day => day, :hour => list.ResetHour, :minute => list.ResetMinute, :second => 0 });
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
                            next_reset = Time.Gregorian.moment({ :year => year, :month => month, :day => day, :hour => list.ResetHour, :minute => list.ResetMinute, :second => 0 });
                            next_reset = Helper.DateUtil.ShiftTimezoneToGMT(next_reset);
                        }
                    }
                } else {
                    //daily reset
                    if (Time.now().value() - list.ResetLast > Time.Gregorian.SECONDS_PER_DAY) {
                        //last reset is more than 1 day ago...
                        Debug.Log("Next daily reset for list " + list.toString() + " is NOW, 1+ day ago");
                        do_reset = true;
                    } else {
                        //this is the moment, when the reset should happen today...
                        next_reset = Helper.DateUtil.ShiftTimezoneToGMT(Time.Gregorian.moment({ :hour => list.ResetHour, :minute => list.ResetMinute }));
                    }
                }

                //check, if the last reset was before this moment, and the moment has passed
                if (next_reset != null) {
                    var interval_str = "";
                    switch (list.ResetInterval) {
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
                    Debug.Log("Next scheduled " + interval_str + " reset for list " + list.toString() + " is " + Helper.DateUtil.toLogString(next_reset, true) + " (" + next_reset.value() + ")");
                    if (Time.now().compare(next_reset) >= 0 && last_reset_moment.compare(next_reset) < 0) {
                        do_reset = true;
                    }
                }
            } else if (list.Reset == true) {
                var missing = [];
                if (list.ResetInterval == null) {
                    missing.add("interval");
                }
                if (list.ResetHour == null) {
                    missing.add("hour");
                }
                if (list.ResetMinute == null) {
                    missing.add("minute");
                }
                list.RemoveReset();
                store_list = true;
                Debug.Log("Could not reset list " + list.toString() + " doe to missing parameters: " + missing);
            }

            if (do_reset) {
                var count = 0;
                for (var i = 0; i < list.Items.size(); i++) {
                    var item = list.Items[i];

                    if (item.Done == true) {
                        item.Done = false;
                        count++;
                    }
                }
                list.ResetLast = Time.now().value();
                store_list = true;
                Debug.Log("List " + list.toString() + " reseted, changed " + count + " item(s) to undone");
            }

            if (store_list) {
                $.getApp().ListsManager.StoreList(list);
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
