import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Views;
import Comm;
import Lists;
import Debug;

class ListsApp extends Application.AppBase {
    private var PhoneReceiver as PhoneReceiver;
    var ListsManager as ListsManager;
    var Debug as DebugStorage;
    var startupList = null as String?;
    var GlobalStates as Dictionary<String, Object> = {};

    function initialize() {
        AppBase.initialize();
        Application.Properties.setValue("appVersion", "2024.10.0400");

        self.Debug = new Debug.DebugStorage();
        self.ListsManager = new ListsManager();
        Debug.Log(self.getInfo());
        self.PhoneReceiver = new PhoneReceiver();
    }

    function onStart(state as Lang.Dictionary?) as Void {
        self.startupList = Helper.Properties.Get(Helper.Properties.LASTLIST, "");
        Helper.Properties.Store(Helper.Properties.LASTLIST, "");
    }

    function getInitialView() as Array<WatchUi.Views or WatchUi.InputDelegates>? {
        var listview = new Views.ListsSelectView();
        return [listview, new Views.ListsSelectViewDelegate(listview)] as Array<WatchUi.Views or InputDelegates>;
    }

    function onSettingsChanged() as Void {
        self.Debug.onSettingsChanged();
        Themes.ThemesLoader.loadTheme();

        Debug.Log("Settings changed");
        if ($.onSettingsChanged instanceof Array) {
            for (var i = 0; i < $.onSettingsChanged.size(); i++) {
                if ($.onSettingsChanged[i] has :onSettingsChanged) {
                    $.onSettingsChanged[i].onSettingsChanged();
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
        ret.add("Firmware: " + settings.firmwareVersion);
        ret.add("Monkey Version: " + settings.monkeyVersion);
        ret.add("Memory: " + stats.usedMemory + " / " + stats.totalMemory);
        ret.add("Lists in Storage: " + self.ListsManager.GetLists().size());
        return ret;
    }
}

var isRoundDisplay = System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND;
var onSettingsChanged as Array<Object> = [];

function getApp() as ListsApp {
    return Application.getApp() as ListsApp;
}

function getAppStore() as String {
    return "https://play.google.com/store/apps/details?id=de.romandrechsel.lists";
}
