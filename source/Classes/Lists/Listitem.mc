import Toybox.Lang;

module Lists {
    typedef ListitemModel as Dictionary<Number, String or Boolean or Number or Null>;

    (:background)
    class Listitem {
        private enum EKey {
            UUID = 0,
            TEXT = 1,
            NOTE = 2,
            DONE = 3,
            ORDER = 4,
        }

        public var Uuid as String or Number or Null;
        public var Text as String?;
        public var Note as String?;
        public var Done as Boolean;
        public var Order as Number?;

        function initialize(data as ListitemModel?) {
            if (data != null) {
                self.Uuid = data.get(UUID) as String or Number or Null;
                self.Text = data.get(TEXT) as String?;
                self.Note = data.get(NOTE) as String?;
                self.Order = data.get(ORDER) as Number?;
                self.Done = data.get(DONE) as Boolean?;
            } else {
                self.Done = false;
            }
        }

        public function isValid() as Boolean {
            return self.Text != null && self.Order != null && self.Order >= 0;
        }

        public function toBackend() as ListitemModel? {
            if (self.isValid()) {
                var model = ({ UUID => self.Uuid, TEXT => self.Text, ORDER => self.Order }) as ListitemModel;
                if (self.Note != null) {
                    model.put(NOTE, self.Note);
                }
                if (self.Done == true) {
                    model.put(DONE, true);
                }
                return model;
            }
            return null;
        }
    }
}
