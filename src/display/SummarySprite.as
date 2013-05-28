package display {
import event.WorkLogEvent;

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.Dictionary;
import mx.utils.StringUtil;

import vo.BillableItem;

public class SummarySprite extends Sprite {
    var keyFields:Array;
    var timeFields:Array;

    var titleField:TextField;

    private const titleFormat:TextFormat = new TextFormat("arial", 12, 0, true);
    private const cellFormat:TextFormat = new TextFormat("arial", 12, 0, false);

    public function SummarySprite() {
    }

    public function render(logItems:Array):void {
        while (this.numChildren > 0) {
            this.removeChildAt(0);
        }
        titleField = createTextField();
        titleField.text = "Summary";
        titleField.setTextFormat(titleFormat);
        addChild(titleField);

        keyFields = [];
        timeFields = [];
        var timeCount:Number = 0;
        var billableTimes:Dictionary = new Dictionary();
        billableTimes["default"] = new BillableItem("Default",0);

        for each (var evt:WorkLogEvent in logItems) {
            if (StringUtil.trim(evt.log).length > 0) {
                timeCount = (evt.endTime.getTime() - evt.startTime.getTime());
                var billingKey:String = "default";
                var keys:Array = [billingKey];
                if (StringUtil.trim(evt.billTo).length != 0) {
                    billingKey = StringUtil.trim(evt.billTo);
                    if (billingKey.indexOf(",") >= 0) {
                        keys = billingKey.split(",");
                    } else {
                        keys  = [billingKey];
                    }
                }
                for each (var key:String in keys) {
                    var lKey = StringUtil.trim(key.toLowerCase());
                    if (!billableTimes[lKey]) {
                        billableTimes[lKey] = new BillableItem(key, 0);
                    }

                    billableTimes[lKey].time += timeCount/keys.length;
                }
            }

        }

        var billableArray:Array = [];
        for each (var bi:BillableItem in billableTimes) {
            billableArray.push(bi);
        }
        billableArray.sort(sortBillableItems);

        var maxKeyWidth:Number = 0;
        var maxTimeWidth:Number = 0;
        var totalHours:Number = 0;
        for each (var bi:BillableItem in billableArray) {
            if (bi.time == 0) {
                continue;
            }
            var keyField:TextField = createTextField();
            keyField.text = bi.key;
            keyField.setTextFormat(cellFormat);
            keyFields.push(keyField);
            var hours:Number = bi.time/(1000*60*60);
            hours = Math.round(hours*100)/100;
            totalHours += hours;
            var timeField:TextField = createTextField();
            timeField.text = hours.toString() + " h";
            timeField.setTextFormat(cellFormat);
            timeFields.push(timeField);
            if (maxKeyWidth < keyField.width) {
                maxKeyWidth = keyField.width;
            }
            if (maxTimeWidth < timeField.width) {
                maxTimeWidth = timeField.width;
            }
        }

        var totalLabel:TextField = createTextField();
        addChild(totalLabel);
        totalLabel.text = "Billable Hours";
        totalLabel.setTextFormat(titleFormat);
        keyFields.push(totalLabel);
        if (maxKeyWidth < totalLabel.width) {
            maxKeyWidth = totalLabel.width;
        }

        var totalValue:TextField = createTextField();
        addChild(totalValue);
        totalValue.text = totalHours.toString();
        totalValue.setTextFormat(titleFormat)
        timeFields.push(totalValue);
        if (maxTimeWidth < totalValue.width) {
            maxTimeWidth = totalValue.width;
        }

        pack(maxKeyWidth,maxTimeWidth);
    }

    private function pack(keyFieldWidth:Number,timeFieldWidth:Number):void {
        var i:int;
        var yPrev:Number = titleField.y + titleField.textHeight + 5;
        for (i=0;i<keyFields.length;i++) {
            var keyField:TextField = keyFields[i] as TextField;
            keyField.border = true;
            keyField.borderColor = 0x888888;
            keyField.y = yPrev;
            keyField.autoSize = TextFieldAutoSize.NONE;
            keyField.width = keyFieldWidth;
            yPrev = keyField.y + keyField.height;
            var timeField:TextField = timeFields[i] as TextField;
            timeField.border = true;
            timeField.borderColor = 0x888888;
            timeField.y = keyField.y;
            timeField.x = keyFieldWidth;
            timeField.autoSize = TextFieldAutoSize.NONE;
            timeField.width = timeFieldWidth + 5;
        }
    }

    private function createTextField():TextField {
        var tf:TextField = new TextField();
        tf.autoSize = TextFieldAutoSize.LEFT;
        addChild(tf);
        return tf;
    }

    private function sortBillableItems(item1:BillableItem,item2:BillableItem):int {
        if (item1.time > item2.time) {
            return 1;
        }
        return -1;
    }
}
}
