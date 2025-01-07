import Toybox.Application;
import Toybox.Lang;

(:glance)
module Lists {
    class GlanceListsManager {
        public function GetInfo() as String {
            var index = Application.Storage.getValue("listindex") as ListIndex?;
            if (index == null || index.size() == 0) {
                return Application.loadResource(Rez.Strings.GlNoLists);
            }

            var prop = Helper.Properties.Get(Helper.Properties.LASTLIST, "");
            if (prop.length() > 0 && index.hasKey(prop)) {
                var list = index.get(prop);
                if (list != null) {
                    var title = list.get("name");
                    if (title != null) {
                        return title;
                    }
                }
            }

            if (index.size() == 1) {
                return Application.loadResource(Rez.Strings.GlOneList);
            } else {
                return Helper.StringUtil.stringReplace(Application.loadResource(Rez.Strings.GlNumLists), "%d", index.size().toString());
            }
        }
    }
}
