import Toybox.System;

module Common {
    (:background,:glance)
    class MemoryChecker {
        static function Check() as Void {
            var app = $.getApp();
            var stats = System.getSystemStats();
            var usage = stats.usedMemory.toDouble() / stats.totalMemory.toDouble();
            if (usage > 0.9d) {
                if (app.AppType == ListsApp.APP) {
                    Views.ErrorView.Show(Views.ErrorView.OUT_OF_MEMORY, null);
                    throw new Exceptions.OutOfMemoryException(usage, stats.usedMemory, stats.totalMemory);
                } else if (app.AppType == ListsApp.BACKGROUND && app.BackgroundService != null) {
                    app.BackgroundService.Finish(false);
                }
            }
        }
    }
}
