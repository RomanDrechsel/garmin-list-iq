import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Communications;
import Toybox.Background;
import Toybox.Timer;
import Views;
import Comm;
import Lists;
import Debug;

(:glance,:background)
class ListsApp extends Application.AppBase {
    enum EState {
        STARTPAGE = 1,
        MOVETOP = 2,
        LEGACYLIST = 3,
    }

    var Phone = null as PhoneCommunication?;
    var ListsManager = null as ListsManager?;
    var Debug = null as DebugStorage?;
    var Inactivity = null as Helper.Inactivity?;
    var BackgroundService = null as BG.Service?;
    var MemoryCheck as Helper.MemoryChecker;
    var GlobalStates as Array<EState> = [];
    var isGlanceView = false;
    var isBackground = false;
    var NoBackButton = false;
    var ListCacher = null as BG.ListCacher?;
    private var onSettingsChangedListeners as Array<WeakReference> = [];
    (:withBackground)
    private var _backgroundReceive as Array<Array<Object> > = [];
    (:withBackground)
    private var _backgroundReceiveTimer = null as Timer?;

    function initialize() {
        AppBase.initialize();
        if (Background has :getPhoneAppMessageEventRegistered && !Background.getPhoneAppMessageEventRegistered() && $.hasBackgroundCapability) {
            Background.registerForPhoneAppMessageEvent();
        }
        self.MemoryCheck = new Helper.MemoryChecker(self);
    }

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        var appVersion = "2025.03.1300";
        Application.Properties.setValue("appVersion", appVersion);

        self.Debug = new Debug.DebugStorage();

        var settings = System.getDeviceSettings();
        if ((settings.inputButtons & System.BUTTON_INPUT_ESC) == 0) {
            self.NoBackButton = true;
        }

        self.ListsManager = new ListsManager(self);
        self.Phone = new Comm.PhoneCommunication(self, true);
        self.Inactivity = new Helper.Inactivity();
        self.processBackground();

        var startview = new Views.ListsSelectView(true);

        //just clean up the storage, if there are any relics
        if (self.ListCacher == null) {
            if (self.ListsManager.GetListsIndex().size() == 0) {
                Debug.Log("Cleanup storage, due to no listindex found");
                Application.Storage.clearValues();
            }
        }

        return [startview, new Views.ItemViewDelegate(startview)];
    }

    (:glance,:withGlance)
    function getGlanceView() as [WatchUi.GlanceView] or [WatchUi.GlanceView, WatchUi.GlanceViewDelegate] or Null {
        self.isGlanceView = true;
        return [new Views.GlanceView()];
    }

    (:withBackground,:background)
    function getServiceDelegate() as [System.ServiceDelegate] {
        self.isBackground = true;
        self.ListsManager = new ListsManager(self);
        self.Phone = new Comm.PhoneCommunication(self, false);
        self.BackgroundService = new BG.Service();
        return [self.BackgroundService];
    }

    function onSettingsChanged() as Void {
        self.triggerOnSettingsChanged();
    }

    (:withBackground)
    function onBackgroundData(data as Application.PersistableType) as Void {
        var maxMessages = 5;
        if (data instanceof Array) {
            Debug.Log("Received message from background");
            self._backgroundReceive.add(data);
            if (self._backgroundReceive.size() > maxMessages) {
                Debug.Log("Received too many messages from background, only keep the " + maxMessages + " newest");
                self._backgroundReceive = self._backgroundReceive.slice(-maxMessages, null);
            }
        } else {
            Debug.Log("Received invalid message from background");
        }
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
        ret.add("LowBGMemory: " + !$.hasBackgroundCapability);
        ret.add("Language: " + settings.systemLanguage);
        ret.add("Lists in Storage: " + self.ListsManager.GetListsIndex().size());
        return ret;
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

    (:withBackground)
    private function processBackground() as Void {
        if (self._backgroundReceive.size() > 0) {
            self._backgroundReceiveTimer = new Timer.Timer();
            self._backgroundReceiveTimer.start(method(:handleBackgroundData), 100, true);
        }
        self.ListCacher = new BG.ListCacher(self);
        self.ListCacher.ProcessCache();
    }

    (:withoutBackground)
    private function processBackground() as Void {}

    (:withBackground)
    function handleBackgroundData() as Void {
        if (self._backgroundReceive.size() > 0) {
            var data = self._backgroundReceive[0];
            self._backgroundReceive = self._backgroundReceive.slice(0, 1);
            try {
                self.Phone.processData(data);
            } catch (ex instanceof Lang.Exception) {}
        } else if (self._backgroundReceiveTimer != null) {
            self._backgroundReceiveTimer.stop();
            self._backgroundReceiveTimer = null;
        }
    }
}

(:glance,:background)
function getApp() as ListsApp {
    return Application.getApp() as ListsApp;
}

function openGooglePlay() as Void {
    Communications.openWebPage("https://play.google.com/store/apps/details?id=de.romandrechsel.lists", null, null);
}

(:withBackground)
var hasBackgroundCapability = true;
(:withoutBackground)
var hasBackgroundCapability = false;

(:roundVersion)
var isRoundDisplay = true;
(:regularVersion)
var isRoundDisplay = false;

var screenHeight = System.getDeviceSettings().screenHeight;
