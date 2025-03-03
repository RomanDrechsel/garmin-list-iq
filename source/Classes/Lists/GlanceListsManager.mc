import Toybox.Application;
import Toybox.Lang;

module Lists {
    (:glance)
    class GlanceListsManager {
        public function GetInfo() as String {
            var indexdata = Application.Storage.getValue("listindex");
            if (indexdata == null || !(indexdata instanceof Array) || indexdata.size() == 0) {
                return Application.loadResource(Rez.Strings.GlNoLists);
            }

            var count = indexdata.size();

            var prop = Helper.Properties.Get(Helper.Properties.LASTLIST, "");
            if (prop.length() > 0) {
                while (indexdata.size() > 0) {
                    var index = indexdata[0] as Array<String>;
                    indexdata = indexdata.slice(1, null);
                    var listname = null;
                    var correct_list = false;
                    while (index.size() > 0) {
                        if (index[0].substring(0, 5).equals("uuid=")) {
                            var uuid = index[0].substring(5, index[0].length());
                            if (prop.equals(uuid)) {
                                correct_list = true;
                                if (listname != null) {
                                    return listname as String;
                                }
                            } else if (index[0].substring(0, 2).equals("n=")) {
                                listname = index[0].substring(2, index[0].length());
                                if (correct_list) {
                                    return listname;
                                }
                            }
                        }
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
