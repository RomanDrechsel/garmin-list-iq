import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Communications;
import Views;
import Comm;
import Lists;
import Debug;

(:glance)
class ListsApp extends Application.AppBase {
    var Phone = null as PhoneCommunication?;
    var ListsManager = null as ListsManager?;
    var Debug = null as DebugStorage?;
    var Inactivity = null as Helper.Inactivity?;
    var GlobalStates as Dictionary<String, Object> = {};
    var isGlanceView = false;
    var NoBackButton = false;
    private var onSettingsChangedListeners as Array<WeakReference> = [];

    function getInitialView() as Array<WatchUi.Views or WatchUi.InputDelegates>? {
        self.isGlanceView = false;
        var appVersion = "2025.02.1800";
        Application.Properties.setValue("appVersion", appVersion);

        self.Debug = new Debug.DebugStorage();

        var settings = System.getDeviceSettings();
        if ((settings.inputButtons & System.BUTTON_INPUT_ESC) == 0) {
            self.NoBackButton = true;
        }

        self.ListsManager = new ListsManager();
        self.Phone = new Comm.PhoneCommunication();
        self.Inactivity = new Helper.Inactivity();

        var startview = new Views.ListsSelectView(true);
        return [startview, new Views.ItemViewDelegate(startview)];
    }

    function getGlanceView() as Array<WatchUi.GlanceView or WatchUi.GlanceViewDelegate>? {
        self.isGlanceView = true;
        return [new Views.GlanceView()];
    }

    function onSettingsChanged() as Void {
        self.triggerOnSettingsChanged();
    }

    function triggerOnSettingsChanged() as Void {
        Debug.Log("Settings changed");
        if (self.Debug != null) {
            self.Debug.onSettingsChanged();
        }
        Themes.ThemesLoader.loadTheme();
        for (var i = 0; i < self.onSettingsChangedListeners.size(); i++) {
            var weak = self.onSettingsChangedListeners[i];
            if (weak.stillAlive()) {
                var obj = weak.get();
                if (obj != null && obj has :onSettingsChanged) {
                    obj.onSettingsChanged();
                }
            }
        }

        WatchUi.requestUpdate();
    }

    function getInfo() as Array<String> {
        var settings = System.getDeviceSettings();
        var stats = System.getSystemStats();

        var screenShape = settings.screenShape;
        switch (screenShape) {
            case System.SCREEN_SHAPE_ROUND:
                screenShape = "Round";
                break;
            case System.SCREEN_SHAPE_RECTANGLE:
                screenShape = "Square";
                break;
            case System.SCREEN_SHAPE_SEMI_OCTAGON:
                screenShape = "Semi-Octagon";
                break;
            case System.SCREEN_SHAPE_SEMI_ROUND:
                screenShape = "Semi-Round";
                break;
        }

        var ret = [] as Array<String>;
        ret.add("Version: " + Application.Properties.getValue("appVersion"));
        ret.add("Display: " + screenShape);
        ret.add("Touchscreen: " + settings.isTouchScreen);
        ret.add("Controls: " + Views.ItemView.SupportedControls());
        ret.add("LowColors Display: " + Themes.ThemesLoader.LowColors());
        ret.add("Firmware: " + settings.firmwareVersion);
        ret.add("Monkey Version: " + settings.monkeyVersion);
        ret.add("Memory: " + stats.usedMemory + " / " + stats.totalMemory);
        ret.add("Language: " + settings.systemLanguage);
        ret.add("Lists in Storage: " + self.ListsManager.GetLists().size());
        return ret;
    }

    static function openGooglePlay() as Void {
        Communications.openWebPage("https://play.google.com/store/apps/details?id=de.romandrechsel.lists", null, null);
    }

    function addSettingsChangedListener(obj as Object) as Void {
        var del = [];
        for (var i = 0; i < self.onSettingsChangedListeners.size(); i++) {
            var weak = self.onSettingsChangedListeners[i];
            if (weak.stillAlive()) {
                var o = weak.get();
                if (o == null || !(o has :onSettingsChanged)) {
                    del.add(weak);
                }
            } else {
                del.add(weak);
            }
        }
        if (del.size() > 0) {
            for (var i = 0; i < del.size(); i++) {
                self.onSettingsChangedListeners.remove(del[i]);
            }
        }

        if (obj has :onSettingsChanged) {
            var ref = obj.weak();

            if (self.onSettingsChangedListeners.indexOf(ref) < 0) {
                self.onSettingsChangedListeners.add(ref);
            }
        }
    }
}

(:glance)
function getApp() as ListsApp {
    return Application.getApp() as ListsApp;
}

(:roundVersion)
var isRoundDisplay = true;
(:regularVersion)
var isRoundDisplay = false;

var screenHeight = System.getDeviceSettings().screenHeight;

(:debug)
var isDebug = true;
(:release)
var isDebug = false;
