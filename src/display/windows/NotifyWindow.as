package display.windows {
import display.*;
import display.controls.ControlFactory;

import event.NotifyUserEvent;

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
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.ui.Keyboard;

import mx.controls.Button;
import mx.controls.Text;

import mx.formatters.DateFormatter;
import mx.utils.StringUtil;

/**
 * A lightweight window to display the message.
 */
public class NotifyWindow extends NativeWindow {
    private static const stockWidth:int = 250;
    private var manager:DisplayManager;
    private const format:TextFormat = new TextFormat("arial", 14, 0,true);

    public var evt:NotifyUserEvent;

    private var okSprite:Sprite;

    public function NotifyWindow(evt:NotifyUserEvent,manager:DisplayManager):void {
        this.manager = manager;
        this.evt = evt;
        var options:NativeWindowInitOptions = new NativeWindowInitOptions();
        options.type = NativeWindowType.LIGHTWEIGHT;
        options.systemChrome = NativeWindowSystemChrome.NONE;
        options.transparent = true;
        super(options);

        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;

        width = NotifyWindow.stockWidth;

        var textDisplay:TextField = new TextField();

        textDisplay.text = evt.message;
        textDisplay.wordWrap = true;
        textDisplay.setTextFormat(format);
        stage.addChild(textDisplay);
        textDisplay.x = 5;
        textDisplay.y = 5;
        textDisplay.width = width - 10;
        textDisplay.border = false;

        okSprite = ControlFactory.button("ok");
        okSprite.addEventListener(MouseEvent.CLICK, onOk);
        stage.addChild(okSprite);
        okSprite.y = textDisplay.textHeight + 15;
        okSprite.x = width - okSprite.width - 15;

        height = textDisplay.textHeight + okSprite.height + 30;

        draw();
        alwaysInFront = true;
    }

    private function onOk(event:MouseEvent):void {
        close();
    }

    public override function close():void {
        super.close();
    }

    private function draw():void {
        var background:Sprite = new Sprite();
        with (background.graphics) {
            lineStyle(1);
            beginFill(0xE5F1FC, .9);
            drawRoundRect(2, 2, width - 4, height - 4, 8, 8);
            endFill();
        }
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