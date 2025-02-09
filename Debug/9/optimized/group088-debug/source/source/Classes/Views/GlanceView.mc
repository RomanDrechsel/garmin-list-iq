using Lists;
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
            self._title = new Controls.Label(Application.loadResource(Rez.Strings.AppName), 0 as Toybox.Graphics.FontDefinition, dc.getWidth());
            self._sub = new Controls.Label(self._lists.GetInfo(), 0 as Toybox.Graphics.FontDefinition, dc.getWidth());
            self._sub.SetMaxHeight(dc.getHeight() - self._title.getHeight(dc));
        }

        public function onUpdate(dc as Dc) as Void {
            var pre_2;
            pre_2 = 2;
            var yStart = (dc.getHeight() - self._title.getHeight(dc) - self._sub.getHeight(dc)) / pre_2;
            var height = self._title.draw(dc, 0, yStart, 0xffffff as Toybox.Graphics.ColorValue, pre_2 as Toybox.Graphics.TextJustification);
            self._sub.draw(dc, 0, yStart + height, 0xaaaaaa as Toybox.Graphics.ColorValue, pre_2 as Toybox.Graphics.TextJustification);
        }
    }
}
