import Toybox.Lang;

module Helper {
    (:background)
    class OutOfMemoryException extends Lang.Exception {
        public var Usage as Double;
        public var Used as Number;
        public var Total as Number;

        function initialize(usage as Double, used as Number, total as Number) {
            Exception.initialize();
            self.Usage = usage;
            self.Used = used;
            self.Total = total;
        }
    }
}
