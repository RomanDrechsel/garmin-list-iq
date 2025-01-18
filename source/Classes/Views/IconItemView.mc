import Controls.Listitems;
import Toybox.Graphics;

module Views {
    class IconItemView extends ItemView {
        protected var _itemIcon as Listitems.ViewItemIcon;
        protected var _itemIconDone as Listitems.ViewItemIcon;
        protected var _itemIconInvert as Listitems.ViewItemIcon? = null;
        protected var _itemIconDoneInvert as Listitems.ViewItemIcon? = null;

        function onLayout(dc as Dc) as Void {
            ItemView.onLayout(dc);
            self.loadIcons();
        }

        function onSettingsChanged() as Void {
            ItemView.onSettingsChanged();
            self.loadIcons();
        }

        protected function loadIcons() as Void {
            var theme = $.getTheme();
            self._itemIcon = theme.getItemIcon(false);
            self._itemIconDone = theme.getItemIcon(true);

            if (!$.TouchControls) {
                self._itemIconInvert = theme.getItemIconInvert(false);
                self._itemIconDoneInvert = theme.getItemIconInvert(true);
            } else {
                self._itemIconInvert = null;
                self._itemIconDoneInvert = null;
            }
        }

        protected function validate(dc as Dc) as Void {
            var validate = self._needValidation;
            ItemView.validate(dc);
            if (validate) {
                for (var i = 0; i < self.Items.size(); i++) {
                    var icon = self.Items[i].getIcon();
                    if (icon != null) {
                        self.Items[i].setIconInvert(icon == self._itemIcon ? self._itemIconInvert : self._itemIconDoneInvert);
                    }
                }
            }
        }
    }
}
