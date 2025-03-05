import Controls;
import Controls.Listitems;
import Exceptions;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Application;

module Views {
    class ErrorView extends ItemView {
        private var _errorMsg as Lang.ResourceId? = null;
        private var _errorCode as Lang.Number? = null;
        private var _errorPayload as Array<String>?;

        function initialize(msg as Lang.ResourceId?, code as Lang.Number?, payload as Array<String>?) {
            ItemView.initialize();
            self._errorMsg = msg;
            self._errorCode = code;
            self._errorPayload = payload;
        }

        function onLayout(dc as Dc) as Void {
            ItemView.onLayout(dc);
            self.loadVisuals();
        }

        function onHide() as Void {
            ItemView.onHide();
            $.getApp().MemoryCheck.ShowErrorView = true;
        }

        function onTap(x as Number, y as Number) as Boolean {
            if (!ItemView.onTap(x, y)) {
                self.sendReport();
            }
            return false;
        }

        function onKeyEnter() as Boolean {
            if (!ItemView.onKeyEnter()) {
                self.sendReport();
                return true;
            }
            return false;
        }

        function onKeyEsc() as Boolean {
            ItemView.onKeyEsc();
            self.goBack();
            return true;
        }

        private function sendReport() as Void {
            var app = $.getApp();
            if (app.Phone != null && app.Debug != null) {
                var send = ["type=reportError"];
                if (self._errorMsg != null) {
                    send.add("msg=" + Application.loadResource(self._errorMsg));
                }
                if (self._errorCode) {
                    send.add("code=0x" + self._errorCode.format("%04x"));
                }
                if (self._errorPayload != null) {
                    var str = "payload";
                    var payload_index = 0;
                    while (self._errorPayload.size() > 0) {
                        send.add(str + payload_index + "=" + self._errorPayload[0]);
                        self._errorPayload = self._errorPayload.slice(1, null);
                        payload_index += 1;
                    }
                }

                var logs = app.Debug.GetLogs() as Array<String>;
                for (var i = 0; i < logs.size(); i++) {
                    send.add("log" + i + "=" + logs[i]);
                }
                app.Phone.SendToPhone(send);
                Debug.Log("Send error report code 0x" + self._errorCode.format("%04x") + " to smartphone");
                Helper.ToastUtil.Toast(Rez.Strings.ErrReport, Helper.ToastUtil.ATTENTION);
                self.goBack();
            }
        }

        private function loadVisuals() as Void {
            if (self.Items.size() > 0) {
                self.Items = new Array<Item>[0];
            }

            if (self._errorMsg != null) {
                var errMsg = new Listitems.Item(self._mainLayer, Application.loadResource(self._errorMsg), null, null, null, null, 0, null);
                errMsg.DrawLine = false;
                errMsg.isSelectable = false;
                errMsg.TitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
                self.Items.add(errMsg);
            }

            if (self._errorCode != null) {
                var errCode = new Listitems.Item(self._mainLayer, "0x" + self._errorCode.format("%04x"), null, null, null, null, 1, Helper.Fonts.Big());
                errCode.DrawLine = false;
                errCode.isSelectable = false;
                errCode.TitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
                self.Items.add(errCode);

                var hint = new Listitems.Item(self._mainLayer, null, Application.loadResource(Rez.Strings.ErrHint), null, null, null, 2, null);
                hint.setSubFont(Helper.Fonts.Normal());
                hint.DrawLine = false;
                hint.isSelectable = false;
                hint.SubtitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
                self.Items.add(hint);

                var txt = self.DisplayButtonSupport() ? Application.loadResource(Rez.Strings.ErrHintTouch) : Application.loadResource(Rez.Strings.ErrHintBtn);
                var hint2 = new Listitems.Item(self._mainLayer, null, txt, null, null, null, 3, null);
                hint2.setSubFont(Helper.Fonts.Normal());
                hint2.DrawLine = false;
                hint2.isSelectable = false;
                hint2.SubtitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
                self.Items.add(hint2);
            }

            if ($.getApp().NoBackButton) {
                self.addBackButton(false);
            }
        }
    }
}
