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
        private var _errorPayload as Dictionary<String, Object>?;

        function initialize(msg as Lang.ResourceId?, code as Lang.Number?, payload as Dictionary<String, Object>?) {
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
            var pre__errorMsg, pre____, pre_0, pre_1;
            var app = $.getApp();
            if (app.Phone != null && app.Debug != null) {
                var logs;
                pre__errorMsg = self._errorMsg;
                var send = ["type=reportError"];
                if (pre__errorMsg != null) {
                    send.add("msg=" + Application.loadResource(pre__errorMsg));
                }
                if (self._errorCode) {
                    send.add("code=0x" + self._errorCode.format("%04x"));
                }
                pre_1 = 1;
                pre_0 = 0;
                pre____ = "=";
                if (self._errorPayload != null) {
                    var payload_index = pre_0;
                    var keys = self._errorPayload.keys();
                    for (var i = pre_0; i < keys.size(); i += pre_1) {
                        var val = self._errorPayload.get(keys[i]);
                        if (val instanceof Array) {
                            {
                                pre__errorMsg /*>j<*/ = pre_0;
                                for (; pre__errorMsg /*>j<*/ < val.size(); pre__errorMsg /*>j<*/ += pre_1) {
                                    send.add("payload" + payload_index + pre____ + keys[i] + pre__errorMsg /*>j<*/ + pre____ + val[pre__errorMsg /*>j<*/]);
                                    payload_index += pre_1;
                                }
                            }
                        } else if (val instanceof Dictionary) {
                            var val_keys = val.keys();
                            {
                                logs /*>j<*/ = pre_0;
                                for (; logs /*>j<*/ < val_keys.size(); logs /*>j<*/ += pre_1) {
                                    pre__errorMsg /*>key<*/ = val_keys[logs /*>j<*/];
                                    send.add("payload" + payload_index + pre____ + keys[i] + logs /*>j<*/ + pre____ + pre__errorMsg /*>key<*/ + pre____ + val.get(pre__errorMsg /*>key<*/));
                                    payload_index += pre_1;
                                }
                            }
                        }
                    }
                }

                logs = app.Debug.GetLogs();
                {
                    pre__errorMsg /*>i<*/ = pre_0;
                    for (; pre__errorMsg /*>i<*/ < logs.size(); pre__errorMsg /*>i<*/ += pre_1) {
                        send.add("log" + pre__errorMsg /*>i<*/ + pre____ + logs[pre__errorMsg /*>i<*/]);
                    }
                }
                app.Phone.SendToPhone(send);
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

            if ($.getApp().NoBackButton) {
                self.addBackButton(false);
            }
        }
    }
}
