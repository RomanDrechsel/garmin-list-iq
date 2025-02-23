import Toybox.Lang;
import Toybox.Application;
import Toybox.WatchUi;
import Toybox.Attention;

module Helper {
    class ToastUtil {
        enum ToastType {
            SUCCESS,
            ERROR,
            ATTENTION,
        }

        public static function Toast(msg_id as Lang.ResourceId, type as ToastType) as Void {
            if (WatchUi has :showToast) {
                var str = Application.loadResource(msg_id);

                if (type == SUCCESS) {
                    WatchUi.showToast(str, { :icon => Rez.Drawables.Success });
                } else if (type == ERROR) {
                    WatchUi.showToast(str, { :icon => Rez.Drawables.Error });
                } else if (type == ATTENTION) {
                    WatchUi.showToast(str, { :icon => Rez.Drawables.Attention });
                }
            }

            if (Attention has :vibrate) {
                var length = 100;
                if (type == ERROR) {
                    length = 1000;
                }

                Attention.vibrate([new Attention.VibeProfile(50, length)]);
            } else if (Attention has :playTone) {
                if (type == SUCCESS) {
                    Attention.playTone(Attention.TONE_MSG);
                } else if (type == ERROR) {
                    Attention.playTone(Attention.TONE_ERROR);
                }
            }
        }
    }
}
