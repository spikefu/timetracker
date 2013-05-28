package model {
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import WorkLog;

import WorkLog;

import WorkLog;
import WorkLog;
import util.DateFactory;

public class TimeTrackerOptions {

    private var dateFactory:DateFactory;
    public function TimeTrackerOptions(dateFactory:DateFactory) {
        this.dateFactory = dateFactory;
        loadOptions();
    }

    /** Milliseconds after midnight */
    public var startMillis:Number = 8*60*60*1000;

    /** Milliseconds after midnight */
    public var endMillis:Number = 17*60*60*1000;

    /** Interval between notification pop-ups in milliseconds */
    public var autoRecordInterval:Number = 30*60*1000;



    public function startTime():Date  {
        var start:Date = dateFactory.startOfToday();
        start.setTime(start.getTime() + startMillis);
        return start;
    }

    public function endTime():Date {
        var end:Date = dateFactory.startOfToday();
        end.setTime(end.getTime() + endMillis);
        return end;
    }

    private function loadOptions():void {
        if (WorkLog.logFolder.exists) {
            var stream:FileStream = new FileStream();
            var optionFile:File = WorkLog.logFolder.resolvePath("options.txt");
            if (optionFile.exists) {
                stream.open(optionFile, FileMode.READ);
                var messages:String = stream.readUTFBytes(stream.bytesAvailable);
                stream.close();
                deserializeMessages(messages);
            }
        }
    }

    private function deserializeMessages(opts:String):void {
        var lines:Array = opts.split("\n");
        if (lines.length >= 3) {
            var parts:Array = lines[0].split("\t");
            if (parts.length == 2) {
                startMillis = new Number(parts[1]);
            }
            parts = lines[1].split("\t");
            if (parts.length == 2) {
                endMillis = new Number(parts[1]);
            }
            parts = lines[2].split("\t");
            if (parts.length == 2) {
                this.autoRecordInterval = new Number(parts[1]);
            }
        }
    }

    public function saveOptions():void {
        if (!WorkLog.logFolder.exists) {
            WorkLog.logFolder.createDirectory();
        }
        var optionsFile:File = WorkLog.logFolder.resolvePath("options.txt");


        var output:String = "";
        output += "Day Start:\t" + startMillis + "\n";
        output += "Day End:\t" + endMillis + "\n";
        output += "Notify Interval:\t" + autoRecordInterval + "\n";

        var stream:FileStream = new FileStream();
        stream.open(optionsFile, FileMode.WRITE);
        stream.writeUTFBytes(output);
        stream.close();
    }
}
}
