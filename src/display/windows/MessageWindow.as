package display.windows {
import display.*;
import event.WorkLogEvent;
import display.controls.ControlFactory;

import flash.display.Graphics;

import flash.display.NativeWindow;
import flash.display.NativeWindowInitOptions;
import flash.display.NativeWindowType;
import flash.display.NativeWindowSystemChrome;
import flash.events.Event;
import flash.display.Sprite;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.ui.Keyboard;

import mx.formatters.DateFormatter;

import mx.utils.StringUtil;

/**
 * A lightweight window to display the message.
 */
public class MessageWindow extends NativeWindow {
    private static const stockWidth:int = 250;
    private var manager:DisplayManager;
    private var workLog:WorkLog;
    private const workingHoursformat:TextFormat = new TextFormat("arial", 14, 0x000000, true);
    private const futureHoursformat:TextFormat = new TextFormat("arial", 14, 0xFF6666, true);
    private const idleHoursformat:TextFormat = new TextFormat("arial", 14, 0x888888, true);

    private var textInput:TextField;
    private var textDisplay:TextField;

    private var billToInput:TextField;
    private var billToLabel:TextField;

    private var autoCompleteSprite:AutoCompleteSprite;

    public var workEvent:WorkLogEvent;

    public function MessageWindow(workEvent:WorkLogEvent, manager:DisplayManager):void {
        this.manager = manager;
        this.workLog = manager.workLog;
        this.workEvent = workEvent;
        var options:NativeWindowInitOptions = new NativeWindowInitOptions();
        options.type = NativeWindowType.LIGHTWEIGHT;
        options.systemChrome = NativeWindowSystemChrome.NONE;
        options.transparent = true;
        super(options);

        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, true);

        width = MessageWindow.stockWidth;

        textDisplay = new TextField();
        textInput = new TextField();
        billToInput = new TextField();
        billToLabel = new TextField();

        renderText();
        stage.addChild(textDisplay);

        textDisplay.x = 5;
        textDisplay.y = 5;
        textDisplay.width = width - 10;
        textDisplay.border = false;

        stage.addChild(textInput);

        textInput.backgroundColor = 0xFFFFFF;
        textInput.background = true;
        textInput.wordWrap = true;
        textInput.multiline = true;
        textInput.x = 5;
        textInput.y = textDisplay.textHeight + 15;
        textInput.type = TextFieldType.INPUT;
        textInput.width = width - 10;
        textInput.border = true;

        billToLabel.border = false;
        billToLabel.y = textInput.y + textInput.height + 5;
        stage.addChild(billToLabel);

        billToInput.background = 0xFFFFFF;
        billToInput.background = true;
        billToInput.height = 20;
        billToInput.y = textInput.y + textInput.height + 5;
        billToInput.type = TextFieldType.INPUT;
        billToInput.border = true;
        billToInput.addEventListener(KeyboardEvent.KEY_UP, getBillingAutoComplete);
        billToInput.addEventListener(Event.CHANGE,getBillingAutoComplete);
        stage.addChild(billToInput);

        var prevButton:Sprite = ControlFactory.button("<");
        stage.addChild(prevButton);
        prevButton.addEventListener(MouseEvent.CLICK, prevInterval);
        prevButton.x = 5;
        prevButton.y = textInput.y + textInput.height + 5;

        var nextButton:Sprite = ControlFactory.button(">");
        stage.addChild(nextButton);
        nextButton.addEventListener(MouseEvent.CLICK, nextInterval);
        nextButton.x = this.width - nextButton.width - 5;
        nextButton.y = textInput.y + textInput.height + 5;


        billToLabel.x = prevButton.x + prevButton.width + 5;
        billToInput.x = billToLabel.x + billToLabel.textWidth + 3;
        billToInput.width = nextButton.x - 7 - billToInput.x;

        var closeIcon:Sprite = ControlFactory.closeIcon();
        closeIcon.x = this.width - 21;
        closeIcon.y = 5;
        closeIcon.addEventListener(MouseEvent.CLICK, closeWindow);
        stage.addChild(closeIcon);


        height = textDisplay.textHeight + textInput.height + nextButton.height + 25;

        draw();
        alwaysInFront = true;
    }

    private function renderText():void {
        var formatter:DateFormatter = new DateFormatter();
        formatter.formatString = "JJ:NN";
        var message:String = "Work log from: " + formatter.format(workEvent.startTime) + " to: " + formatter.format(workEvent.endTime);
        textDisplay.text = message;
        textDisplay.wordWrap = true;
        if (workEvent.startTime.getTime() >= workLog.options.startTime().getTime()) {
            if (workEvent.startTime.getTime() > new Date().getTime()) {
                textDisplay.setTextFormat(futureHoursformat);
            } else if (workEvent.endTime.getTime() > workLog.options.endTime().getTime()) {
                textDisplay.setTextFormat(idleHoursformat);
            } else {
                textDisplay.setTextFormat(workingHoursformat)
            }
        } else {
            textDisplay.setTextFormat(idleHoursformat);
        }


        textInput.text = workEvent.log;
        billToInput.text = workEvent.billTo;
        billToLabel.text = "Bill to:";
    }

    private function getBillingAutoComplete(evt:Event):void {

        if (evt is KeyboardEvent) {
            if (KeyboardEvent(evt).keyCode != Keyboard.DELETE && KeyboardEvent(evt).keyCode != Keyboard.BACKSPACE) {
                return;
            }
        }


        var prevText:String = billToInput.text;
        var searchText:String = prevText;
        var tokens:Array = [prevText];
        var tokenIndex:int = 0;
        if (prevText.indexOf(",") >= 0) {
            tokens = prevText.split(",");
            var idx:int = billToInput.caretIndex;
            var tmp:String = "";
            var tmpIdx:int = 0;
            for each (var token:String in tokens) {
                tmp += token + ",";
                if (tmp.length >= idx) {
                    searchText = token;
                    tokenIndex = tmpIdx;
                    break;
                }
                tmpIdx++;
            }
        }

        var candidates:Array = workLog.getAutoCompleteOptions(searchText.toLowerCase());
        if (candidates.length == 0) {
            if (autoCompleteSprite != null) {
                autoCompleteSprite.visible = false;
                if (stage.contains(autoCompleteSprite)) {
                    stage.removeChild(autoCompleteSprite)
                }
            }
            return;
        }

        if (candidates.length == 1 && !(evt is KeyboardEvent)) {
            tokens[tokenIndex] = candidates[0];
            billToInput.text = tokens.join(",");
            var begin:int = billToInput.text.toLowerCase().indexOf(prevText.toLowerCase());
            var end:int = begin + prevText.length;
            billToInput.setSelection(end,billToInput.text.length);
            evt.preventDefault();
            hideAutoCompleteSprite();
        } else {
            if (autoCompleteSprite == null) {
                autoCompleteSprite = new AutoCompleteSprite();
            }
            while (autoCompleteSprite.numChildren > 0) {
                autoCompleteSprite.removeChildAt(0);
            }

            var lastPosY:int = 0;
            var widestText:int = 0;
            for each (var line:String in candidates) {
                var txt:TextField = new TextField();
                txt.autoSize = TextFieldAutoSize.LEFT;
                txt.text = line;
                autoCompleteSprite.addChild(txt);
                txt.y = lastPosY;
                lastPosY = txt.textHeight + lastPosY + 3;
                if (widestText < txt.textWidth) {
                    widestText = txt.textWidth;
                }
            }
            autoCompleteSprite.graphics.clear();
            autoCompleteSprite.graphics.lineStyle(0);
            autoCompleteSprite.graphics.beginFill(0xEBF4FE);
            autoCompleteSprite.graphics.drawRect(0, 0, widestText + 4, lastPosY);
            autoCompleteSprite.y = billToInput.y - lastPosY;
            autoCompleteSprite.x = billToInput.x;
            autoCompleteSprite.visible = true;

            //autoCompleteSprite.selectedIndex = autoCompleteSprite.numChildren-1;

            //autoCompleteSprite.highlightSelectedChild();

            if (!stage.contains(autoCompleteSprite)) {
                stage.addChild(autoCompleteSprite);
            }
        }
    }

    private function hideAutoCompleteSprite():void {
        if (autoCompleteSprite == null) {
            return;
        }
        if (stage.contains(autoCompleteSprite)) {
            stage.removeChild(autoCompleteSprite);
        }
        autoCompleteSprite.visible = false;
        autoCompleteSprite.selectedIndex = -1;
    }

    private function prevInterval(evt:MouseEvent):void {
        this.workEvent.log = StringUtil.trim(textInput.text);
        this.workEvent.billTo = StringUtil.trim(billToInput.text);
        manager.commit(this.workEvent);
        this.workEvent = workLog.prevEvent(this.workEvent);
        renderText();
    }

    private function nextInterval(evt:MouseEvent):void {
        this.workEvent.log = StringUtil.trim(textInput.text);
        this.workEvent.billTo = StringUtil.trim(billToInput.text);
        manager.commit(this.workEvent);
        this.workEvent = workLog.nextEvent(this.workEvent);
        renderText();
    }

    public function onKeyUp(evt:KeyboardEvent):void {
        if (!evt.shiftKey && evt.keyCode == Keyboard.ENTER && StringUtil.trim(textInput.text).length > 0) {
            close();
        }
        if (evt.keyCode == Keyboard.ESCAPE) {
            super.close();
        }
        if (evt.altKey) {
            if (evt.keyCode == Keyboard.RIGHT) {
                evt.preventDefault();
                nextInterval(null);
            } else if (evt.keyCode == Keyboard.LEFT) {
                evt.preventDefault();
                prevInterval(null);
            }
        }
    }

    private function closeWindow(event:MouseEvent):void {
        close();
    }

    public override function close():void {
        workEvent.log = StringUtil.trim(textInput.text);
        workEvent.billTo = StringUtil.trim(billToInput.text);
        manager.commit(workEvent);
        super.close();
    }

    private function draw():void {
        var background:Sprite = new Sprite();
        var g:Graphics = background.graphics;

            g.lineStyle(1);
            g.beginFill(0xE5F1FC, .9);
            g.drawRoundRect(2, 2, width - 4, height - 4, 8, 8);
            g.endFill();

        stage.addChildAt(background, 0);
    }

    public function animateY(endY:int):void {
        var dY:Number;
        var animate:Function = function (event:Event):void {
            dY = (endY - y) / 4
            y += dY;
            if (y <= endY) {
                y = endY;
                stage.removeEventListener(Event.ENTER_FRAME, animate);
            }
        }
        stage.addEventListener(Event.ENTER_FRAME, animate);
    }
}
}