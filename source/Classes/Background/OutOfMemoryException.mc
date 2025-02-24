import Toybox.Lang;

module BG {
    (:background)
    class OutOfMemoryException extends Lang.Exception {
        public var Usage as Double;

        function initialize(usage as Double) {
            Exception.initialize();
            self.Usage = usage;
        }
    }
}
