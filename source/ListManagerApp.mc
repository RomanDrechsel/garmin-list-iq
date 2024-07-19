import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Views;
import Comm;
import Lists;

class ListManagerApp extends Application.AppBase {
    private var ListsReceiver as ListsReceiver;

    var ListsManager as ListsManager;
    var startupList = null;

    function initialize() {
        AppBase.initialize();
        Application.Properties.setValue("appVersion", "2024.7.1900");
        Helper.Properties.Load();
        self.ListsManager = new ListsManager();
        self.ListsReceiver = new ListsReceiver();
        self.ListsReceiver.Start();
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
        WatchUi.requestUpdate();
    }
}

var isRoundDisplay = System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND;

function getApp() as ListManagerApp {
    return Application.getApp() as ListManagerApp;
}

function getAppStore() as String {
    return "https://play.google.com/store/apps/details?id=de.romandrechsel.lists";
}
