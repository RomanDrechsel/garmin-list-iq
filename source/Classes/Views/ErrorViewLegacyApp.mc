import Toybox.Graphics;
import Toybox.Lang;
import Controls.Listitems;

module Views {
    class ErrorViewLegacyApp extends ItemView {
        function onLayout(dc as Dc) as Void {
            ItemView.onLayout(dc);

            var errMsg = new Listitems.Item(self._mainLayer, Application.loadResource(Rez.Strings.LegacyPhoneApp), null, null, null, null, 0, null);
            errMsg.DrawLine = false;
            errMsg.isSelectable = false;
            errMsg.TitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
            self.Items.add(errMsg);

            var txt = self.DisplayButtonSupport() ? Application.loadResource(Rez.Strings.NoListsLink) : Application.loadResource(Rez.Strings.NoListsLinkBtn);
            var hint = new Listitems.Item(self._mainLayer, null, txt, null, null, null, 1, null);
            hint.setSubFont(Helper.Fonts.Normal());
            hint.DrawLine = false;
            hint.isSelectable = false;
            hint.SubtitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
            self.Items.add(hint);
        }

        function onTap(x as Number, y as Number) as Boolean {
            ItemView.onTap(x, y);
            self.openPlaystore();
        }

        function onKeyEnter() as Boolean {
            ItemView.onKeyEnter();
            self.openPlaystore();
            return true;
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
