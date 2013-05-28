package {
import display.DisplayManager;
import event.NotifyUserEvent;
import event.WorkLogEvent;

import flash.desktop.DockIcon;
import flash.desktop.NativeApplication;
import flash.desktop.SystemTrayIcon;
import flash.display.NativeMenu;
import flash.display.NativeMenuItem;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import gfx.TimeTrackerIcon;

import WorkLog;
import model.TimeTrackerOptions;

import util.DateFactory;


public class TimeTracker extends Sprite {
    private var displayManager:DisplayManager;
    private var workLog:WorkLog;
    private var options:TimeTrackerOptions;
    private var icon:TimeTrackerIcon;

    private var iconMenu:NativeMenu;

    private var offTheClockItem:NativeMenuItem;

    private var onTheClockItem:NativeMenuItem;

    public function TimeTracker() {
        var dateFactory:DateFactory = new DateFactory();
        options = new TimeTrackerOptions(dateFactory);
        workLog = new WorkLog(options,dateFactory);
        displayManager = new DisplayManager(workLog);

        workLog.addEventListener(WorkLogEvent.CAPTURE_WORK_LOG, captureLog);
        workLog.addEventListener(WorkLog.CLOCK_IS_ON, updateClockMenuItem);
        workLog.addEventListener(WorkLog.CLOCK_IS_OFF, updateClockMenuItem);

        displayManager.addEventListener(WorkLogEvent.SAVE_WORK_LOG, workLog.recordWorkLog);
        workLog.addEventListener(NotifyUserEvent.NOTIFY_USER, displayManager.notifyUser);

        //Add a tooltip and menu to the system tray icon
        iconMenu = new NativeMenu();


        addMenuItem(iconMenu, "Help",help);
        addMenuItem(iconMenu, "TimeTracker ver." + getAppVersion());
        addMenuItem(iconMenu, "Exit TimeTracker", quit);
        addMenuSeparator(iconMenu);
        addMenuItem(iconMenu, "Options", showOptions);
        offTheClockItem = addMenuItem(iconMenu, "Go off the clock", goOffTheClock);
        onTheClockItem = addMenuItem(iconMenu, "Go on the clock", goOnTheClock);
        addMenuItem(iconMenu, "Show main window", showMainWindow);

        workLog.initialize();


        icon.addEventListener(Event.COMPLETE, function ():void {
            NativeApplication.nativeApplication.icon.bitmaps = icon.bitmaps;
        });
        icon.loadImages();

        if (NativeApplication.supportsSystemTrayIcon) {
            var sysTray:SystemTrayIcon = NativeApplication.nativeApplication.icon as SystemTrayIcon;
            sysTray.tooltip = "TimeTracker";
            sysTray.menu = iconMenu;
            sysTray.addEventListener(MouseEvent.CLICK, workLog.messageNow);
        }
        if (NativeApplication.supportsDockIcon) {
            DockIcon(NativeApplication.nativeApplication.icon).menu = iconMenu;
            DockIcon(NativeApplication.nativeApplication.icon).addEventListener(MouseEvent.CLICK, workLog.messageNow);
        }


        NativeApplication.nativeApplication.autoExit = false;
        stage.nativeWindow.close();
    }

    private function help(event:Event):void {
        navigateToURL(new URLRequest("https://www.assembla.com/spaces/yellowbadger_timetracker/wiki"));
    }

    private function getAppVersion():String {
        var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
        var ns:Namespace = appXml.namespace();
        var appVersion:String = appXml.ns::versionNumber[0].toString();
        return appVersion;
    }

    private function addMenuItem(menu:NativeMenu, label:String, selectHandler:Function = null):NativeMenuItem {
        var menuItem:NativeMenuItem =
                menu.addItem(new NativeMenuItem(label));
        if (selectHandler != null) {
            menuItem.addEventListener(Event.SELECT, selectHandler);
        }
        return menuItem;
    }

    private function addMenuSeparator(menu:NativeMenu):void {
        menu.addItem(new NativeMenuItem("", true));
    }

    private function updateClockMenuItem(evt:Event = null, onTheclock:Boolean = false):void {
        if (evt != null) {
            if (evt.type == WorkLog.CLOCK_IS_OFF) {
                onTheclock = false;
            } else {
                onTheclock = true;
            }
        }
        var idx:int;
        if (onTheclock) {
            if (iconMenu.containsItem(onTheClockItem)) {
                idx = iconMenu.getItemIndex(onTheClockItem);
                iconMenu.removeItem(onTheClockItem);
                if (!iconMenu.containsItem(offTheClockItem)) {
                    iconMenu.addItemAt(offTheClockItem, idx);
                }
            }
            this.icon = new TimeTrackerIcon(true);
        } else {
            if (iconMenu.containsItem(offTheClockItem)) {
                idx = iconMenu.getItemIndex(offTheClockItem);
                iconMenu.removeItem(offTheClockItem);
                if (!iconMenu.containsItem(onTheClockItem)) {
                    iconMenu.addItemAt(onTheClockItem, idx);
                }
            }
            this.icon = new TimeTrackerIcon(false);
        }
    }



    private function notifyUser(evt:Event):void {
        var event:NotifyUserEvent = new NotifyUserEvent("test");
        workLog.dispatchEvent(event);
    }

    private function quit(event:Event):void {
        NativeApplication.nativeApplication.exit();
    }

    private function showMainWindow(event:Event):void {
        displayManager.showMainWindow(workLog);
    }

    private function showOptions(event:Event):void {
        displayManager.showOptions(workLog);
    }

    private function goOffTheClock(event:Event):void {
        workLog.clockOff();
        updateClockMenuItem(null,false);
    }

    private function goOnTheClock(event:Event):void {
        workLog.clockOn();
        updateClockMenuItem(null,true);
    }

    private function captureLog(event:WorkLogEvent):void {
        displayManager.showLogCaptureWindow(event);
        if (NativeApplication.supportsDockIcon) {
            DockIcon(NativeApplication.nativeApplication.icon).bounce();
        }
    }


}
}
