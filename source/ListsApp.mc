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
    var Inactivity as Common.Inactivity? = null;
    var BackgroundService as BG.Service? = null;
    var GlobalStates as Array<EState> = [];
    var AppType as EApptype = APP;
    var Initialized as Boolean = false;
    var ProcessingBackgroundData as Boolean? = null;
    private var _onSettingsChangedListeners as Array<WeakReference> = [];

    function initialize() {
        AppBase.initialize();
        if (Background has :getPhoneAppMessageEventRegistered && !Background.getPhoneAppMessageEventRegistered() && $.hasBackgroundCapability) {
            Background.registerForPhoneAppMessageEvent();
        }
    }

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        self.AppType = APP;
        var appVersion = "2025.11.2800";
        Application.Properties.setValue("appVersion", appVersion);

        self.Debug = new Debug.DebugStorage();
        self.ListsManager = new Lists.ListsManager();
        self.Phone = new Comm.PhoneCommunication(self);

        if (Helper.Properties.Get(Helper.Properties.AUTOEXIT, 0) > 0) {
            self.Inactivity = new Common.Inactivity();
        }

        //check if there where any lists sent to the watch in background...
        self.processBackgroundData();

        //show error view, if a legacy list was send (in no longer supported format)
        var show_error_view_on_startup = null;
        if (Application.Storage.getValue(Lists.RECEIVED_LEGACY_LIST) != null) {
            Application.Storage.deleteValue(Lists.RECEIVED_LEGACY_LIST);
            show_error_view_on_startup = Views.ErrorView.LEGACY_APP;
        }

        //just clean up the storage, if there are any relics
        if (self.ProcessingBackgroundData != true) {
            if (self.ListsManager.GetListsIndex().size() == 0) {
                Debug.Log("Cleanup storage, due to no listindex found");
                Application.Storage.clearValues();
            }
        }

        self.Initialized = true;
        var startview = new Views.ListsSelectView(true, show_error_view_on_startup);
        return [startview, new Views.ListsSelectViewDelegate(startview)];
    }

    (:glance,:withGlance)
    function getGlanceView() as [WatchUi.GlanceView] or [WatchUi.GlanceView, WatchUi.GlanceViewDelegate] or Null {
        self.AppType = GLANCE;
        return [new Views.GlanceView()];
    }

    (:withBackground,:background)
    function getServiceDelegate() as [System.ServiceDelegate] {
        self.AppType = BACKGROUND;
        self.BackgroundService = new BG.Service();

        return [self.BackgroundService];
    }

    function onSettingsChanged() as Void {
        Debug.Log("Settings changed out of app");
        self.triggerOnSettingsChanged();

        var autoexit = Helper.Properties.Get(Helper.Properties.AUTOEXIT, 0);
        if (self.Inactivity == null && autoexit > 0) {
            self.Inactivity = new Common.Inactivity();
        } else if (self.Inactivity != null && autoexit <= 0) {
            self.Inactivity.Stop();
            self.Inactivity = null;
        }
    }

    /**
        this method handles data from background, that were forwarded to foreground via Background.exit(data);
    */
    (:withBackground)
    function onBackgroundData(data as Application.PersistableType) as Void {
        if (data instanceof Array) {
            Debug.Log("Received message from phone in background");
            var cacher = new BG.ListCacher();
            cacher.TrimCache(5);
            cacher.Cache(data);
        } else {
            Debug.Log("Received invalid message from phone in background");
        }
    }

    function triggerOnSettingsChanged() as Void {
        if (self.Debug != null) {
            self.Debug.onSettingsChanged();
        }
        Themes.ThemesLoader.loadTheme();
        for (var i = 0; i < self._onSettingsChangedListeners.size(); i++) {
            var weak = self._onSettingsChangedListeners[i];
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
                screenShape = "Rect";
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
        for (var i = 0; i < self._onSettingsChangedListeners.size(); i++) {
            var weak = self._onSettingsChangedListeners[i];
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
                self._onSettingsChangedListeners.remove(del[i]);
            }
        }

        if (obj has :onSettingsChanged) {
            var ref = obj.weak();

            if (self._onSettingsChangedListeners.indexOf(ref) < 0) {
                self._onSettingsChangedListeners.add(ref);
            }
        }
    }

    function removeSettingsChangedListener(obj as Object) as Void {
        var ref = obj.weak();
        if (self._onSettingsChangedListeners.indexOf(ref) >= 0) {
            self._onSettingsChangedListeners.removeAll(ref);
        }
    }

    (:withBackground)
    private function processBackgroundData() as Void {
        var processor = new BG.ListCacheProcessor();
        processor.ProcessCache();
    }

    (:withoutBackground)
    private function processBackgroundData() as Void {}
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
