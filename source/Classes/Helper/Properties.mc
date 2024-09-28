import Toybox.Lang;
import Toybox.Application;
using Toybox.Application.Properties as Props;

module Helper {
    class Properties {
        typedef PropType as Number or Boolean;

        public enum EProps {
            THEME = "Theme",
            LISTMOVEDOWN = "ListMoveDown",
            DOUBLETAPFORDONE = "DoubleTapForDone",
            SHOWNOTES = "ShowNotes",
            LOGS = "Logs",
            PERSISTENTLOGS = "PersistentLogs",
        }

        public static function Store(prop as EProps, value as PropType) {
            Props.setValue(prop as String, value);
            Debug.Log("Stored property " + prop + " as " + value);
        }

        public static function Get(prop as EProps, default_value as PropType?) {
            try {
                return Props.getValue(prop as String);
            } catch (ex instanceof Lang.Exception) {
                Debug.Log("Could not read property " + prop + ": " + ex.getErrorMessage());
            }
            return default_value;
        }
    }
}
