package util {
import event.WorkLogEvent;

import model.TimeTrackerOptions;

public class DateFactory {

    public function getCurrentDateTime():Date {
        return new Date();
    }

    public function startOfToday():Date {
        return startofDay(getCurrentDateTime());
    }

    public function startofDay(date:Date):Date {
        var start:Date = new Date(date.getFullYear(),date.getMonth(),date.getDate(),0,0,0,0);
        return start;
    }

    public function getPrevStartTime(evt:WorkLogEvent,options:TimeTrackerOptions):Date {
        var d:Date = new Date(evt.startTime.getTime() - options.autoRecordInterval);
        return d;
    }

    public function getPrevEndTime(evt:WorkLogEvent,options:TimeTrackerOptions):Date {
        var d:Date = new Date(evt.endTime.getTime() - options.autoRecordInterval);
        return d;
    }

    public function getNextStartTime(evt:WorkLogEvent,options:TimeTrackerOptions):Date {
        var d:Date = new Date(evt.startTime.getTime() + options.autoRecordInterval);
        return d;
    }

    public function getNextEndTime(evt:WorkLogEvent,options:TimeTrackerOptions):Date {
        var d:Date = new Date(evt.endTime.getTime() + options.autoRecordInterval);
        return d;
    }
}
}
