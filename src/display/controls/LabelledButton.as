package display.controls {
import flash.display.GradientType;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;


public class LabelledButton extends Sprite {
    public var hPadding:Number;
    public var vPadding:Number;
    public var tf:TextField;
    private var label:String;

    private static const buttonLabelFormat:TextFormat = new TextFormat("arial", 11, 0, true);

    public function configure(label:String,hPadding:Number,vPadding:Number):void {
        this.label = label;
        this.hPadding = hPadding;
        this.vPadding = vPadding;
        if (tf == null) {
            tf = new TextField();
            tf.autoSize = TextFieldAutoSize.CENTER;
            tf.mouseEnabled = false;
            tf.selectable = false;
            addChild(tf);
        }
        tf.text = label;
        if (!hasEventListener(MouseEvent.MOUSE_OVER)) {
            addEventListener(MouseEvent.MOUSE_OVER,buttonMouseOver);
        }
        if (!hasEventListener(MouseEvent.MOUSE_OUT)) {
            addEventListener(MouseEvent.MOUSE_OUT,buttonMouseOut);
        }
        if (!hasEventListener(MouseEvent.MOUSE_DOWN)) {
            addEventListener(MouseEvent.MOUSE_DOWN,buttonMouseDown);
        }
        if (!hasEventListener(MouseEvent.MOUSE_UP)) {
            addEventListener(MouseEvent.MOUSE_UP,buttonMouseUp);
        }
    }

    public function render():void {
        tf.x = -2 + hPadding;
        tf.y = -2 + vPadding;
        tf.setTextFormat(buttonLabelFormat);

        drawButtonBgNormal();
    }

    private function buttonMouseOver(event:MouseEvent):void {
        drawButtonBgOver();
    }

    private function buttonMouseDown(event:MouseEvent):void {
        drawButtonBgDown();
    }

    private function buttonMouseOut(event:MouseEvent):void {
        drawButtonBgNormal();
    }

    private function buttonMouseUp(event:MouseEvent):void {
        drawButtonBgNormal();
    }

    private function drawButtonBgNormal():void {
        var bgWidth:Number = tf.textWidth + hPadding*2;
        var bgHeight:Number = tf.textHeight + vPadding*2;
        this.graphics.clear();
        var matr:Matrix = new Matrix();
        matr.rotate(Math.PI/9);
        matr.createGradientBox(bgWidth, bgHeight, Math.PI/2, 0, 1);
        this.graphics.lineStyle(1,0x898989);
        this.graphics.beginGradientFill(GradientType.LINEAR,[0xF0F0F0,0xE0E0E0],[1,1],[0,255],matr);
        this.graphics.drawRoundRect(0,0,bgWidth,bgHeight,5,5);
    }

    private function drawButtonBgOver():void {
        var bgWidth:Number = tf.textWidth + hPadding*2;
        var bgHeight:Number = tf.textHeight + vPadding*2;
        this.graphics.clear();
        var matr:Matrix = new Matrix();
        matr.rotate(Math.PI/9);
        matr.createGradientBox(bgWidth, bgHeight, Math.PI/2, 0, 1);
        this.graphics.lineStyle(1,0x707070);
        this.graphics.beginGradientFill(GradientType.LINEAR,[0xF0F0F0,0xE0E0E0],[1,1],[0,255],matr);
        this.graphics.drawRoundRect(0,0,bgWidth,bgHeight,5,5);
        this.graphics.lineStyle(1,0xBEDEFD);
        this.graphics.endFill();
        this.graphics.drawRoundRect(1,1,bgWidth-2,bgHeight-2,5,5);
    }

    private function drawButtonBgDown():void {
        var bgWidth:Number = tf.textWidth + hPadding*2;
        var bgHeight:Number = tf.textHeight + vPadding*2;
        this.graphics.clear();
        var matr:Matrix = new Matrix();
        matr.rotate(Math.PI/9);
        matr.createGradientBox(bgWidth, bgHeight, Math.PI/2, 0, 1);
        this.graphics.lineStyle(1,0x707070);
        this.graphics.beginGradientFill(GradientType.LINEAR,[0xE0E0E0,0xF0F0F0],[1,1],[0,255],matr);
        this.graphics.drawRoundRect(0,0,bgWidth,bgHeight,5,5);
        this.graphics.lineStyle(1,0xBEDEFD);
        this.graphics.endFill();
        this.graphics.drawRoundRect(1,1,bgWidth-2,bgHeight-2,5,5);
    }
}
}
