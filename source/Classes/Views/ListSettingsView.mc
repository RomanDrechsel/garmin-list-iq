import Toybox.Graphics;
import Toybox.Lang;
import Lists;
import Controls;
import Controls.Listitems;
import Helper;

module Views {
    class ListSettingsView extends Controls.CustomView {
        var ListUuid = null;
        var ScrollMode = SCROLL_DRAG;

        private var _itemIconUncheck as Listitems.ViewItemIcon;
        private var _itemIconCheck as Listitems.ViewItemIcon;

        protected var TAG = "ListSettingsView";

        function initialize(uuid as String) {
            CustomView.initialize();
            self.ListUuid = uuid;
            self._itemIconUncheck = $.getTheme().DarkTheme ? Application.loadResource(Rez.Drawables.Item) : Application.loadResource(Rez.Drawables.bItem);
            self._itemIconCheck = $.getTheme().DarkTheme ? Application.loadResource(Rez.Drawables.ItemDone) : Application.loadResource(Rez.Drawables.bItemDone);
        }

        function onLayout(dc as Dc) {
            CustomView.onLayout(dc);
            self.loadItems();
        }

        function onUpdate(dc as Dc) {
            CustomView.onUpdate(dc);

            dc.setColor(getTheme().BackgroundColor, getTheme().BackgroundColor);
            dc.clear();
            self.drawList(dc);
        }

        function onListTap(position as Number, item as Item, doubletab as Boolean) as Void {
            if ([Helper.Properties.LISTMOVEDOWN, Helper.Properties.DOUBLETAPFORDONE, Helper.Properties.SHOWNOTES].indexOf(item.BoundObject) >= 0) {
                var prop = Helper.Properties.Get(item.BoundObject, true);
                if (prop == true || prop == 1) {
                    item.setIcon(self._itemIconUncheck);
                } else {
                    item.setIcon(self._itemIconCheck);
                }
                Helper.Properties.Store(item.BoundObject, !prop);
                WatchUi.requestUpdate();
                $.getApp().GlobalStates.put("movetop", true);
            } else if (item.BoundObject.equals("del")) {
                var dialog = new WatchUi.Confirmation(Application.loadResource(Rez.Strings.DeleteConfirm));
                var delegate = new ConfirmDelegate(self.method(:deleteList));
                WatchUi.pushView(dialog, delegate, WatchUi.SLIDE_BLINK);
            }
        }

        function deleteList() as Void {
            getApp().ListsManager.deleteList(self.ListUuid);
            $.getApp().GlobalStates.put("movetop", true);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }

        function onSettingsChanged() as Void {
            self.loadItems();
        }

        private function loadItems() as Void {
            self.Items = [];
            self.setTitle(Application.loadResource(Rez.Strings.StTitle));

            var icon;
            var prop = Helper.Properties.Get(Helper.Properties.LISTMOVEDOWN, true);
            if (prop == true || prop == 1) {
                icon = self._itemIconCheck;
            } else {
                icon = self._itemIconUncheck;
            }
            var movedown = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.StMoveBottom), null, Helper.Properties.LISTMOVEDOWN, icon, self._verticalItemMargin, 0, null);
            self.Items.add(movedown);

            prop = Helper.Properties.Get(Helper.Properties.DOUBLETAPFORDONE, true);
            if (prop == true || prop == 1) {
                icon = self._itemIconCheck;
            } else {
                icon = self._itemIconUncheck;
            }
            var doubletap = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.StDoubleTapForDone), null, Helper.Properties.DOUBLETAPFORDONE, icon, self._verticalItemMargin, 0, null);
            self.Items.add(doubletap);

            prop = Helper.Properties.Get(Helper.Properties.SHOWNOTES, true);
            if (prop == true || prop == 1) {
                icon = self._itemIconCheck;
            } else {
                icon = self._itemIconUncheck;
            }
            var shownotes = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.StDShowNotes), null, Helper.Properties.SHOWNOTES, icon, self._verticalItemMargin, 0, null);
            self.Items.add(shownotes);

            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StDelList), "del", self._verticalItemMargin, false));
        }
    }
}
