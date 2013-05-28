package display {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.text.TextField;

public class AutoCompleteSprite extends Sprite{
    public var selectedIndex:int = -1;

    public function highlightSelectedChild():void {
        if (this.numChildren < selectedIndex || selectedIndex < 0) {
            return;
        }
        var tf:TextField = getChildAt(selectedIndex) as TextField;
        tf.background = true;
        tf.backgroundColor = 0xD6EAFF;
    }
}
}
