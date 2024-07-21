import Toybox.Lang;
import Toybox.Application;
using Toybox.Application.Properties as Props;

module Helper {
    class Properties {
        private static var _props as Dictionary<EProps, Number> = {};

        public enum EProps {
            THEME = "Theme",
            LISTMOVEDOWN = "ListMoveDown",
            DOUBLETAPFORDONE = "DoubleTapForDone",
            SHOWNOTES = "ShowNotes",
        }

        public static function Load() {
            self._props = {};
            var prop = Props.getValue("Theme") as Number?;
            if (prop == null) {
                prop = 0;
            }
            self._props.put(THEME, prop);

            prop = Props.getValue("ListMoveDown") as Number?;
            if (prop == null) {
                prop = 1;
            }
            self._props.put(LISTMOVEDOWN, prop);

            prop = Props.getValue("DoubleTapForDone") as Number?;
            if (prop == null) {
                prop = 1;
            }
            self._props.put(DOUBLETAPFORDONE, prop);

            prop = Props.getValue("ShowNotes") as Number?;
            if (prop == null) {
                prop = 1;
            }
            self._props.put(SHOWNOTES, prop);
            Debug.Log("Properties: " + self._props);
        }

        public static function SaveBoolean(prop as EProps, originalValue as Boolean) {
            var value = (originalValue ? 1 : 0) as Number;
            Application.Properties.setValue(prop as String, value);
            self._props.put(prop, value);
            Debug.Log("Stored property " + prop + " as " + value);
        }

        static function Number(prop as Helper.Properties.EProps, default_value as Number) as Number {
            var ret = self._props.get(prop);
            if (ret != null) {
                return ret;
            } else {
                return default_value;
            }
        }

        static function Boolean(prop as Helper.Properties.EProps, default_value as Boolean) as Boolean {
            var ret = self._props.get(prop);
            Debug.Log("Get property " + prop + " as " + ret);
            if (ret != null) {
                return (ret > 0) as Boolean;
            }
        }
    }
}
