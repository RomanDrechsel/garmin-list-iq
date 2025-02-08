import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Application;
import Controls;

(:glance)
module Views {
    class GlanceView extends WatchUi.GlanceView {
        private var _title as Label? = null;
        private var _sub as Label? = null;
        private var _lists = new Lists.GlanceListsManager();

        public function onLayout(dc as Dc) as Void {
            self._title = new Controls.Label(Application.loadResource(Rez.Strings.AppName), Graphics.FONT_XTINY, dc.getWidth());
            self._sub = new Controls.Label(self._lists.GetInfo(), Graphics.FONT_XTINY, dc.getWidth());
            self._sub.SetMaxHeight(dc.getHeight() - self._title.getHeight(dc));
        }

        public function onUpdate(dc as Dc) as Void {
            var yStart = (dc.getHeight() - self._title.getHeight(dc) - self._sub.getHeight(dc)) / 2;
            var height = self._title.draw(dc, 0, yStart, Graphics.COLOR_WHITE, Graphics.TEXT_JUSTIFY_LEFT);
            self._sub.draw(dc, 0, yStart + height, Graphics.COLOR_LT_GRAY, Graphics.TEXT_JUSTIFY_LEFT);
        }
    }
}
