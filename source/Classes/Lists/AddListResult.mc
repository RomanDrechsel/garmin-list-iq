import Toybox.Lang;

module Lists {
    (:background)
    class AddListResult {
        public var Success as Boolean = false;
        public var Missing as Array<String> = [];
        public var IsSyncList as Boolean? = null;
    }
}
