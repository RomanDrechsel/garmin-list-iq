using Toybox.WatchUi;
using Toybox.Lang;

module Controls {
    class ConfirmDelegate extends WatchUi.ConfirmationDelegate {
        private var _onYes;

        function initialize(onYes as (Method() as Void)) {
            ConfirmationDelegate.initialize();
            self._onYes = onYes;
        }

        function onResponse(response) as Void {
            if (response == WatchUi.CONFIRM_YES && self._onYes != null) {
                self._onYes.invoke();
            }
        }
    }
}
