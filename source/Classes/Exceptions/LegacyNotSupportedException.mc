import Toybox.Lang;

module Exceptions {
    class LegacyNotSupportedException extends Lang.Exception {
        function initialize() {
            Exception.initialize();
        }
    }
}
