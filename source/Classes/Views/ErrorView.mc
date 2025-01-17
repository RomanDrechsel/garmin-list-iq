import Controls;
import Controls.Listitems;
import Helper;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Application;

module Views {
    class ErrorView extends Controls.CustomView {
        private var _labelMessage as MultilineLabel? = null;
        private var _labelError as MultilineLabel? = null;
        private var _errorMsg as Lang.ResourceId? = null;
        private var _errorCode as Lang.Number? = null;
        private var _errorPayload as Application.PersistableType = null;

        function initialize(msg as Lang.ResourceId?, code as Lang.Number?, payload as Application.PersistableType) {
            CustomView.initialize();
            self._errorMsg = msg;
            self._errorCode = code;
            self._errorPayload = payload;
        }

        function onLayout(dc as Dc) as Void {
            CustomView.onLayout(dc);
            self.loadVisuals();
        }

        function onTap(x as Number, y as Number) as Boolean {
            var app = $.getApp();
            if (app.Phone != null && app.Debug != null) {
                var resp = ({}) as Dictionary<String, String or Number or Array<String> >;
                resp.put("type", "reportError");
                if (self._errorMsg != null) {
                    resp.put("errorMsg", Application.loadResource(self._errorMsg));
                }
                if (self._errorCode) {
                    resp.put("errorCode", "0x" + self._errorCode.format("%04x"));
                }
                if (self._errorPayload != null) {
                    resp.put("errorPayload", self._errorPayload);
                }
                resp.put("logs", app.Debug.GetLogs());
                app.Phone.SendToPhone(resp);
                Debug.Log("Send error report code 0x" + self._errorCode.format("%04x") + " to smartphone");
                Helper.ToastUtil.Toast(Rez.Strings.ErrReport, Helper.ToastUtil.ATTENTION);
                WatchUi.popView(WatchUi.SLIDE_BLINK);
            }
        }

        private function loadVisuals() as Void {
            if (self.Items.size() > 0) {
                self.Items = new Array<Item>[0];
            }

            if (self._errorMsg != null) {
                var errMsg = new Listitems.Item(self._mainLayer, Application.loadResource(self._errorMsg), null, null, null, self._verticalItemMargin, 0, null);
                errMsg.DrawLine = false;
                errMsg.TitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
                self.Items.add(errMsg);
            }
            if (self._errorCode != null) {
                var errCode = new Listitems.Item(self._mainLayer, "0x" + self._errorCode.format("%04x"), null, null, null, self._verticalItemMargin, 1, Helper.Fonts.Big());
                errCode.DrawLine = false;
                errCode.TitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
                self.Items.add(errCode);
            }

            var hint = new Listitems.Item(self._mainLayer, null, Application.loadResource(Rez.Strings.ErrHint), null, null, self._verticalItemMargin, 2, null);
            hint.DrawLine = false;
            hint.SubtitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
            self.Items.add(hint);
        }
    }
}
