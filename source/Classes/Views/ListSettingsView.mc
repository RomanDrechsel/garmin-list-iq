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

        private var _itemIconUncheck = Application.loadResource(Rez.Drawables.Item);
        private var _itemIconCheck = Application.loadResource(Rez.Drawables.ItemDone);

        protected var TAG = "ListSettingsView";

        function initialize(uuid as String) {
            CustomView.initialize();
            self.ListUuid = uuid;
        }

        function onLayout(dc as Dc) {
            CustomView.onLayout(dc);
            self.setTitle(Application.loadResource(Rez.Strings.StTitle));

            var movedown = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.StMoveBottom), null, Helper.Properties.LISTMOVEDOWN, Helper.Properties.Boolean(Helper.Properties.LISTMOVEDOWN, true) ? self._itemIconCheck : self._itemIconUncheck, self._verticalItemMargin, 0, null);
            self.Items.add(movedown);

            var doubletap = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.StDoubleTapForDone), null, Helper.Properties.DOUBLETAPFORDONE, Helper.Properties.Boolean(Helper.Properties.DOUBLETAPFORDONE, true) ? self._itemIconCheck : self._itemIconUncheck, self._verticalItemMargin, 0, null);
            self.Items.add(doubletap);

            var shownotes = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.StDShowNotes), null, Helper.Properties.SHOWNOTES, Helper.Properties.Boolean(Helper.Properties.SHOWNOTES, true) ? self._itemIconCheck : self._itemIconUncheck, self._verticalItemMargin, 0, null);
            self.Items.add(shownotes);

            self.Items.add(new Listitems.Button(self._mainLayer, Application.loadResource(Rez.Strings.StDelList), "del", self._verticalItemMargin, false));
        }

        function onUpdate(dc as Dc) {
            CustomView.onUpdate(dc);

            dc.setColor(getTheme().BackgroundColor, getTheme().BackgroundColor);
            dc.clear();
            self.drawList(dc);
        }

        function onListTap(position as Number, item as Item, doubletab as Boolean) as Void {
            if ([Helper.Properties.LISTMOVEDOWN, Helper.Properties.DOUBLETAPFORDONE, Helper.Properties.SHOWNOTES].indexOf(item.BoundObject) >= 0) {
                var prop = Helper.Properties.Boolean(item.BoundObject, true);
                if (prop) {
                    item.setIcon(self._itemIconUncheck);
                } else {
                    item.setIcon(self._itemIconCheck);
                }
                Helper.Properties.SaveBoolean(item.BoundObject, !prop);
                WatchUi.requestUpdate();
            } else if (item.BoundObject == "del") {
                var dialog = new WatchUi.Confirmation(Application.loadResource(Rez.Strings.DeleteConfirm));
                var delegate = new ConfirmDelegate(self.method(:deleteList));
                WatchUi.pushView(dialog, delegate, WatchUi.SLIDE_BLINK);
            }
        }

        function deleteList() {
            getApp().ListsManager.deleteList(self.ListUuid);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }
}
