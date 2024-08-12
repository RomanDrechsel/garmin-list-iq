import Toybox.Lang;
import Toybox.Application;
using Toybox.Application.Properties as Props;

module Helper {
    class Properties {
        private static var _props as Dictionary<EProps, PropType> = {};

        typedef PropType as Number or Boolean;

        public enum EProps {
            THEME = "Theme",
            LISTMOVEDOWN = "ListMoveDown",
            DOUBLETAPFORDONE = "DoubleTapForDone",
            SHOWNOTES = "ShowNotes",
        }

        public static function Load() {
            self._props = {};
            var prop = Props.getValue(THEME) as Number?;
            if (prop == null) {
                prop = 0;
            }
            self._props.put(THEME, prop);

            prop = Props.getValue(LISTMOVEDOWN) as Boolean?;
            if (prop == null) {
                prop = true;
            } else if (prop instanceof Lang.Number) {
                prop = prop == 1 ? true : false;
                self.Store(LISTMOVEDOWN, prop as Boolean);
            }
            self._props.put(LISTMOVEDOWN, prop);

            prop = Props.getValue(DOUBLETAPFORDONE) as Boolean?;
            if (prop == null) {
                prop = true;
            } else if (prop instanceof Lang.Number) {
                prop = prop == 1 ? true : false;
                self.Store(DOUBLETAPFORDONE, prop as Boolean);
            }
            self._props.put(DOUBLETAPFORDONE, prop);

            prop = Props.getValue(SHOWNOTES) as Boolean?;
            if (prop == null) {
                prop = true;
            } else if (prop instanceof Lang.Number) {
                prop = prop == 1 ? true : false;
                self.Store(SHOWNOTES, prop as Boolean);
            }
            self._props.put(SHOWNOTES, prop);
            Debug.Log("Properties: " + self._props);
        }

        public static function Store(prop as EProps, value as PropType) {
            Application.Properties.setValue(prop as String, value);
            self._props.put(prop, value);
            Debug.Log("Stored property " + prop + " as " + value);
        }

        public static function Get(prop as EProps, default_value as PropType?) {
            var ret = self._props.get(prop);
            if (ret != null) {
                Debug.Log("Get property " + prop + " as " + ret);
                return ret;
            } else {
                return default_value;
            }
        }
    }
}
