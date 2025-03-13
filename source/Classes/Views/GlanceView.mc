import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Application;
import Toybox.Timer;
import Toybox.Lang;

import Controls;

(:withGlance)
module Views {
    (:glance)
    class GlanceView extends WatchUi.GlanceView {
        private var _title as Label? = null;
        private var _sub as Label? = null;
        private var _lists = new Lists.GlanceListsManager();
        private var _timer = null as Timer.Timer?;

        function initialize() {
            GlanceView.initialize();
        }

        public function onLayout(dc as Dc) as Void {
            GlanceView.onLayout(dc);
            self._title = new Controls.Label(Application.loadResource(Rez.Strings.AppName), Graphics.FONT_XTINY, dc.getWidth());
            self._sub = new Controls.Label(self._lists.GetInfo(), Graphics.FONT_XTINY, dc.getWidth());
            self._sub.SetMaxHeight(dc.getHeight() - self._title.getHeight(dc));
        }

        public function onShow() as Void {
            GlanceView.onShow();
            self._timer = new Timer.Timer();
            self._timer.start(method(:updateLists), 10000, true);
        }

        public function onHide() as Void {
            if (self._timer != null) {
                self._timer.stop();
                self._timer = null;
            }
        }

        public function onUpdate(dc as Dc) as Void {
            var yStart = (dc.getHeight() - self._title.getHeight(dc) - self._sub.getHeight(dc)) / 2;
            var height = self._title.draw(dc, 0, yStart, Graphics.COLOR_WHITE, Graphics.TEXT_JUSTIFY_LEFT);
            self._sub.draw(dc, 0, yStart + height, Graphics.COLOR_LT_GRAY, Graphics.TEXT_JUSTIFY_LEFT);
        }

        function updateLists() as Void {
            var text = self._lists.GetInfo();
            if (!self._sub.getText().equals(text)) {
                self._sub.setText(text);
                WatchUi.requestUpdate();
            }
        }
    }
}
