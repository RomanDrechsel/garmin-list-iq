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

                var options = null;
                if (type == SUCCESS && Rez.Drawables has :Success) {
                    options = { :icon => Rez.Drawables.Success };
                } else if (type == ERROR && Rez.Drawables has :Error) {
                    options = { :icon => Rez.Drawables.Error };
                } else if (type == ATTENTION && Rez.Drawables has :Attention) {
                    options = { :icon => Rez.Drawables.Attention };
                }

                WatchUi.showToast(str, options);
            }

            if (Attention has :vibrate) {
                var length = 100;
                if (type == ERROR) {
                    length = 500;
                }

                Attention.vibrate([new Attention.VibeProfile(50, length)]);
            }
        }
    }
}
