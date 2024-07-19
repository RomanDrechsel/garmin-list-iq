import Toybox.Lang;
import Toybox.Application;
using Toybox.Application.Properties as Props;

module Helper {
    class Properties {
        private static var _props as Dictionary<EProps, Application.PropertyValueType> = {};

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
            Toybox.System.println(self._props);
        }

        public static function Save(prop as EProps, orginalValue as Application.PropertyValueType) {
            var value = orginalValue instanceof Boolean ? (orginalValue ? 1 : 0) as Number : orginalValue;
            Application.Properties.setValue(prop as String, value);
            self._props.put(prop, value);
        }

        static function Number(prop as Helper.Properties.EProps, default_value as Number) as Number {
            var ret = self._props.get(prop);
            if (ret instanceof Number) {
                return ret;
            } else {
                return default_value;
            }
        }

        static function Boolean(prop as Helper.Properties.EProps, default_value as Boolean) as Boolean {
            var ret = self._props.get(prop);
            if (ret instanceof Number) {
                return ret > 0;
            } else {
                return default_value;
            }
        }
    }
}
