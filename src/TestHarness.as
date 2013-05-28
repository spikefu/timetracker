package {
import display.DisplayManager;
import event.NotifyUserEvent;
import event.WorkLogEvent;
import display.controls.ControlFactory;

import flash.display.Sprite;
import flash.events.MouseEvent;

import WorkLog;
import model.TimeTrackerOptions;

import util.DateFactory;

public class TestHarness extends Sprite {

    var workLog:WorkLog;
    var displayManager:DisplayManager;
    var dateFactory:DateFactory;
    public function TestHarness() {
        dateFactory = new DateFactory();
        var options:TimeTrackerOptions = new TimeTrackerOptions(dateFactory);
        workLog = new WorkLog(options,dateFactory);
        workLog.initialize();
        displayManager = new DisplayManager(workLog);

        workLog.addEventListener(NotifyUserEvent.NOTIFY_USER, displayManager.notifyUser);
        workLog.addEventListener(WorkLogEvent.CAPTURE_WORK_LOG, displayManager.showLogCaptureWindow);

        var notifyUserButton:Sprite = ControlFactory.button("Notify User Window");
        notifyUserButton.addEventListener(MouseEvent.CLICK,showNotifyUserWindow);
        stage.addChild(notifyUserButton);

        var workLogButton:Sprite = ControlFactory.button("Work Log Window");
        workLogButton.addEventListener(MouseEvent.CLICK,showWorkLogWindow);
        stage.addChild(workLogButton);
        workLogButton.y = notifyUserButton.y + notifyUserButton.height + 5;

        this.height = 600;
        this.width = 600;
        this.graphics.beginFill(0xFFFFFF);
        this.graphics.drawRect(0,0,this.width,this.height);
    }

    private function showNotifyUserWindow(event:MouseEvent):void {
        workLog.dispatchEvent(new NotifyUserEvent("User Notification"));
    }

    private function showWorkLogWindow(event:MouseEvent):void {
        workLog.messageNow(event);
    }
}
}
