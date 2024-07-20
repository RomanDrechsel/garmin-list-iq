import Toybox.Lang;
import Toybox.Graphics;
import Controls;

module Views {
    class StatusView extends Controls.CustomView {
        protected var TAG = "StatusView";
        private var _callbacks as Dictionary<Object, Method> = {};

        function initialize(message as String, icon as String or Controls.Listitems.ViewItemIcon or Null, additional_items as Array<Listitems.Item> or Listitems.Item or Null, callbacks as Dictionary<Object, Method>?) {
            CustomView.initialize();
            var item_text = new Listitems.Item(null, message, null, null, null, self._verticalItemMargin, -1, null);
            item_text.DrawLine = false;
            item_text.TitleJustification = Graphics.TEXT_JUSTIFY_CENTER;
            self.Items.add(item_text);

            if (additional_items != null) {
                if (!(additional_items instanceof Array)) {
                    additional_items = [additional_items];
                }
                self.Items.addAll(additional_items);
            }
            self._callbacks = callbacks;
            Debug.Log("Callbacks: " + self._callbacks.size());
        }

        function onUpdate(dc as Dc) as Void {
            CustomView.onUpdate(dc);

            dc.setColor(getTheme().BackgroundColor, getTheme().BackgroundColor);
            dc.clear();

            if (self.Items.size() > 0) {
                self.drawList(dc);
            }
        }

        function onListTap(position as Number, item as Listitems.Item, doubletap as Boolean) as Void {
            Debug.Log(self._callbacks);
            if (item.BoundObject != null) {
                var callback = self._callbacks.get(item.BoundObject);
                Debug.Log(callback);
                if (callback) {
                    callback.invoke();
                }
            }
        }
    }
}
