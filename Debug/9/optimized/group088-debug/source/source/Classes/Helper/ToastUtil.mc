using Rez;
import Toybox.Lang;
import Toybox.Application;
import Toybox.WatchUi;
import Toybox.Attention;

module Helper {
    class ToastUtil {
        typedef ToastType as Toybox.Lang.Number;

        public static function Toast(msg_id as Lang.ResourceId, type as ToastType) {
            var pre_1;
            pre_1 = 1;
            if (WatchUi has :showToast) {
                msg_id /*>str<*/ = Application.loadResource(msg_id);

                if (type == 0) {
                    WatchUi.showToast(msg_id /*>str<*/, { :icon => Rez.Drawables.Success });
                } else if (type == pre_1) {
                    WatchUi.showToast(msg_id /*>str<*/, { :icon => Rez.Drawables.Error });
                } else if (type == 2) {
                    WatchUi.showToast(msg_id /*>str<*/, { :icon => Rez.Drawables.Attention });
                }
            }

            if (Attention has :vibrate) {
                msg_id /*>length<*/ = 100;
                if (type == pre_1) {
                    msg_id /*>length<*/ = 1000;
                }

                Attention.vibrate([new Attention.VibeProfile(50, msg_id /*>length<*/)]);
            } else if (Attention has :playTone) {
                if (type == 0) {
                    Attention.playTone(3 as Toybox.Attention.Tone);
                } else if (type == pre_1) {
                    Attention.playTone(18 as Toybox.Attention.Tone);
                }
            }
        }
    }
}
