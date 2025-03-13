import Toybox.Application;
import Toybox.Lang;

(:withGlance)
module Lists {
    (:glance)
    class GlanceListsManager {
        typedef ListIndexItem as Dictionary<Number, String or Number>;
        typedef ListIndex as Dictionary<String or Number, ListIndexItem>;

        public function GetInfo() as String {
            var indexdata = Application.Storage.getValue("listindex") as ListIndex?;
            if (indexdata == null || !(indexdata instanceof Dictionary) || indexdata.size() == 0) {
                return Application.loadResource(Rez.Strings.GlNoLists);
            }
            var count = indexdata.size();

            var prop = Helper.Properties.Get(Helper.Properties.LASTLIST, null);
            if (prop != null) {
                var list = indexdata.get(prop) as ListIndexItem?;
                if (list != null && list instanceof Dictionary) {
                    var listname = list.get(Lists.List.TITLE);
                    if (listname != null) {
                        return listname;
                    }
                }
            }

            if (count == 1) {
                return Application.loadResource(Rez.Strings.GlOneList);
            } else {
                return Helper.StringUtil.stringReplace(Application.loadResource(Rez.Strings.GlNumLists), "%d", count.toString());
            }
        }
    }
}
