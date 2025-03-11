import Toybox.Lang;

module Exceptions {
    (:background,:glance)
    class LegacyNotSupportedException extends Lang.Exception {
        function initialize() {
            Exception.initialize();
        }
    }
}
