package display.controls {
import flash.display.DisplayObject;
import flash.display.GradientType;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Matrix;

public class IconButton extends Sprite {
    public var hPadding:Number;
    public var vPadding:Number;
    private var borderWidth:uint = 1;
    private var cornerRadius:uint = 5;
    public var icon:DisplayObject;

    public function configure(icon:DisplayObject,hPadding:Number,vPadding:Number):void {
        this.hPadding = hPadding;
        this.vPadding = vPadding;
        this.icon = icon;
        if (!this.contains(icon)) {
            addChild(icon);
        }
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
        icon.x = hPadding;
        icon.y = vPadding;
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
        var bgWidth:Number = icon.width - borderWidth*2 + hPadding*2;
        var bgHeight:Number = icon.height - borderWidth*2 + vPadding*2;
        this.graphics.clear();
        var matr:Matrix = new Matrix();
        matr.rotate(Math.PI/9);
        matr.createGradientBox(bgWidth, bgHeight, Math.PI/2, 0, 1);
        this.graphics.lineStyle(1,0x898989);
        this.graphics.beginGradientFill(GradientType.LINEAR,[0xF0F0F0,0xE0E0E0],[1,1],[0,255],matr);
        this.graphics.drawRoundRect(0,0,bgWidth,bgHeight,cornerRadius,cornerRadius);
    }

    private function drawButtonBgOver():void {
        var bgWidth:Number = icon.width - borderWidth*2 + hPadding*2;
        var bgHeight:Number = icon.height - borderWidth*2 + vPadding*2;
        this.graphics.clear();
        var matr:Matrix = new Matrix();
        matr.rotate(Math.PI/9);
        matr.createGradientBox(bgWidth, bgHeight, Math.PI/2, 0, 1);
        this.graphics.lineStyle(1,0x707070);
        this.graphics.beginGradientFill(GradientType.LINEAR,[0xF0F0F0,0xE0E0E0],[1,1],[0,255],matr);
        this.graphics.drawRoundRect(0,0,bgWidth,bgHeight,cornerRadius,cornerRadius);
        this.graphics.lineStyle(1,0xBEDEFD);
        this.graphics.endFill();
        this.graphics.drawRoundRect(borderWidth,borderWidth,bgWidth-borderWidth*2,bgHeight-borderWidth*2,cornerRadius,cornerRadius);
    }

    private function drawButtonBgDown():void {
        var bgWidth:Number = icon.width - borderWidth*2 + hPadding*2;
        var bgHeight:Number = icon.height - borderWidth*2 + vPadding*2;
        this.graphics.clear();
        var matr:Matrix = new Matrix();
        matr.rotate(Math.PI/9);
        matr.createGradientBox(bgWidth, bgHeight, Math.PI/2, 0, 1);
        this.graphics.lineStyle(1,0x707070);
        this.graphics.beginGradientFill(GradientType.LINEAR,[0xE0E0E0,0xF0F0F0],[1,1],[0,255],matr);
        this.graphics.drawRoundRect(0,0,bgWidth,bgHeight,cornerRadius,cornerRadius);
        this.graphics.lineStyle(1,0xBEDEFD);
        this.graphics.endFill();
        this.graphics.drawRoundRect(borderWidth,borderWidth,bgWidth-borderWidth*2,bgHeight-borderWidth*2,cornerRadius,cornerRadius);
    }
}
}
