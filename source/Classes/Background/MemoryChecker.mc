import Toybox.System;

module BG {
    (:background)
    class MemoryChecker {
        function Check() {
            var maxUsage = 0.95;
            if ($.getApp().isBackground) {
                maxUsage = 0.9;
            }
            var stats = System.getSystemStats();
            var usage = stats.usedMemory.toDouble() / stats.totalMemory.toDouble();
            if (usage > maxUsage) {
                throw new OutOfMemoryException(usage);
            }
        }
    }
}
