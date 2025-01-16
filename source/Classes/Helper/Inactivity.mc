import Toybox.Timer;
import Toybox.Lang;
import Toybox.Time;

module Helper {
    class Inactivity {
        private var _timer = new Timer.Timer();
        private var _autoexit as Number = 0;
        private var _lastInteraction as Time.Moment?;

        function initialize() {
            self.onSettingsChanged();
            $.getApp().onSettingsChangedListeners.add(self);
        }

        function Interaction() as Void {
            self._lastInteraction = Time.now();
        }

        function onSettingsChanged() as Void {
            self._lastInteraction = Time.now();
            self._autoexit = Helper.Properties.Get(Helper.Properties.AUTOEXIT, 0);
            if (self._autoexit > 0) {
                self._timer = new Timer.Timer();
                self._timer.start(method(:onTimer), 10000, true);
            } else if (self._timer != null) {
                self._timer.stop();
                self._timer = null;
            }
        }

        function onTimer() as Void {
            if (self._autoexit > 0) {
                var minutes = (Time.now().value() - self._lastInteraction.value()).toFloat() / 60.0;
                if (minutes > self._autoexit) {
                    Debug.Log("Close app due to " + self._autoexit + " min. of inactivity (last interaction: " + Helper.DateUtil.toLogString(self._lastInteraction, null) + ")");
                    System.exit();
                }
            }
        }
    }
}
