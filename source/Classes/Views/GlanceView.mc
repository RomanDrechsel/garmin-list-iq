import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Application;
import Controls;

(:glance)
module Views {
    class GlanceView extends WatchUi.GlanceView {
        private var _title = null as MultilineLabel?;
        private var _sub = null as MultilineLabel?;
        private var _lists = new Lists.GlanceListsManager();

        public function onLayout(dc as Dc) as Void {
            self._title = new Controls.MultilineLabel(Application.loadResource(Rez.Strings.AppName), dc.getWidth(), Graphics.FONT_XTINY);
            self._sub = new Controls.MultilineLabel(self._lists.GetInfo(), dc.getWidth(), Graphics.FONT_XTINY);
            self._sub.SetMaxHeight(dc.getHeight() - self._title.getHeight(dc));
        }

        public function onUpdate(dc as Dc) as Void {
            var yStart = (dc.getHeight() - self._title.getHeight(dc) - self._sub.getHeight(dc)) / 2;
            var height = self._title.drawText(dc, 0, yStart, Graphics.COLOR_WHITE, Graphics.TEXT_JUSTIFY_LEFT);
            self._sub.drawText(dc, 0, yStart + height, Graphics.COLOR_LT_GRAY, Graphics.TEXT_JUSTIFY_LEFT);
        }
    }
}
