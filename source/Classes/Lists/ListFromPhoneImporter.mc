import Toybox.Lang;

module Lists {
    class ListFromPhoneImporter {
        public function Import(data as Array?) as List? {
            var list = new List(null);
            while (data.size() > 0) {
                var rowsplit = Helper.StringUtil.split(data[0].toString(), "=", 2);
                data = data.slice(1, null);
                if (rowsplit.size() <= 1 || rowsplit[0].length == 0) {
                    Debug.Log("No key value pair in list data " + rowsplit);
                    continue;
                }
                var key = rowsplit[0];
                var val = rowsplit[1];
                rowsplit = null;
                if (key.equals("uuid")) {
                    list.Uuid = val.toString();
                    var num = Helper.StringUtil.StringToNumber(list.Uuid);
                    if (num != null) {
                        list.Uuid = num;
                    }
                } else if (key.equals("t")) {
                    list.Title = val.toString();
                } else if (key.equals("o")) {
                    list.Order = val.toNumber();
                } else if (key.equals("d")) {
                    var date = val.toLong();
                    if (date != null) {
                        if (date > 999999999) {
                            // date is in milliseconds
                            date /= 1000;
                        }
                        list.Date = date.toNumber();
                    }
                } else if (key.substring(0, 2).equals("it")) {
                    var split = Helper.StringUtil.split(key.substring(2, key.length()), "_", 2);
                    key = null;
                    var index = split[0].toNumber();
                    var prop = split.size() > 1 ? split[1] : null;
                    split = null;
                    if (prop != null && index != null) {
                        var item = list.GetItem(index);
                        if (item == null) {
                            item = new Listitem(null);
                            item.Order = index;
                            list.Items.add(item);
                        }
                        if (prop.equals("i")) {
                            item.Text = val.toString();
                        } else if (prop.equals("n")) {
                            item.Note = val.toString();
                        } else if (prop.equals("uuid")) {
                            var num = Helper.StringUtil.StringToNumber(val);
                            item.Uuid = num != null ? num : val;
                        }
                    }
                } else if (key.substring(0, 2).equals("r_")) {
                    if (key.equals("r_a")) {
                        val = Helper.StringUtil.StringToBool(val);
                        if (val != null) {
                            list.Reset = val;
                        }
                    } else if (key.equals("r_i")) {
                        list.ResetInterval = val.toString(); //no reference
                    } else if (key.equals("r_h")) {
                        val = val.toNumber();
                        if (val != null) {
                            list.ResetHour = val;
                        }
                    } else if (key.equals("r_m")) {
                        val = val.toNumber();
                        if (val != null) {
                            list.ResetMinute = val;
                        }
                    } else if (key.equals("r_w")) {
                        val = val.toNumber();
                        if (val != null) {
                            list.ResetWeekday = val;
                        }
                    } else if (key.equals("r_d")) {
                        val = val.toNumber();
                        if (val != null) {
                            list.ResetDay = val;
                        }
                    }
                } else if (key.equals("r_l")) {
                    var num = val.toNumber();
                    if (num != null) {
                        list.ResetLast = num;
                    }
                } else if (key.equals("rev")) {
                    list.Revision = val.toNumber();
                    if (list.Revision != list.CurrentRevision) {
                        Debug.Log("Old list revision number: " + list.Revision + " <> " + list.CurrentRevision);
                        throw new Exceptions.LegacyNotSupportedException();
                    }
                }
                key = null;
                val = null;
                Common.MemoryChecker.Check();
            }

            //check if list is valid
            if (list.Revision == null) {
                Debug.Log("No revision number in list received from phone");
                throw new Exceptions.LegacyNotSupportedException();
            } else if (list.Revision != list.CurrentRevision) {
                Debug.Log("Old list revision number: " + list.Revision + " <> " + list.CurrentRevision);
                throw new Exceptions.LegacyNotSupportedException();
            }

            if (list.IsValid()) {
                if (list.Reset != null) {
                    var missing = [];
                    if (list.ResetInterval != null && list.ResetHour != null && list.ResetMinute != null) {
                        if (list.ResetInterval == "w" && list.ResetWeekday == null) {
                            missing.add("weekday");
                        } else if (list.ResetInterval == "m" && list.ResetDay == null) {
                            missing.add("day");
                        }
                    } else {
                        if (list.ResetInterval == null) {
                            missing.add("interval");
                        }
                        if (list.ResetHour == null) {
                            missing.add("hour");
                        }
                        if (list.ResetMinute == null) {
                            missing.add("minute");
                        }
                    }
                    if (missing.size() > 0) {
                        Debug.Log("Could not load list: missing properties - " + missing);
                    }
                }
                if (list.Date == null) {
                    list.Date = Time.now().value();
                }
                if (list.Reset != null && list.ResetLast == null) {
                    list.ResetLast = Time.now().value();
                }
                list.Items = list.sortItems(list.Items);
                return list;
            } else {
                var missing = [];
                if (list.Title == null) {
                    missing.add("title");
                }
                if (list.Order == null) {
                    missing.add("order");
                }
                if (list.Uuid == null) {
                    missing.add("uuid");
                }
                if (missing.size() > 0) {
                    Debug.Log("Could not load list: missing properties - " + missing);
                } else {
                    Debug.Log("Could not load list: missing properties");
                }
                return null;
            }
        }
    }
}
