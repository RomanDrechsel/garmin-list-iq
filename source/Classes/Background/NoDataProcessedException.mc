import Toybox.Lang;

module BG {
    (:background)
    class NoDataProcessedException extends Lang.Exception {
        function initialize() {
            Exception.initialize();
        }
    }
}
