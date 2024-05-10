import Toybox.Lang;

enum ELogType {
    DEBUG = "D",
    NOTICE = "N",
    IMPORTANT = "I",
    ERROR = "E",
}

(:debug)
function Log(str as String) {
    LogT(str, DEBUG);
}

(:debug)
function LogT(str as String, type as ELogType) {
    Toybox.System.println("[" + type + "] " + str);
}

(:release)
function Log(str as String) {}

(:release)
function LogT(str as String, type as ELogType) {}
