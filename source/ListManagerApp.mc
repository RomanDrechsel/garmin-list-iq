import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Views;
import Comm;
import Lists;

class ListsApp extends Application.AppBase {
    private var PhoneReceiver as PhoneReceiver;

    var ListsManager as ListsManager;
    var startupList = null;
    var GlobalStates as Dictionary<String, Object> = {};

    function initialize() {
        AppBase.initialize();
        Application.Properties.setValue("appVersion", "2024.9.2700");

        var logs = self.getInfo();
        for (var i = 0; i < logs.size(); i++) {
            Debug.Log(logs[i]);
        }

        self.ListsManager = new ListsManager();
        self.PhoneReceiver = new PhoneReceiver();
    }

    function onStart(state as Lang.Dictionary?) as Void {
        self.startupList = Application.Storage.getValue("LastList");
        Application.Storage.deleteValue("LastList");
    }

    function getInitialView() as Array<WatchUi.Views or WatchUi.InputDelegates>? {
        var listview = new Views.ListsSelectView();
        return [listview, new Views.ListsSelectViewDelegate(listview)] as Array<WatchUi.Views or InputDelegates>;
    }

    function onSettingsChanged() as Void {
        Helper.Properties.Load();
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

        var ret = [] as Array<String>;
        ret.add("Version: " + Application.Properties.getValue("appVersion"));
        ret.add("Display: " + settings.screenShape);
        ret.add("Firmware: " + settings.firmwareVersion);
        ret.add("Monkey Version: " + settings.monkeyVersion);
        ret.add("Memory: " + stats.usedMemory + " / " + stats.totalMemory);
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
