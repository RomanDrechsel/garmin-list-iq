import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
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
    var onSettingsChangedListeners as Array<Object> = [];
    var isGlanceView = false;
    var NoBackButton = false;

    function getInitialView() as Array<WatchUi.Views or WatchUi.InputDelegates>? {
        self.isGlanceView = false;
        var appVersion = "2025.01.0801";
        Application.Properties.setValue("appVersion", appVersion);

        self.Debug = new Debug.DebugStorage();
        Debug.Log("App started (" + appVersion + ")");

        var settings = System.getDeviceSettings();
        if ((settings.inputButtons & System.BUTTON_INPUT_ESC) == 0) {
            self.NoBackButton = true;
        }

        self.ListsManager = new ListsManager();
        self.Phone = new Comm.PhoneCommunication();
        self.Inactivity = new Helper.Inactivity();

        Debug.Log(self.getInfo());

        var startview = new Views.ListsSelectView(true);
        //var startview = new Debug.TestView();
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
        if (self.Debug != null) {
            self.Debug.onSettingsChanged();
        }
        Themes.ThemesLoader.loadTheme();
        Debug.Log("Settings changed");
        if (self.onSettingsChangedListeners instanceof Array) {
            for (var i = 0; i < self.onSettingsChangedListeners.size(); i++) {
                if (self.onSettingsChangedListeners[i] has :onSettingsChanged) {
                    self.onSettingsChangedListeners[i].onSettingsChanged();
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

    function openGooglePlay() as Void {
        Communications.openWebPage("https://play.google.com/store/apps/details?id=de.romandrechsel.lists", null, null);
    }
}

var isRoundDisplay = System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND;
var screenHeight = System.getDeviceSettings().screenHeight;

function getApp() as ListsApp {
    return Application.getApp() as ListsApp;
}

(:debug)
var isDebug = true;
(:release)
var isDebug = false;
