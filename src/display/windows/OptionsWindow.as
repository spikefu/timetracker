package display.windows {
import display.controls.ControlFactory;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.NativeWindow;
import flash.display.NativeWindowInitOptions;
import flash.display.NativeWindowSystemChrome;
import flash.display.NativeWindowType;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.ui.Keyboard;

import WorkLog;

import mx.controls.DateChooser;
import mx.controls.Image;

import mx.formatters.DateFormatter;

public class OptionsWindow extends NativeWindow {
    private static const stockWidth:int = 300;
    private static const stockHeight:int = 200;
    private var messageCenter:WorkLog;
    private const titleFormat:TextFormat = new TextFormat("arial", 14, 0, true);

    private var startInput:TextField;
    private var endInput:TextField;
    private var notifyInput:TextField;

    public function OptionsWindow(messageCenter:WorkLog) {
        this.messageCenter = messageCenter;
        var initOptions:NativeWindowInitOptions = new NativeWindowInitOptions();
        initOptions.type = NativeWindowType.LIGHTWEIGHT;
        initOptions.systemChrome = NativeWindowSystemChrome.NONE;
        initOptions.transparent = true;
        super(initOptions);

        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        width = stockWidth;
        height = stockHeight;

        var titleDisplay:TextField = new TextField();

        titleDisplay.text = "Time Tracker Options";
        titleDisplay.wordWrap = true;
        titleDisplay.setTextFormat(titleFormat);
        stage.addChild(titleDisplay);
        titleDisplay.selectable = false;
        titleDisplay.x = 5;
        titleDisplay.y = 5;
        titleDisplay.width = width - 10;
        titleDisplay.border = false;

        var closeIcon:Sprite = ControlFactory.closeIcon();
        closeIcon.x = this.width - 21;
        closeIcon.y = 5;
        closeIcon.addEventListener(MouseEvent.CLICK, closeWindow);
        stage.addChild(closeIcon);

        var startLabel:TextField = ControlFactory.label("Day Start:");
        startLabel.x = 5;
        startLabel.y = titleDisplay.y + titleDisplay.textHeight + 10;
        stage.addChild(startLabel);

        startInput = ControlFactory.timeInput(messageCenter.options.startMillis);
        startInput.x = startLabel.x + startLabel.width + 5;
        startInput.y = startLabel.y;
        stage.addChild(startInput);

        var endLabel:TextField = ControlFactory.label("Day End:");
        endLabel.x = 5;
        endLabel.y = startLabel.y + startLabel.textHeight + 10;
        stage.addChild(endLabel);

        endInput = ControlFactory.timeInput(messageCenter.options.endMillis);
        endInput.x = endLabel.x + endLabel.width + 5;
        endInput.y = endLabel.y;
        stage.addChild(endInput);

        endLabel.autoSize = startLabel.autoSize = TextFieldAutoSize.NONE;
        endInput.autoSize = startInput.autoSize = TextFieldAutoSize.NONE;

        endLabel.width = startLabel.width = Math.max(endLabel.width, startLabel.width);
        endInput.width = startInput.width = Math.max(endInput.width, startInput.width);
        startInput.x = startLabel.x + startLabel.width + 5;
        endInput.x = endLabel.x + endLabel.width + 5;

        var okButton:Sprite = ControlFactory.button("OK");
        okButton.x = this.width - okButton.width - 10;
        okButton.y = this.height - okButton.height - 10;
        okButton.addEventListener(MouseEvent.CLICK, saveOptions);
        stage.addChild(okButton);

        var cancelButton:Sprite = ControlFactory.button("Cancel");
        cancelButton.x = okButton.x - cancelButton.width - 10;
        cancelButton.y = okButton.y;
        cancelButton.addEventListener(MouseEvent.CLICK, closeWindow);
        stage.addChild(cancelButton);

        draw();
        alwaysInFront = true;
    }

    private function closeWindow(event:Event = null):void {
        super.close();
    }

    private function saveOptions(event:Event):void {
        messageCenter.options.startMillis = new Number(startInput.text)*60*60*1000;
        messageCenter.options.endMillis = new Number(endInput.text)*60*60*1000;
        messageCenter.options.saveOptions();
        super.close();
    }


    private function draw():void {
        var background:Sprite = new Sprite();
        with (background.graphics) {
            lineStyle(1);
            beginFill(0xE5F1FC, 1);
            drawRoundRect(2, 2, width - 4, height - 4, 8, 8);
            endFill();
        }
        stage.addChildAt(background, 0);
    }
}
}
