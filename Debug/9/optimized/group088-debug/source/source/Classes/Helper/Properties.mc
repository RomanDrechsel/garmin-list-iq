using Debug;
import Toybox.Lang;
import Toybox.Application;
using Toybox.Application.Properties as Props;

(:glance)
module Helper {
    class Properties {
        typedef PropType as Number or Boolean or String;

        typedef EProps as Toybox.Lang.String;

        public static function Store(prop as EProps or String, value as PropType) as Void {
            var no_log = ["LastListScroll", "Init", "LastList"];

            try {
                Props.setValue(prop as String, value);
                if (no_log.indexOf(prop) < 0) {
                    Debug.Log("Stored property " + prop + " as " + value);
                }
            } catch (ex instanceof Lang.Exception) {
                Debug.Log("Could not store property " + prop + " as " + value + ": " + ex.getErrorMessage());
            }
        }

        public static function Get(prop as EProps or String, default_value as PropType?) as PropType {
            try {
                return Props.getValue(prop as String);
            } catch (ex instanceof Lang.Exception) {
                Debug.Log("Could not read property " + prop + ": " + ex.getErrorMessage());
            }
            return default_value;
        }
    }
}
