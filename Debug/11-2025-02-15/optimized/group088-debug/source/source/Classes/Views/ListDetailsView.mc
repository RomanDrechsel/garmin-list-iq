using Toybox.Time.Gregorian;
using Debug;
using Rez;
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

        function initialize(uuid as String, scrollTo as Number?) {
            IconItemView.initialize();
            self._listUuid = uuid;
            self._startScroll = scrollTo;
            self.loadIcons();
        }

        function onLayout(dc as Dc) as Void {
            IconItemView.onLayout(dc);
            if ($.getApp().ListsManager != null) {
                $.getApp().ListsManager.addListChangedListener(self);
            }
            self.publishItems(false);
        }

        protected function interactItem(item as Listitems.Item, doubletap as Boolean) as Void {
            if ($.getApp().ListsManager == null) {
                self.goBack();
            } else if (item.BoundObject instanceof Boolean) {
                var prop = Helper.Properties.Get("DoubleTapForDone", false);
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

                    $.getApp().ListsManager.updateListitem(self._listUuid, item.ItemPosition, item.BoundObject);
                    self.publishItems(true);
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
            self.publishItems(true);
        }

        function openSettings() as Void {
            var pre__listUuid;
            pre__listUuid = self._listUuid;
            if (pre__listUuid != null) {
                pre__listUuid /*>view<*/ = new ListSettingsView(pre__listUuid);
                WatchUi.pushView(pre__listUuid /*>view<*/, new ItemViewDelegate(pre__listUuid /*>view<*/), 1 as Toybox.WatchUi.SlideType);
            }
        }

        function onSettingsChanged() as Void {
            ItemView.onSettingsChanged();
            self.loadIcons();
            self.publishItems(true);
        }

        function onScroll(delta as Number) as Void {
            ItemView.onScroll(delta);
            Helper.Properties.Store("LastListScroll", self._scrollOffset);
        }

        private function publishItems(request_update as Boolean) as Void {
            var pre__items_, pre__d_, pre__name_, pre_0, pre_1;
            self.Items = [];

            if (self._listUuid == null || $.getApp().ListsManager == null) {
                self.errorLoadingList();
            } else {
                var list = getApp().ListsManager.getList(self._listUuid) as List?;
                if (list == null) {
                    self.errorLoadingList();
                } else {
                    var move_down;
                    //check if the time for an autoreset is come
                    if (request_update) {
                        self.checkAutoreset(list);
                    }

                    pre__name_ = "name";
                    Helper.Properties.Store("LastList", self._listUuid);
                    var show_notes = Helper.Properties.Get("ShowNotes", true);
                    move_down = Helper.Properties.Get("ListMoveDown", true);
                    if (list.hasKey(pre__name_)) {
                        self.setTitle(list.get(pre__name_) as String);
                    }

                    pre_1 = 1;
                    pre_0 = 0;
                    pre__items_ = "items";
                    if (list.hasKey(pre__items_)) {
                        var done,
                            items,
                            item_0,
                            ordered = [];
                        done = [];

                        var count = pre_0;

                        items = [];

                        if (list.hasKey(pre__items_)) {
                            pre__items_ /*>itemsDict<*/ = list.get(pre__items_);
                            if (pre__items_ /*>itemsDict<*/ instanceof Array) {
                                items = pre__items_ /*>itemsDict<*/;
                            }
                        }

                        pre__d_ = "d";
                        {
                            pre__items_ /*>i<*/ = pre_0;
                            for (; pre__items_ /*>i<*/ < items.size(); pre__items_ /*>i<*/ += pre_1) {
                                count += pre_1;
                                item_0 /*>item<*/ = items[pre__items_ /*>i<*/];
                                item_0 /*>item<*/.put("pos", pre__items_ /*>i<*/);
                                if ((move_down == true || move_down == pre_1) && item_0 /*>item<*/.get(pre__d_) == true) {
                                    done.add(item_0 /*>item<*/);
                                } else {
                                    ordered.add(item_0 /*>item<*/);
                                }
                            }
                        }

                        if (done.size() > pre_0) {
                            ordered.addAll(done);
                        }

                        {
                            move_down /*>i<*/ = pre_0;
                            for (; move_down /*>i<*/ < ordered.size(); move_down /*>i<*/ += pre_1) {
                                done /*>item<*/ = ordered[move_down /*>i<*/];
                                var iconInvert, obj;

                                if (done /*>item<*/.hasKey(pre__d_) && done /*>item<*/.get(pre__d_) == true) {
                                    items /*>icon<*/ = self._itemIconDone;
                                    iconInvert = self._itemIconDoneInvert;
                                    obj = true;
                                } else {
                                    items /*>icon<*/ = self._itemIcon;
                                    iconInvert = self._itemIconInvert;
                                    obj = false;
                                }

                                item_0 /*>text<*/ = done /*>item<*/.get("i");
                                pre__items_ /*>note<*/ = show_notes == true ? done /*>item<*/.get("n") : null;

                                if (item_0 /*>text<*/ != null) {
                                    pre__items_ /*>itemObj<*/ = self.addItem(item_0 /*>text<*/, pre__items_ /*>note<*/, obj, items /*>icon<*/, done /*>item<*/.get("pos"));
                                    pre__items_ /*>itemObj<*/.setIconInvert(iconInvert);
                                    pre__items_ /*>itemObj<*/.isDisabled = obj;
                                }
                            }
                        }

                        if (count <= pre_0) {
                            pre__items_ /*>item<*/ = new Listitems.Item(self._mainLayer, null, Application.loadResource(Rez.Strings.ListEmpty), null, null, null, pre_0, null);
                            pre__items_ /*>item<*/.SubtitleJustification = pre_1 as Toybox.Graphics.TextJustification;
                            pre__items_ /*>item<*/.isSelectable = false;
                            pre__items_ /*>item<*/.DrawLine = false;
                            self.Items.add(pre__items_ /*>item<*/);
                        }
                        if (self.DisplayButtonSupport()) {
                            self.addSettingsButton();
                        }

                        if ($.getApp().NoBackButton) {
                            self.addBackButton(false);
                        }
                    }

                    if (request_update == false) {
                        Debug.Log("Displaying list '" + list.get(pre__name_) + "' (" + self._listUuid + ")");
                    }

                    //no lone below the last items
                    if (self.Items.size() > pre_0) {
                        self.Items[self.Items.size() - pre_1].DrawLine = false;
                    }

                    if (self._startScroll != null && self._startScroll > pre_0) {
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
            var pre__Could_not_reset_list__, reset_weekday, count, active, pre__d_, pre__r_last_, pre_0, pre_1;
            if ($.getApp().ListsManager == null) {
                return;
            }

            var list_items = list.get("items");
            pre_0 = 0;
            if (list_items == null || !(list_items instanceof Array) || list_items.size() <= pre_0) {
                return;
            }

            pre_1 = 1;
            pre__r_last_ = "r_last";
            pre__d_ = "d";
            pre__Could_not_reset_list__ = "Could not reset list ";
            var do_reset = false;

            active = list.get("r_a") as Boolean?;
            var interval = list.get("r_i") as String?;
            var reset_hour = list.get("r_h") as Number?;
            var reset_minute = list.get("r_m") as Number?;
            reset_weekday = list.get("r_wd") as Number?;
            var reset_day = list.get("r_d") as Number?;
            if (active != null && active == true && interval != null && reset_hour != null && reset_minute != null) {
                reset_hour = reset_hour.toNumber();
                reset_minute = reset_minute.toNumber();
                active /*>last_reset<*/ = list.get(pre__r_last_) as Number?;
                if (active /*>last_reset<*/ == null) {
                    list.put(pre__r_last_, Time.now().value());
                    $.getApp().ListsManager.saveList(self._listUuid, list);
                    return;
                }

                var last_reset_moment = new Time.Moment(active /*>last_reset<*/);
                count /*>last_reset_info<*/ = Gregorian /*>Time.Gregorian<*/.info(last_reset_moment, pre_0 as Toybox.Time.DateFormat);
                Debug.Log("Last reset for list " + self._listUuid + " was " + Helper.DateUtil.toLogString(count /*>last_reset_info<*/, true) + " (" + last_reset_moment.value() + ")");

                var next_reset = null;
                if (interval.equals("w")) {
                    if (reset_weekday == null) {
                        Debug.Log(pre__Could_not_reset_list__ + self._listUuid + " weekly doe to missing parameter: weekday");
                    } else {
                        //weekly reset
                        if (Time.now().value() - active /*>last_reset<*/ > 604800) {
                            //last reset is more than 7 days ago ...
                            Debug.Log("Next weekly reset for list " + self._listUuid + " is NOW, 7+ days ago");
                            do_reset = true;
                        } else {
                            next_reset = Helper.DateUtil.ShiftTimezoneToGMT(
                                Gregorian /*>Time.Gregorian<*/.moment({
                                    :year => count /*>last_reset_info<*/.year,
                                    :month => count /*>last_reset_info<*/.month,
                                    :day => count /*>last_reset_info<*/.day,
                                    :hour => reset_hour,
                                    :minute => reset_minute,
                                    :second => pre_0,
                                })
                            );
                            active /*>days_diff<*/ = (7 - count /*>last_reset_info<*/.day_of_week + reset_weekday.toNumber()) % 7;
                            if (active /*>days_diff<*/ != pre_0) {
                                next_reset = next_reset.add(new Time.Duration(active /*>days_diff<*/ * 86400));
                            }
                        }
                    }
                } else if (interval.equals("m")) {
                    //monthly reset
                    if (reset_day == null) {
                        Debug.Log(pre__Could_not_reset_list__ + self._listUuid + " monthly doe to missing parameter: day");
                    }
                    reset_day = reset_day.toNumber();
                    if (Time.now().value() - active /*>last_reset<*/ > 2678400) {
                        //last reset is more than 31 days ago ...
                        Debug.Log("Next monthly reset for list " + self._listUuid + " is NOW, 31+ days ago");
                        do_reset = true;
                    } else {
                        //How many days does the month of the last reset have...
                        pre__Could_not_reset_list__ /*>day<*/ = Helper.DateUtil.NumDaysForMonth(count /*>last_reset_info<*/.month, count /*>last_reset_info<*/.year);
                        if (reset_day < pre__Could_not_reset_list__ /*>day<*/) {
                            //the month of the last reset does not have this many days, so we just reset on the last of the month
                            pre__Could_not_reset_list__ /*>day<*/ = reset_day;
                        }

                        next_reset = Helper.DateUtil.ShiftTimezoneToGMT(
                            Gregorian /*>Time.Gregorian<*/.moment({
                                :year => count /*>last_reset_info<*/.year,
                                :month => count /*>last_reset_info<*/.month,
                                :day => pre__Could_not_reset_list__ /*>day<*/,
                                :hour => reset_hour,
                                :minute => reset_minute,
                                :second => pre_0,
                            })
                        );
                        if (next_reset.compare(last_reset_moment) < pre_0) {
                            //the last reset is newer than the next reset, so we add 1 month
                            active /*>next_reset_info<*/ = Gregorian /*>Time.Gregorian<*/.info(next_reset, pre_0 as Toybox.Time.DateFormat);
                            reset_weekday /*>year<*/ = active /*>next_reset_info<*/.year;
                            count /*>month<*/ = active /*>next_reset_info<*/.month + pre_1;
                            if (count /*>month<*/ > 12) {
                                count /*>month<*/ = pre_1;
                                reset_weekday /*>year<*/ += pre_1;
                            }
                            active /*>new_day<*/ = Helper.DateUtil.NumDaysForMonth(count /*>month<*/, reset_weekday /*>year<*/);
                            if (pre__Could_not_reset_list__ /*>day<*/ > active /*>new_day<*/) {
                                pre__Could_not_reset_list__ /*>day<*/ = active /*>new_day<*/;
                            }
                            next_reset = Helper.DateUtil.ShiftTimezoneToGMT(
                                Gregorian /*>Time.Gregorian<*/.moment({ :year => reset_weekday /*>year<*/, :month => count /*>month<*/, :day => pre__Could_not_reset_list__ /*>day<*/, :hour => reset_hour, :minute => reset_minute, :second => pre_0 })
                            );
                        }
                    }
                } else {
                    //daily reset
                    if (Time.now().value() - active /*>last_reset<*/ > 86400) {
                        //last reset is more than 1 day ago...
                        Debug.Log("Next daily reset for list " + self._listUuid + " is NOW, 1+ day ago");
                        do_reset = true;
                    } else {
                        //this is the moment, when the reset should happen today...
                        next_reset = Helper.DateUtil.ShiftTimezoneToGMT(Gregorian /*>Time.Gregorian<*/.moment({ :hour => reset_hour, :minute => reset_minute }));
                    }
                }

                //check, if the last reset was before this moment, and the moment has passed
                if (next_reset != null) {
                    active /*>interval_str<*/ = "";
                    switch (interval) {
                        case pre__d_:
                            active /*>interval_str<*/ = "daily";
                            break;
                        case "w":
                            active /*>interval_str<*/ = "weekly";
                            break;
                        case "m":
                            active /*>interval_str<*/ = "monthly";
                            break;
                    }
                    Debug.Log("Next scheduled " + active /*>interval_str<*/ + " reset for list " + self._listUuid + " is " + Helper.DateUtil.toLogString(next_reset, true) + " (" + next_reset.value() + ")");
                    if (Time.now().compare(next_reset) >= pre_0 && last_reset_moment.compare(next_reset) < pre_0) {
                        do_reset = true;
                    }
                }
            } else if (active != null && active == true) {
                active /*>missing<*/ = [];
                if (interval == null) {
                    active /*>missing<*/.add("interval");
                }
                if (reset_hour == null) {
                    active /*>missing<*/.add("hour");
                }
                if (reset_minute == null) {
                    active /*>missing<*/.add("minute");
                }
                Debug.Log(pre__Could_not_reset_list__ + self._listUuid + " doe to missing parameters: " + active /*>missing<*/);
            }

            if (do_reset) {
                count = pre_0;
                {
                    active /*>i<*/ = pre_0;
                    for (; active /*>i<*/ < list_items.size(); active /*>i<*/ += pre_1) {
                        reset_weekday /*>done<*/ = list_items[active /*>i<*/].get(pre__d_);
                        if (reset_weekday /*>done<*/ != null && reset_weekday /*>done<*/ instanceof Lang.Boolean && reset_weekday /*>done<*/ == true) {
                            list_items[active /*>i<*/][pre__d_] = false;
                            count += pre_1;
                        }
                    }
                }
                list.put(pre__r_last_, Time.now().value());
                if (count > pre_0) {
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
            item.TitleJustification = 1 as Toybox.Graphics.TextJustification;
            item.isSelectable = false;
            item.DrawLine = false;
            self.Items.add(item);
        }
    }
}
