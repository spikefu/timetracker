package display.controls {
import display.controls.IconButton;
import display.controls.LabelledButton;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;


public class ControlFactory {

    private static const labelFormat:TextFormat = new TextFormat("arial", 12, 0, false);
    private static const inputFormat:TextFormat = new TextFormat("arial", 12, 0, false);

    private static const hPadding:Number = 10;
    private static const vPadding:Number = 4;

    private static var buttonMode:Boolean = false;

    [Bindable]
    [Embed(source="../../gfx/close.png")]
    private static var _closeIcon:Class;

    [Bindable]
    [Embed(source="../../gfx/button_background.png")]
    private static var _buttonBackground:Class;

    public static function label(text:String):TextField {
        var lbl:TextField = new TextField();
        lbl.text = text;
        lbl.selectable = false;
        lbl.autoSize = TextFieldAutoSize.LEFT;
        lbl.setTextFormat(labelFormat);
        return lbl;
    }

    public static function textInput(text:String):TextField {
        var input:TextField = new TextField();
        input.text = text;
        input.type = TextFieldType.INPUT;
        input.selectable = true;
        input.border = true;
        input.backgroundColor = 0xFFFFFF;
        input.background = true;
        input.autoSize = TextFieldAutoSize.LEFT;
        input.multiline = false;
        input.setTextFormat(inputFormat);
        return input;
    }

    /**
     *
     * @param time: milliseconds after the start of the day.
     * @return
     */
    public static function timeInput(time:Number):TextField {
        var input:TextField = textInput("");
        input.restrict = "0-9";
        input.maxChars = 2;
        var hours:Number = Math.floor(time/(60*60*1000));
        var hourText:String = hours.toString();
        if (hourText.length < 2) {
            hourText = "0" + hourText;
        }
        input.text = hourText;
        return input;
    }

    public static function button(label:String):LabelledButton {
        var buttonSprite:LabelledButton = new LabelledButton();
        buttonSprite.configure(label,hPadding,vPadding);
        buttonSprite.render();

        buttonSprite.buttonMode = buttonMode;
        return buttonSprite;
    }


    public static function closeIcon():Sprite {
        var iconSprite:Sprite = new Sprite();
        var btn:IconButton = new IconButton();
        btn.configure(iconSprite,5,5);
        var g:Graphics = iconSprite.graphics;
        g.clear();
        g.lineStyle(1);
        g.moveTo(0,0);
        g.lineTo(6,6);
        g.moveTo(0,6);
        g.lineTo(6,0);
        btn.render();
        return btn;
    }

    private static function createIconSprite(bmd:BitmapData):Sprite {
        var sprite:Sprite = new Sprite();
        var g:Graphics = sprite.graphics;
        var mtx:Matrix = new Matrix();
        mtx.translate(0, 0);
        g.beginBitmapFill(bmd, mtx, false, false);
        g.drawRect(0, 0, bmd.width, bmd.height);
        g.endFill();
        sprite.buttonMode = buttonMode;
        return sprite;
    }


}
}
