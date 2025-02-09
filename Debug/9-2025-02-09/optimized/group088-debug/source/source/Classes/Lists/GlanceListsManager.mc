using Helper;
using Toybox.Application.Storage;
import Toybox.Application;
import Toybox.Lang;

(:glance)
module Lists {
    class GlanceListsManager {
        public function GetInfo() as String {
            var prop,
                index = Storage /*>Application.Storage<*/.getValue("listindex") as ListIndex?;
            if (index == null || index.size() == 0) {
                return Application.loadResource(Rez.Strings.GlNoLists);
            }

            prop = Helper.Properties.Get("LastList", "");
            if (prop.length() > 0 && index.hasKey(prop)) {
                prop /*>list<*/ = index.get(prop);
                if (prop /*>list<*/ != null) {
                    prop /*>title<*/ = prop /*>list<*/.get("name");
                    if (prop /*>title<*/ != null) {
                        return prop /*>title<*/;
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
