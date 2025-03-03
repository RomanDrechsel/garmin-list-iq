import Toybox.Lang;

module Lists {
    (:background)
    class AddListBatch {
        public var List as List;
        public var IsSync = false;
        private var _data as Array<String>;
        private var _linesPerTick = 50;

        function initialize(data as Array<String>) {
            if (data[0] == "issync") {
                self.IsSync = true;
                data = data.slice(1, null);
            }
            self._data = data;
            self.List = new List(null);
        }

        public function ProcessBatch(memoryChecker as Helper.MemoryChecker?) as Array<Boolean?> {
            if (self._data.size() > 0) {
                var lines = self._data.size() > self._linesPerTick ? self._linesPerTick : self._data.size();
                self.List.ProcessBatch(self._data.slice(0, lines), memoryChecker);
                if (self._data.size() > lines) {
                    self._data = self._data.slice(lines, null);
                    return [false, null];
                } else {
                    return [true, self.List.FinishBatch()];
                }
            }
            return [true, null];
        }
    }
}
