import Toybox.Lang;
import Toybox.Application;
using Toybox.Application.Properties as Props;

module Helper {
    class Properties {
        typedef PropType as Number or Boolean or String;

        public enum EProps {
            THEME = "Theme",
            LISTMOVEDOWN = "ListMoveDown",
            DOUBLETAPFORDONE = "DoubleTapForDone",
            SHOWNOTES = "ShowNotes",
            LASTLIST = "LastList",
            LOGS = "Logs",
            PERSISTENTLOGS = "PersistentLogs",
        }

        public static function Store(prop as EProps, value as PropType) {
            try {
                Props.setValue(prop as String, value);
                Debug.Log("Stored property " + prop + " as " + value);
            } catch (ex instanceof Lang.Exception) {
                Debug.Log("Could not store property " + prop + " as " + value + ": " + ex.getErrorMessage());
            }
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
