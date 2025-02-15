using Toybox.WatchUi;
using Toybox.Lang;

module Controls {
    class ConfirmDelegate extends WatchUi.ConfirmationDelegate {
        private var _onYes;

        function initialize(onYes as (Method() as Void)) {
            ConfirmationDelegate.initialize();
            self._onYes = onYes;
        }

        function onResponse(response as Lang.Number) as Lang.Boolean {
            var pre__onYes;
            pre__onYes = self._onYes;
            if (response == 1 && pre__onYes != null) {
                pre__onYes.invoke();
            }
            return true;
        }
    }
}
