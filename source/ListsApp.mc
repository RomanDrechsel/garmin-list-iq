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

    function getInitialView() as Array<WatchUi.Views or WatchUi.InputDelegates>? {
        $.isGlanceView = false;
        var appVersion = "2025.01.0801";
        Application.Properties.setValue("appVersion", appVersion);

        self.Debug = new Debug.DebugStorage();
        Debug.Log("App started (" + appVersion + ")");

        self.ListsManager = new ListsManager();
        self.Phone = new Comm.PhoneCommunication();
        self.Inactivity = new Helper.Inactivity();

        var listview = new Views.ListsSelectView(true);
        return [listview, new Views.CustomViewDelegate(listview)];
    }

    function getGlanceView() as Array<WatchUi.GlanceView or WatchUi.GlanceViewDelegate>? {
        $.isGlanceView = true;
        var glance = new Views.GlanceView();
        return [glance];
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
        ret.add("TouchControls: " + $.TouchControls);
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
var TouchControls = System.getDeviceSettings().isTouchScreen;
var screenHeight = System.getDeviceSettings().screenHeight;

function getApp() as ListsApp {
    return Application.getApp() as ListsApp;
}

var isGlanceView = false;

(:debug)
var isDebug = true;
(:release)
var isDebug = false;
