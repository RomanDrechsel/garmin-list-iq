import Toybox.System;

module Helper {
    (:background,:glance)
    class MemoryChecker {
        private var _app as ListsApp;

        function initialize(app as ListsApp) {
            self._app = app;
        }
        function Check() as Void {
            var stats = System.getSystemStats();
            var usage = stats.usedMemory.toDouble() / stats.totalMemory.toDouble();
            var maxusage = self._app.isBackground ? 0.9d : 0.8d;
            if (usage > maxusage) {
                if (self._app.BackgroundService != null) {
                    self._app.BackgroundService.Finish(false);
                } else {
                    Views.ErrorView.Show(Views.ErrorView.OUT_OF_MEMORY, null);
                    throw new Exceptions.OutOfMemoryException(usage, stats.usedMemory, stats.totalMemory);
                }
            }
        }
    }
}
