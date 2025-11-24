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

    enum EApptype {
        APP = 1,
        BACKGROUND = 2,
        GLANCE = 3,
    }

    var Phone as PhoneCommunication? = null;
    var ListsManager as ListsManager? = null;
    var Debug as DebugStorage? = null;
    var Inactivity as Helper.Inactivity? = null;
    var BackgroundService as BG.Service? = null;
    var MemoryCheck as Helper.MemoryChecker;
    var GlobalStates as Array<EState> = [];
    var AppType as EApptype = APP;
    var NoBackButton = false;
    var ListCacher as BG.ListCacher? = null;
    var Initialized as Boolean = false;
    private var onSettingsChangedListeners as Array<WeakReference> = [];
    (:withBackground)
    private var _backgroundReceive as Array<Array<Object> > = [];
    (:withBackground)
    private var _backgroundReceiveTimer = null as Timer.Timer?;

    function initialize() {
        AppBase.initialize();
        if (Background has :getPhoneAppMessageEventRegistered && !Background.getPhoneAppMessageEventRegistered() && $.hasBackgroundCapability) {
            Background.registerForPhoneAppMessageEvent();
        }
        self.MemoryCheck = new Helper.MemoryChecker(self);
    }

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        self.AppType = APP;
        var appVersion = "2025.11.2200";
        Application.Properties.setValue("appVersion", appVersion);

        self.Debug = new Debug.DebugStorage();

        var settings = System.getDeviceSettings();
        if ((settings.inputButtons & System.BUTTON_INPUT_ESC) == 0) {
            self.NoBackButton = true;
        }

        if (self.ListsManager == null) {
            self.ListsManager = new Lists.ListsManager(self);
        }

        self.Phone = new Comm.PhoneCommunication(self, true);

        if (Helper.Properties.Get(Helper.Properties.AUTOEXIT, 0) > 0) {
            self.Inactivity = new Helper.Inactivity();
        }
        self.processBackground();

        var show_error_view_on_startup = null;
        if (Application.Storage.getValue(Lists.RECEIVED_LEGACY_LIST) != null) {
            Application.Storage.deleteValue(Lists.RECEIVED_LEGACY_LIST);
            show_error_view_on_startup = Views.ErrorView.LEGACY_APP;
        }

        var startview = new Views.ListsSelectView(true, show_error_view_on_startup);

        //just clean up the storage, if there are any relics
        if (self.ListCacher == null) {
            if (self.ListsManager.GetListsIndex().size() == 0) {
                Debug.Log("Cleanup storage, due to no listindex found");
                Application.Storage.clearValues();
            }
        }

        self.Initialized = true;
        return [startview, new Views.ItemViewDelegate(startview)];
    }

    (:glance,:withGlance)
    function getGlanceView() as [WatchUi.GlanceView] or [WatchUi.GlanceView, WatchUi.GlanceViewDelegate] or Null {
        self.AppType = GLANCE;
        return [new Views.GlanceView()];
    }

    (:withBackground,:background)
    function getServiceDelegate() as [System.ServiceDelegate] {
        self.AppType = BACKGROUND;
        if (self.ListsManager == null) {
            self.ListsManager = new Lists.ListsManager(self);
        }
        self.Phone = new Comm.PhoneCommunication(self, false);
        self.BackgroundService = new BG.Service();
        return [self.BackgroundService];
    }

    function onSettingsChanged() as Void {
        Debug.Log("Settings changed out of app");
        self.triggerOnSettingsChanged();

        var autoexit = Helper.Properties.Get(Helper.Properties.AUTOEXIT, 0);
        if (self.Inactivity == null && autoexit > 0) {
            self.Inactivity = new Helper.Inactivity();
        } else if (self.Inactivity != null && autoexit <= 0) {
            self.Inactivity.Stop();
            self.Inactivity = null;
        }
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
        }

        var ret = [] as Array<String>;
        ret.add("Version: " + Application.Properties.getValue("appVersion"));
        ret.add("Display: " + screenShape);
        ret.add("Touchscreen: " + settings.isTouchScreen);
        ret.add("Controls: " + Views.ItemView.SupportedControls());
        ret.add("High Color Display: " + $.hasHighColorDisplay);
        ret.add("Firmware: " + settings.firmwareVersion);
        ret.add("Monkey Version: " + settings.monkeyVersion);
        ret.add("Memory: " + stats.usedMemory + " / " + stats.totalMemory);
        ret.add("BG Capability: " + $.hasBackgroundCapability);
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

    function removeSettingsChangedListener(obj as Object) as Void {
        var ref = obj.weak();
        if (self.onSettingsChangedListeners.indexOf(ref) >= 0) {
            self.onSettingsChangedListeners.removeAll(ref);
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
(:withHighColor)
var hasHighColorDisplay = true;
(:withoutHighColor)
var hasHighColorDisplay = false;

(:roundVersion)
var isRoundDisplay = true;
(:regularVersion)
var isRoundDisplay = false;

var screenHeight = System.getDeviceSettings().screenHeight;
