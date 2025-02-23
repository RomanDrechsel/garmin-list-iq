import Toybox.Lang;
import Toybox.Application;
using Toybox.Application.Properties as Props;

module Helper {
    class Properties {
        typedef PropType as Number or Boolean or String;

        (:glance,:background)
        public enum EProps {
            INIT = "Init",
            THEME = "Theme",
            LISTMOVEDOWN = "ListMoveDown",
            DOUBLETAPFORDONE = "DoubleTapForDone",
            SHOWNOTES = "ShowNotes",
            LASTLIST = "LastList",
            LASTLISTSCROLL = "LastListScroll",
            LOGS = "Logs",
            PERSISTENTLOGS = "PersistentLogs",
            AUTOEXIT = "AutoExit",
            HWBCTRL = "HWBCtrl",
        }

        public static function Store(prop as EProps or String, value as PropType) as Void {
            if ($.getApp().isBackground) {
                return;
            }
            var no_log = [LASTLISTSCROLL, INIT, LASTLIST];

            try {
                Props.setValue(prop as String, value);
                if (no_log.indexOf(prop) < 0) {
                    Debug.Log("Stored property " + prop + " as " + value);
                }
            } catch (ex instanceof Lang.Exception) {
                Debug.Log("Could not store property " + prop + " as " + value + ": " + ex.getErrorMessage());
            }
        }

        (:glance,:background)
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
