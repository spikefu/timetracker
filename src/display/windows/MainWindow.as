package display.windows {
import display.*;
import display.controls.ControlFactory;
import display.controls.LabelledButton;

import event.WorkLogEvent;

import flash.display.NativeWindow;
import flash.display.NativeWindowInitOptions;
import flash.display.NativeWindowSystemChrome;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import WorkLog;

import mx.formatters.DateFormatter;

public class MainWindow extends NativeWindow {
    private static const stockWidth:int = 600;
    private static const stockHeight:int = 650;
    private const format:TextFormat = new TextFormat("arial", 14, 0, true);
    private const itemFormat:TextFormat = new TextFormat("arial", 12, 0);

    private var workLog:WorkLog;

    private var activeDate:Date;

    public function MainWindow(workLog:WorkLog) {
        this.workLog = workLog;
        var options:NativeWindowInitOptions = new NativeWindowInitOptions();

        options.systemChrome = NativeWindowSystemChrome.STANDARD;

        super(options);
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        width = stockWidth;
        height = stockHeight;
        activeDate = new Date();
        loadLogForActiveDate();
    }

    private function showPrevDay(event:MouseEvent):void {
        activeDate.setTime(activeDate.getTime() - 1000 * 60 * 60 * 24);
        loadLogForActiveDate();
    }

    private function showNextDay(event:MouseEvent):void {
        activeDate.setTime(activeDate.getTime() + 1000 * 60 * 60 * 24);
        loadLogForActiveDate();
    }

    private function loadLogForActiveDate():void {

        while (stage.numChildren > 0) {
            stage.removeChildAt(0);
        }


        var logItems:Array = workLog.getLogArray(activeDate);

        var formatter:DateFormatter = new DateFormatter();
        formatter.formatString = "EEE, DD MMM YYYY";
        var dateString:String = "";
        dateString = ": " + formatter.format(activeDate);

        var titleDisplay:TextField = new TextField();
        titleDisplay.text = "Time Tracker " + dateString;
        titleDisplay.wordWrap = false;
        titleDisplay.setTextFormat(format);
        stage.addChild(titleDisplay);
        titleDisplay.selectable = false;
        titleDisplay.y = 7;
        titleDisplay.autoSize = TextFieldAutoSize.LEFT;
        titleDisplay.border = false;

        var prevDay:LabelledButton = ControlFactory.button("<");
        prevDay.addEventListener(MouseEvent.CLICK, showPrevDay);
        prevDay.x = 5;
        prevDay.y = 5;
        stage.addChild(prevDay);

        titleDisplay.x = prevDay.x + prevDay.width + 5;

        var nextDay:LabelledButton = ControlFactory.button(">");
        nextDay.addEventListener(MouseEvent.CLICK, showNextDay);
        nextDay.x = titleDisplay.x + titleDisplay.width + 5;
        nextDay.y = 5;
        stage.addChild(nextDay);


        if (logItems.length == 0) {
            return;
        }
        var yPrev:Number = titleDisplay.y + titleDisplay.height + 15;
        var logDisplay:TextField;

        for each (var evt:WorkLogEvent in logItems) {
            logDisplay = new TextField();
            logDisplay.text = evt.toString();
            logDisplay.multiline = false;
            logDisplay.setTextFormat(itemFormat);
            stage.addChild(logDisplay);
            logDisplay.x = 5;
            logDisplay.y = yPrev;
            logDisplay.width = this.width - 10;
            yPrev = logDisplay.y + logDisplay.textHeight + 5;
        }

        var summarySprite:SummarySprite = new SummarySprite();
        stage.addChild(summarySprite);
        summarySprite.render(logItems);
        summarySprite.y = yPrev + 10;
        summarySprite.x = 5;

    }


}
}
