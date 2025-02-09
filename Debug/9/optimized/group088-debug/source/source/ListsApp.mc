using Themes;
using Helper;
using Toybox.Application.Properties;
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
    var Phone = null;
    var ListsManager = null;
    var Debug = null;
    var Inactivity = null;
    var GlobalStates as Dictionary<String, Object> = {};
    var isGlanceView = false;
    var NoBackButton = false;
    private var onSettingsChangedListeners as Array<WeakReference> = [];

    function getInitialView() as Array<WatchUi.Views or WatchUi.InputDelegates>? {
        self.isGlanceView = false;
        Properties /*>Application.Properties<*/.setValue("appVersion", "2025.02.0900");

        self.Debug = new Debug.DebugStorage();

        if ((System.getDeviceSettings().inputButtons & 128) == 0) {
            self.NoBackButton = true;
        }

        self.ListsManager = new ListsManager();
        self.Phone = new Comm.PhoneCommunication();
        self.Inactivity = new Helper.Inactivity();

        //Debug.Log(self.getInfo());

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
        var pre_Debug;
        Debug.Log("Settings changed");
        pre_Debug = self.Debug;
        if (pre_Debug != null) {
            pre_Debug.onSettingsChanged();
        }
        Themes.ThemesLoader.loadTheme();
        for (var i = 0; i < self.onSettingsChangedListeners.size(); i += 1) {
            pre_Debug /*>weak<*/ = self.onSettingsChangedListeners[i];
            if (pre_Debug /*>weak<*/.stillAlive()) {
                pre_Debug /*>obj<*/ = pre_Debug /*>weak<*/.get();
                if (pre_Debug /*>obj<*/ != null && pre_Debug /*>obj<*/ has :onSettingsChanged) {
                    pre_Debug /*>obj<*/.onSettingsChanged();
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
            case 1 as Toybox.System.ScreenShape:
                screenShape = "Round";
                break;
            case 3 as Toybox.System.ScreenShape:
                screenShape = "Square";
                break;
            case 4 as Toybox.System.ScreenShape:
                screenShape = "Semi-Octagon";
                break;
            case 2 as Toybox.System.ScreenShape:
                screenShape = "Semi-Round";
                break;
        }

        var ret = [] as Array<String>;
        ret.add("Version: " + Properties /*>Application.Properties<*/.getValue("appVersion"));
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
        var ref, pre_onSettingsChangedListeners, pre_0;
        pre_0 = 0;
        var del = [];
        pre_onSettingsChangedListeners = self.onSettingsChangedListeners;
        {
            ref /*>i<*/ = pre_0;
            for (; ref /*>i<*/ < pre_onSettingsChangedListeners.size(); ref /*>i<*/ += 1) {
                var weak = self.onSettingsChangedListeners[ref /*>i<*/];
                if (weak.stillAlive()) {
                    var o = weak.get();
                    if (o == null || !(o has :onSettingsChanged)) {
                        del.add(weak);
                    }
                } else {
                    del.add(weak);
                }
            }
        }
        if (del.size() > pre_0) {
            {
                ref /*>i<*/ = pre_0;
                for (; ref /*>i<*/ < del.size(); ref /*>i<*/ += 1) {
                    self.onSettingsChangedListeners.remove(del[ref /*>i<*/]);
                }
            }
        }

        if (obj has :onSettingsChanged) {
            ref = obj.weak();

            if (pre_onSettingsChangedListeners.indexOf(ref) < pre_0) {
                self.onSettingsChangedListeners.add(ref);
            }
        }
    }
}

(:glance)
function getApp() as ListsApp {
    return Application.getApp() as ListsApp;
}

(:regularVersion)
var isRoundDisplay = false;

var screenHeight = System.getDeviceSettings().screenHeight;

(:debug)
var isDebug = true;
