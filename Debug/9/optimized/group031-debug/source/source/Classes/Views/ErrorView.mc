using Rez;
using Debug;
import Controls;
import Controls.Listitems;
import Helper;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Application;

module Views {
    class ErrorView extends ItemView {
        private var _errorMsg as Lang.ResourceId? = null;
        private var _errorCode as Lang.Number? = null;
        private var _errorPayload as Application.PersistableType = null;

        function initialize(msg as Lang.ResourceId?, code as Lang.Number?, payload as Application.PersistableType) {
            ItemView.initialize();
            self._errorMsg = msg;
            self._errorCode = code;
            self._errorPayload = payload;
        }

        function onLayout(dc as Dc) as Void {
            ItemView.onLayout(dc);
            self.loadVisuals();
        }

        function onTap(x as Number, y as Number) as Boolean {
            ItemView.onTap(x, y);
            self.sendReport();
        }

        function onKeyEnter() as Boolean {
            ItemView.onKeyEnter();
            self.sendReport();
            return true;
        }

        function onKeyEsc() as Boolean {
            ItemView.onKeyEsc();
            self.goBack();
            return true;
        }

        private function sendReport() as Void {
            var pre__errorMsg;
            var app = $.getApp();
            if (app.Phone != null && app.Debug != null) {
                pre__errorMsg = self._errorMsg;
                var resp = ({}) as Dictionary<String, String or Number or Array<String> >;
                resp.put("type", "reportError");
                if (pre__errorMsg != null) {
                    resp.put("errorMsg", Application.loadResource(pre__errorMsg));
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
                Helper.ToastUtil.Toast(Rez.Strings.ErrReport, 2);
                self.goBack();
            }
        }

        private function loadVisuals() as Void {
            var txt, pre_0, pre_1;
            pre_0 = 0;
            if (self.Items.size() > pre_0) {
                self.Items = new Array<Item>[pre_0];
            }

            pre_1 = 1;
            txt /*>pre__errorMsg<*/ = self._errorMsg;
            if (txt /*>pre__errorMsg<*/ != null) {
                txt /*>errMsg<*/ = new Listitems.Item(self._mainLayer, Application.loadResource(txt /*>pre__errorMsg<*/), null, null, null, null, pre_0, null);
                txt /*>errMsg<*/.DrawLine = false;
                txt /*>errMsg<*/.isSelectable = false;
                txt /*>errMsg<*/.TitleJustification = pre_1 as Toybox.Graphics.TextJustification;
                self.Items.add(txt /*>errMsg<*/);
            }
            if (self._errorCode != null) {
                txt /*>errCode<*/ = new Listitems.Item(self._mainLayer, "0x" + self._errorCode.format("%04x"), null, null, null, null, pre_1, Helper.Fonts.Big());
                txt /*>errCode<*/.DrawLine = false;
                txt /*>errCode<*/.isSelectable = false;
                txt /*>errCode<*/.TitleJustification = pre_1 as Toybox.Graphics.TextJustification;
                self.Items.add(txt /*>errCode<*/);
            }

            txt /*>hint<*/ = new Listitems.Item(self._mainLayer, null, Application.loadResource(Rez.Strings.ErrHint), null, null, null, 2, null);
            txt /*>hint<*/.setSubFont(Helper.Fonts.Normal());
            txt /*>hint<*/.DrawLine = false;
            txt /*>hint<*/.isSelectable = false;
            txt /*>hint<*/.SubtitleJustification = pre_1 as Toybox.Graphics.TextJustification;
            self.Items.add(txt /*>hint<*/);

            txt = self.DisplayButtonSupport() ? Application.loadResource(Rez.Strings.ErrHintTouch) : Application.loadResource(Rez.Strings.ErrHintBtn);
            txt /*>hint2<*/ = new Listitems.Item(self._mainLayer, null, txt, null, null, null, 3, null);
            txt /*>hint2<*/.setSubFont(Helper.Fonts.Normal());
            txt /*>hint2<*/.DrawLine = false;
            txt /*>hint2<*/.isSelectable = false;
            txt /*>hint2<*/.SubtitleJustification = pre_1 as Toybox.Graphics.TextJustification;
            self.Items.add(txt /*>hint2<*/);
        }
    }
}
