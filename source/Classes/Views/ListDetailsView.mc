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
            self.publishItems(false);
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
                self.publishItems(true);

                WatchUi.requestUpdate();
            }
        }

        function onListsChanged(index as ListIndexType) as Void {
            self.publishItems(true);
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

        private function publishItems(request_update as Boolean) as Void {
            self.Items = [];

            var list = getApp().ListsManager.getList(self.ListUuid) as List?;

            //check if the time for an autoreset is come
            self.checkAutoreset(list);

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

                        var text = null;
                        var note = null;
                        var itemobj = item.get("i");
                        if (itemobj instanceof String) {
                            text = itemobj;
                        } else if (itemobj instanceof Array) {
                            text = itemobj[0];
                            if ((show_notes == true || show_notes == 1) && itemobj.size() > 1) {
                                note = itemobj[1];
                            }
                        }

                        if (text != null) {
                            self.addItem(text, note, obj, icon, item.get("pos"));
                            if (obj == true) {
                                self.Items[self.Items.size() - 1].setColor(getTheme().DisabledColor);
                            }
                        }
                    }
                }
                Debug.Log("Displaying list " + self.ListUuid + " (" + list.get("name") + ")");
            }

            if (request_update) {
                WatchUi.requestUpdate();
            }
        }

        private function checkAutoreset(list as List?) as Void {
            if (list == null) {
                return;
            }

            var do_reset = false;

            var active = list.get("r_a") as Boolean?;
            var interval = list.get("r_i") as String?;
            var reset_hour = list.get("r_h") as Number?;
            var reset_minute = list.get("r_m") as Number?;
            if (active != null && active == true && interval != null && reset_hour != null && reset_minute != null) {
                var last_reset = list.get("r_last") as Number?;
                if (last_reset == null) {
                    list.put("r_last", Time.now().value());
                    $.getApp().ListsManager.saveList(self.ListUuid, list);
                    return;
                }
                last_reset = 1729173431;
                var last_moment = new Time.Moment(last_reset);
                var next_reset = null;
                if (interval.equals("w")) {
                    //TODO: weekly reset
                } else if (interval.equals("m")) {
                    //TODO: monthly reset
                } else {
                    //daily reset
                    //check, if the last reset is more than 1 day ago...
                    if (Time.now().value() - last_reset > Time.Gregorian.SECONDS_PER_DAY) {
                        do_reset = true;
                    } else {
                        //this is the moment, when the reset should happen today...
                        next_reset = Helper.DateUtil.TimezoneOffset(Time.Gregorian.moment({ :hour => reset_hour, :minute => reset_minute }));
                    }
                }

                //check, if the last reset was before this moment, and the moment has passed
                if (next_reset != null) {
                    Debug.Log("Next list reset for list " + self.ListUuid + " is " + Helper.DateUtil.toString(next_reset, null));
                    Debug.Log("Last reset was " + Helper.DateUtil.toString(last_moment, null));
                    if (Time.now().compare(next_reset) >= 0 && last_moment.compare(next_reset) < 0) {
                        do_reset = true;
                    }
                }
            }
            Debug.Log("RESET LIST? " + do_reset);
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
