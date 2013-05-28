package {
import event.NotifyUserEvent;
import event.WorkLogEvent;

import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.Timer;
import flash.events.Event;
import flash.events.TimerEvent;

import model.TimeTrackerOptions;


import mx.formatters.DateFormatter;
import mx.utils.StringUtil;

import util.DateFactory;

/**
 * The MessageCenter keeps a running 1 minute timer and dispatches a message event
 * if we need to notify the user at the end of a timer cycle.
 */
public class WorkLog extends EventDispatcher {

    public static const CLOCK_IS_ON:String = "clockIsOn";
    public static const CLOCK_IS_OFF:String = "clockIsOff";

    public static const ON_THE_CLOCK_MESSAGE:String = "Going on the clock";
    public static const OFF_THE_CLOCK_MESSAGE:String = "Going off the clock";

    private static const billingCodeFile:String = "billingCodes.txt";

    public var onTheClock:Boolean = false;

    public var options:TimeTrackerOptions;

    public var dateFactory:DateFactory;

    private var messageTimer:Timer = new Timer(60 * 1000);

    private var nextAutoCapture:Date;

    private var currentWorkLog:Object = {};

    private var billingCodes:Object = {};

    public static var logFolder:File = File.userDirectory.resolvePath("timeTracker");

    private var currentFileName:String;

    private var lastLogEntry:String = "";
    private var lastBillTo:String = "";

    public function WorkLog(options:TimeTrackerOptions,dateFactory:DateFactory) {
        this.options = options;
        this.dateFactory = dateFactory;
    }

    public function initialize():WorkLog {
        messageTimer.addEventListener(TimerEvent.TIMER, onMessageTimer);
        messageTimer.start();
        computeNextAutoCapture();
        updateCurrentFileName();
        currentWorkLog = loadOldMessages(currentFileName);
        loadBillingCodes();
        var now:Date = dateFactory.getCurrentDateTime();
        if (now.getTime() > options.startTime().getTime()
                && now.getTime() < options.endTime().getTime()) {
            clockOn();
        } else {
            clockOff();
        }
        return this;
    }


    // TODO: The logic in here is far too complex. Rework it.
    public function onMessageTimer(evt:Event):void {
        updateCurrentFileName();
        var now:Date = dateFactory.getCurrentDateTime();

        // Don't auto track time on the week-end
        if ((options.startTime().getDay() == 0 || options.startTime().getDay() == 6) && !onTheClock) {
            return;
        }

        // Work day hasn't started yet
        if (now.getTime() < options.startTime().getTime() && onTheClock == false) {
            if (now.getTime() + options.autoRecordInterval < options.startTime().getTime()) {
                computeNextAutoCapture();
            }
            return;
        }

        // Work day has ended
        if (now.getTime() > options.endTime().getTime()) {
            // Work day has just ended
            if (now.getTime() < options.endTime().getTime() + messageTimer.delay) {
                if (onTheClock) {
                    showClockEndMessage();
                    clockOff();
                }
            }
            if (onTheClock == false) {
                computeNextAutoCapture();
                return;
            }
        }

        // Work day has just started
        if (now.getTime() - messageTimer.delay < options.startTime().getTime()) {
            if (!onTheClock) {
                showClockStartMessage();
                clockOn();
            }
        }

        // Work day in progress
        if (now.getTime() > nextAutoCapture.getTime() && onTheClock) {
            captureWorkLog(nextAutoCapture);
            computeNextAutoCapture();
        }
    }

    private function showClockStartMessage():void {
        var event:NotifyUserEvent = new NotifyUserEvent(ON_THE_CLOCK_MESSAGE);
        dispatchEvent(event);
    }

    private function showClockEndMessage():void {
        var event:NotifyUserEvent = new NotifyUserEvent(OFF_THE_CLOCK_MESSAGE);
        dispatchEvent(event);
    }

    private function updateCurrentFileName():void {
        var d:Date = dateFactory.getCurrentDateTime();
        var fileName:String = getFileNameForDate(d);

        var oldFileName:String = currentFileName;
        currentFileName = fileName;
        if (currentFileName != oldFileName) {
            currentWorkLog = {};
        }
    }

    public function getFileNameForDate(date:Date):String {
        var formatter:DateFormatter = new DateFormatter();
        formatter.formatString = "YYYMMDD";
        var fileName:String = formatter.format(date);
        return fileName + ".log";
    }

    /**
     * Iterates from start of today in TimeTrackerOptions.autoRecordInterval increments
     * until MessageCenter.nextAutoCapture is greater than the current time.
     */
    private function computeNextAutoCapture():void {
        var now:Date = dateFactory.getCurrentDateTime();
        var startOfToday:Date = new Date(now.getFullYear(),now.getMonth(),now.getDate(),0,0,0,0);
        nextAutoCapture = new Date(startOfToday.getTime());
        while (nextAutoCapture.getTime() < now.getTime()) {
            nextAutoCapture.setTime(nextAutoCapture.getTime() + options.autoRecordInterval);
        }
    }

    public function clockOff():void {
        dispatchEvent(new Event(CLOCK_IS_OFF));
        onTheClock = false;
    }

    public function clockOn():void {
        onTheClock = true;
        dispatchEvent(new Event(CLOCK_IS_ON));
        computeNextAutoCapture();
    }

    public function prevEvent(evt:WorkLogEvent):WorkLogEvent {
        var key:String = evt.getKey();
        var prev:WorkLogEvent = new WorkLogEvent(WorkLogEvent.CAPTURE_WORK_LOG, dateFactory.getPrevStartTime(evt,options),dateFactory.getPrevEndTime(evt,options),"","");
        var prevKey:String = prev.getKey();
        if (currentWorkLog[prevKey] != null) {
            prev = currentWorkLog[prevKey];
        }
        return prev;
    }

    public function nextEvent(evt:WorkLogEvent):WorkLogEvent {
        var key:String = evt.getKey();
        var next:WorkLogEvent = new WorkLogEvent(WorkLogEvent.CAPTURE_WORK_LOG, dateFactory.getNextStartTime(evt,options),dateFactory.getNextEndTime(evt,options),"","");
        var nextKey:String = next.getKey();
        if (currentWorkLog[nextKey] != null) {
            next = currentWorkLog[nextKey];
        }
        return next;
    }

    public function messageNow(evt:MouseEvent):void {
        captureWorkLog(nextAutoCapture);
    }

    private function captureWorkLog(endTime:Date):void {

        var startTime:Date;
        startTime = new Date(endTime.valueOf() - options.autoRecordInterval);

        var log:String = "";
        var logEvent:WorkLogEvent = new WorkLogEvent(WorkLogEvent.CAPTURE_WORK_LOG, startTime, endTime, log,"");

        var key:String = logEvent.getKey();
        if (currentWorkLog[key] != null) {
            logEvent.log = WorkLogEvent(currentWorkLog[key]).log;
            logEvent.billTo = WorkLogEvent(currentWorkLog[key]).billTo;
        } else {
            logEvent.log = lastLogEntry;
            logEvent.billTo = lastBillTo;
        }
        dispatchEvent(logEvent);
    }

    public function getLogArray(date:Date):Array {
        var now:Date = new Date();
        var logEntries:Object;
        if (now.getFullYear() == date.getFullYear()
                && now.getMonth() == date.getMonth()
                && now.getDate() == date.getDate()) {
            logEntries = currentWorkLog;
        } else {
            logEntries = loadOldMessages(getFileNameForDate(date));
        }
        var items:Array = [];
        for each (var event:WorkLogEvent in logEntries) {
            items.push(event);
        }
        items.sort(timeCompare);
        var lastEvent:WorkLogEvent = null;
        var tmp:Array = [];
        var dayStart:Date = dateFactory.startofDay(date);
        dayStart.setTime(dayStart.getTime() + options.startMillis);
        var startEvent:WorkLogEvent = createEmptyLogEvent(dayStart);
        var firstEvent:WorkLogEvent = items[0] as WorkLogEvent;
        if (firstEvent) {
            while (true) {
                if (startEvent.startTime.getTime() < firstEvent.startTime.getTime()) {
                    tmp.push(startEvent);
                    startEvent = createEmptyLogEvent(startEvent.endTime);
                } else {
                    break;
                }
            }
        }
        for each (var evt:WorkLogEvent in items) {
            if (lastEvent != null) {
                while(lastEvent.endTime.getTime() < evt.startTime.getTime()) {
                    lastEvent = createEmptyLogEvent(lastEvent.endTime);
                    tmp.push(lastEvent);
                }
            }
            tmp.push(evt);
            lastEvent = evt;
        }
        var dayEnd:Date = dateFactory.startofDay(date);
        dayEnd.setTime(dayEnd.getTime() + options.endMillis);
        var endEvent:WorkLogEvent = createEmptyLogEvent(dayEnd);
        var lastEvent:WorkLogEvent = items[items.length-1] as WorkLogEvent;
        if (lastEvent && lastEvent.startTime.getTime() < endEvent.startTime.getTime()) {
            while (true) {
                lastEvent = createEmptyLogEvent(lastEvent.endTime);
                if (lastEvent.startTime.getTime() < endEvent.startTime.getTime()) {
                    tmp.push(lastEvent);
                } else {
                    break;
                }
            }
        }
        return tmp;
    }

    public function getAutoCompleteOptions(str:String):Array{

        if (StringUtil.trim(str).length == 0) {
            return [];
        }

        var candidates:Array = [];
        for each (var line:String in billingCodes) {
            if (line.toLowerCase().indexOf(str.toLowerCase()) > -1) {
                candidates.push(line);
            }
        }

        candidates.sort(stringCompare);

        return candidates;
    }

    private function createEmptyLogEvent(startTime:Date):WorkLogEvent {
        var endTime:Date = new Date(startTime.getTime() + options.autoRecordInterval);
        return new WorkLogEvent(WorkLogEvent.CAPTURE_WORK_LOG,startTime,endTime,"","");
    }

    public function recordWorkLog(evt:WorkLogEvent):void {
        currentWorkLog[evt.getKey()] = evt;
        lastLogEntry = evt.log;
        lastBillTo = evt.billTo;
        writeLogToDisk();
        if (evt.billTo.length > 0) {
            var codes:Array = evt.billTo.split(",");
            for each (var code:String in codes) {
                code = StringUtil.trim(code);
                if (code.length > 0) {
                    billingCodes[code] = code;
                }
            }
            writeBillingCodesToDisk();
        }
    }


    public function loadOldMessages(fileName:String):Object {
        var result:Object = {};
        if (logFolder.exists) {
            var stream:FileStream = new FileStream();
            var logFile:File = logFolder.resolvePath(fileName);
            if (logFile.exists) {
                stream.open(logFile, FileMode.READ);
                var contents:String = stream.readUTFBytes(stream.bytesAvailable);
                stream.close();
                result = deserializeMessages(contents);
            }
        }
        return result;
    }


    public function loadBillingCodes():void {
        billingCodes = {};
        if (logFolder.exists) {
            var stream:FileStream = new FileStream();
            var billingCodeFile:File = logFolder.resolvePath(billingCodeFile);
            if (billingCodeFile.exists) {
                stream.open(billingCodeFile, FileMode.READ);
                var contents:String = stream.readUTFBytes(stream.bytesAvailable);
                stream.close();
                var lines:Array = contents.split("\n");
                for each (var line:String in lines) {
                    if (StringUtil.trim(line).length > 0) {
                        billingCodes[line] = line;
                    }
                }
            }
        }
    }

    private function deserializeMessages(contents:String):Object {
        var lines:Array = contents.split("\n");
        var items:Object = {};

        for each (var line:String in lines) {
            var parts:Array = line.split("\t");
            if (parts.length >= 3) {
                var startTime:Date = parseDate(parts[0]);
                var endTime:Date = parseDate(parts[1]);
                var log:String = StringUtil.trim(decodeURI(parts[2]));
                var billTo:String = "";
                if (parts.length == 4) {
                    billTo = StringUtil.trim(decodeURI(parts[3]));
                }
                var evt:WorkLogEvent = new WorkLogEvent(WorkLogEvent.SAVE_WORK_LOG, startTime, endTime, log,billTo);
                items[evt.getKey()] = evt;
            }
        }
        return items;
    }

    private function parseDate(str:String):Date {
        var year:Number = new Number(str.substr(0, 4));
        var month:Number = new Number(str.substr(4, 2)) - 1;
        var day:Number = new Number(str.substr(6, 2));
        var hour:Number = new Number(str.substr(8, 2));
        var min:Number = new Number(str.substr(10, 2));
        var d:Date = new Date(year, month, day, hour, min, 0, 0);
        return d;
    }

    private function writeLogToDisk():void {
        if (!logFolder.exists) {
            logFolder.createDirectory();
        }
        updateCurrentFileName();
        var logFile:File = logFolder.resolvePath(currentFileName);

        var items:Array = getLogArray(new Date());

        var output:String = "";
        for each (var evt:WorkLogEvent in items) {
            output += evt.serialize() + "\n";
        }
        var stream:FileStream = new FileStream();
        stream.open(logFile, FileMode.WRITE);
        stream.writeUTFBytes(output);
        stream.close();
    }

    private function writeBillingCodesToDisk():void {
        if (!logFolder.exists) {
            logFolder.createDirectory();
        }
        var billingCodeFile:File = logFolder.resolvePath(billingCodeFile);

        var items:String = "";
        for each (var line:String in billingCodes) {
            items += line + "\n";
        }

        var stream:FileStream = new FileStream();
        stream.open(billingCodeFile, FileMode.WRITE);
        stream.writeUTFBytes(items);
        stream.close();
    }

    private function timeCompare(item1:WorkLogEvent, item2:WorkLogEvent):int {
        if (item1.startTime.valueOf() > item2.startTime.valueOf()) {
            return 1;
        }
        return -1;
    }

    private function stringCompare(item1:String, item2:String):int {
        if (item1.toLowerCase() > item2.toLowerCase()) {
            return 1;
        }
        return -1;
    }


}
}