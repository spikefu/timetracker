package event {
import flash.events.Event;
import mx.formatters.DateFormatter;
import mx.utils.StringUtil;

public class WorkLogEvent extends Event {
    public static const CAPTURE_WORK_LOG:String = "captureWorkLog";
    public static const SAVE_WORK_LOG:String = "saveWorkLog";

    public var billTo:String;
    public var log:String;
    public var startTime:Date;
    public var endTime:Date;

    public function WorkLogEvent(type:String,  startTime:Date, endTime:Date, log:String, billTo:String) {
        super(type);
        this.startTime = startTime;
        this.endTime = endTime;
        this.log = log;
        this.billTo = billTo;
    }

    public function serialize():String {

        return keyFormat(startTime) + "\t" + keyFormat(endTime) + "\t" + encodeURI(log) + "\t" + encodeURI(billTo);
    }

    private function keyFormat(date:Date):String {
        var formatter:DateFormatter = new DateFormatter();
        formatter.formatString = "YYYYMMDDHHNN";
        var key:String = formatter.format(date);
        return key;
    }

    public function getKey():String {

        return keyFormat(this.startTime) + "_" + keyFormat(this.endTime);
    }

    override public function clone():Event {
        return new WorkLogEvent(this.type, startTime, endTime, log, billTo);
    }

    override public function toString():String {
        var formatter:DateFormatter = new DateFormatter();
        formatter.formatString = "JJ:NN";

        var response:String = formatter.format(startTime) + " - " + formatter.format(endTime) + ": " + log.replace("\r",";");
        if (StringUtil.trim(billTo).length > 0) {
            response += " [" + billTo + "]";
        }
        return response;
    }
}
}
