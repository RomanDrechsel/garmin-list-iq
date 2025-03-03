import Toybox.System;

module Helper {
    (:background)
    class MemoryChecker {
        private var _app as ListsApp;
        public var ShowErrorView = true;

        function initialize(app as ListsApp) {
            self._app = app;
        }
        function Check() as Void {
            var stats = System.getSystemStats();
            var usage = stats.usedMemory.toDouble() / stats.totalMemory.toDouble();
            var maxusage = self._app.isBackground ? 0.9d : 0.80d;
            if (usage > maxusage) {
                if (self._app.BackgroundService != null) {
                    self._app.BackgroundService.Finish(false);
                } else {
                    if (self.ShowErrorView) {
                        self.ShowErrorView = false;
                        var errorView = new Views.ErrorView(Rez.Strings.ListRecOOM, null, null);
                        WatchUi.pushView(errorView, new Views.ItemViewDelegate(errorView), WatchUi.SLIDE_BLINK);
                    }
                    throw new OutOfMemoryException(usage, stats.usedMemory, stats.totalMemory);
                }
            }
        }
    }
}
