import Controls;
import Controls.Listitems;
import Exceptions;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Application;
import Toybox.WatchUi;

module Views {
    class ErrorView extends ItemView {
        private var _errorMsg as Lang.ResourceId? = null;
        private var _errorMsg2 as Lang.ResourceId? = null;
        private var _errorMsg3 as Lang.ResourceId? = null;
        private var _errorCode as Lang.Number? = null;
        private var _errorPayload as Array<String>?;

        private static var _instance as ErrorView? = null;
        public static var ErrorCode = null as ECode;
        private var _isValid = false;

        public enum ECode {
            OUT_OF_MEMORY = 0,
            LIST_REC_INVALID = 1,
            LIST_REC_STORE_FAILED = 2,
            LIST_REC_INDEX_STORE_FAILED = 3,
            LIST_DEL_FAILED = 100,
            LEGACY_APP = 150,
        }

        function initialize() {
            ItemView.initialize();
            self._instance = self;
        }

        public function onLayout(dc as Dc) as Void {
            ItemView.onLayout(dc);
            self.loadVisuals();
        }

        public function onHide() as Void {
            ItemView.onHide();
            self._instance = null;
        }

        public function onUpdate(dc as Dc) as Void {
            if (!self._isValid) {
                self.loadVisuals();
            }
            ItemView.onUpdate(dc);
        }

        public function onTap(x as Number, y as Number) as Boolean {
            if (!ItemView.onTap(x, y)) {
                self.interact();
            }
            return false;
        }

        public function onKeyEnter() as Boolean {
            if (!ItemView.onKeyEnter()) {
                self.interact();
                return true;
            }
            return false;
        }

        public function onKeyEsc() as Boolean {
            ItemView.onKeyEsc();
            self.goBack();
            return true;
        }

        public function SetError(code as ECode, payload as Array<String>?) {
            self.ErrorCode = code;
            self._errorCode = null;
            self._errorPayload = payload;
            self._errorMsg = null;
            self._errorMsg2 = null;
            self._errorMsg3 = null;

            if (code == OUT_OF_MEMORY) {
                self._errorMsg = Rez.Strings.ListRecOOM;
            } else if (code == LIST_REC_INVALID || code == LIST_REC_STORE_FAILED || code == LIST_REC_INDEX_STORE_FAILED) {
                self._errorMsg = Rez.Strings.ErrListRec;
                self._errorMsg2 = Rez.Strings.ErrHint;
                self._errorMsg3 = self.DisplayButtonSupport() ? Rez.Strings.ErrHintTouch : Rez.Strings.ErrHintBtn;
                self._errorCode = code;
            } else if (code == LIST_DEL_FAILED) {
                self._errorMsg = Rez.Strings.ErrListDel;
                self._errorMsg2 = Rez.Strings.ErrHint;
                self._errorMsg3 = self.DisplayButtonSupport() ? Rez.Strings.ErrHintTouch : Rez.Strings.ErrHintBtn;
                self._errorCode = LIST_DEL_FAILED;
            } else if (code == LEGACY_APP) {
                self._errorMsg = Rez.Strings.LegacyPhoneApp;
                self._errorMsg2 = self.DisplayButtonSupport() ? Rez.Strings.NoListsLinkBtn : Rez.Strings.NoListsLink;
            } else {
                self._errorMsg = Rez.Strings.ErrUnknown;
            }

            self._isValid = false;
        }

        private function interact() as Void {
            if ([LIST_REC_INVALID, LIST_REC_STORE_FAILED, LIST_REC_INDEX_STORE_FAILED, LIST_DEL_FAILED].indexOf(self.ErrorCode) >= 0) {
                var app = $.getApp();
                if (app.Phone != null && app.Debug != null) {
                    var send = ["type=reportError"];
                    if (self._errorMsg != null) {
                        send.add("msg=" + Application.loadResource(self._errorMsg));
                    }
                    if (self._errorCode != null) {
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
            } else if (self.ErrorCode == LEGACY_APP) {
                $.openGooglePlay();
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
            }

            if (self._errorMsg2 != null) {
                var hint = new Listitems.Item(self._mainLayer, null, Application.loadResource(self._errorMsg2), null, null, null, 2, null);
                hint.setSubFont(Helper.Fonts.Normal());
                hint.DrawLine = false;
                hint.isSelectable = false;
                hint.SubtitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
                self.Items.add(hint);
            }

            if (self._errorMsg3 != null) {
                var hint2 = new Listitems.Item(self._mainLayer, null, Application.loadResource(self._errorMsg3), null, null, null, 3, null);
                hint2.setSubFont(Helper.Fonts.Normal());
                hint2.DrawLine = false;
                hint2.isSelectable = false;
                hint2.SubtitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
                self.Items.add(hint2);
            }

            if ($.getApp().NoBackButton) {
                self.addBackButton(false);
            }
            self._isValid = true;
        }

        public static function Show(code as ECode, payload as Array<String>?) {
            if (self._instance != null) {
                if (self.ErrorCode != code) {
                    self._instance.SetError(code, payload);
                    WatchUi.requestUpdate();
                }
            } else {
                var errorView = new Views.ErrorView();
                errorView.SetError(code, payload);
                WatchUi.pushView(errorView, new Views.ItemViewDelegate(errorView), WatchUi.SLIDE_BLINK);
            }
        }
    }
}
