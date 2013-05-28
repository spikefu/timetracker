package display {
import display.windows.MainWindow;
import display.windows.MessageWindow;
import display.windows.NotifyWindow;
import display.windows.OptionsWindow;

import event.NotifyUserEvent;
import event.WorkLogEvent;

import flash.desktop.NativeApplication;
import flash.display.NativeWindow;
import flash.display.Screen;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Timer;

import WorkLog;

import mx.charts.renderers.AreaRenderer;
import mx.utils.StringUtil;


public class DisplayManager extends EventDispatcher {
    private var currentScreen:Screen;
    private const gutter:int = 10;

    private var openWindows:Array = [];

    public var workLog:WorkLog;

    public function DisplayManager(workLog:WorkLog):void {
        this.workLog = workLog;
    }

    //Create a new message window and animate its entrance
    public function showLogCaptureWindow(evt:WorkLogEvent):void {
        for each (var win:MessageWindow in openWindows) {
            if (win.workEvent.getKey() == evt.getKey()) {
                return;
            }
        }
        if (openWindows.length >= 16) {
            return;
        }
        var messageWindow:MessageWindow = new MessageWindow(evt, this);
        var position:Point = findSpotForMessage(messageWindow.bounds);
        messageWindow.x = position.x;
        messageWindow.y = currentScreen.bounds.height;

        messageWindow.visible = true;
        messageWindow.animateY(position.y);
        openWindows.push(messageWindow);
    }

    public function notifyUser(event:NotifyUserEvent):void {
        var window:NotifyWindow = new NotifyWindow(event, this);
        var position:Point = findSpotForMessage(window.bounds);
        window.x = position.x;
        window.y = currentScreen.bounds.height;

        window.visible = true;
        window.animateY(position.y);
    }

    public function showMainWindow(messageCenter:WorkLog):void {
        var win:MainWindow = new MainWindow(messageCenter);
        win.visible = true;
        win.title = "YellowBadger - Time Tracker";
    }

    public function showOptions(messageCenter:WorkLog):void {
        var win:OptionsWindow = new OptionsWindow(messageCenter);
        win.visible = true;

        var midScreenX:Number = Screen.mainScreen.bounds.width/2;
        var midScreenY:Number = Screen.mainScreen.bounds.height/2;
        win.x = midScreenX - win.width/2;
        win.y = midScreenY - win.height/2;
    }

    public function commit(evt:WorkLogEvent):void {
        if (StringUtil.trim(evt.log).length > 0) {
            var evt:WorkLogEvent = new WorkLogEvent(WorkLogEvent.SAVE_WORK_LOG, evt.startTime, evt.endTime, evt.log,evt.billTo);
            dispatchEvent(evt);
        }
        var tmp:Array = [];
        for each (var win:MessageWindow in openWindows) {
            if (win.workEvent.getKey() != evt.getKey()) {
                tmp.push(win);
            }
        }
        openWindows = tmp;
    }


    //Finds a spot onscreen for a message window
    private function findSpotForMessage(size:Rectangle):Point {
        var spot:Point = new Point();
        var done:Boolean = false;
        for each(var screen:Screen in Screen.screens) {
            currentScreen = screen;
            for (var x:int = screen.visibleBounds.x + screen.visibleBounds.width - size.width - gutter;
                 x >= screen.visibleBounds.x;
                 x -= (size.width + gutter)) {
                for (var y:int = screen.visibleBounds.y + screen.visibleBounds.height - size.height - gutter;
                     y >= screen.visibleBounds.y;
                     y -= 10) {
                    var testRect:Rectangle = new Rectangle(x, y, size.width + gutter, size.height + gutter);
                    if (!isOccupied(testRect)) {
                        spot.x = x;
                        spot.y = y;
                        done = true;
                        break;
                    }
                }
                if (done) {
                    break;
                }
            }
            if (done) {
                break;
            }
        }
        return spot;
    }

    //Checks to see if any opened message windows are in a particular spot on screen
    private function isOccupied(testRect:Rectangle):Boolean {
        var occupied:Boolean = false;
        for each (var window:NativeWindow in NativeApplication.nativeApplication.openedWindows) {
            occupied = occupied || window.bounds.intersects(testRect);
        }
        return occupied;
    }
}
}