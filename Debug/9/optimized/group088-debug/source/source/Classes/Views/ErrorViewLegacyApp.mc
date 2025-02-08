using Helper;
using Rez;
using Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Controls.Listitems;

module Views {
    class ErrorViewLegacyApp extends ItemView {
        function initialize() {
            ItemView.initialize();
        }

        function onLayout(dc as Dc) as Void {
            var pre_1;
            pre_1 = 1;
            ItemView.onLayout(dc);

            dc /*>errMsg<*/ = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.LegacyPhoneApp), null, null, null, null, 0, null);
            dc /*>errMsg<*/.DrawLine = false;
            dc /*>errMsg<*/.isSelectable = false;
            dc /*>errMsg<*/.TitleJustification = pre_1 as Toybox.Graphics.TextJustification;
            self.Items.add(dc /*>errMsg<*/);

            dc /*>txt<*/ = self.DisplayButtonSupport() ? Application.loadResource(Rez.Strings.NoListsLinkBtn) : Application.loadResource(Rez.Strings.NoListsLink);
            dc /*>hint<*/ = new Listitems.Item(self._mainLayer, null, dc /*>txt<*/, null, null, null, pre_1, null);
            dc /*>hint<*/.setSubFont(Helper.Fonts.Normal());
            dc /*>hint<*/.DrawLine = false;
            dc /*>hint<*/.isSelectable = false;
            dc /*>hint<*/.SubtitleJustification = pre_1 as Toybox.Graphics.TextJustification;
            self.Items.add(dc /*>hint<*/);

            if ($.getApp().NoBackButton) {
                self.addBackButton(false);
            }
        }

        function onDoubleTap(x as Number, y as Number) as Boolean {
            if (!ItemView.onDoubleTap(x, y)) {
                self.openPlaystore();
                return true;
            }
            return false;
        }

        function onKeyEnter() as Boolean {
            if (!ItemView.onKeyEnter()) {
                self.openPlaystore();
                return true;
            }
            return false;
        }

        function onKeyEsc() as Boolean {
            ItemView.onKeyEsc();
            self.goBack();
            return true;
        }

        private function openPlaystore() as Void {
            $.getApp().openGooglePlay();
        }
    }
}
