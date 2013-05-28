package {
import event.NotifyUserEvent;

import flexunit.framework.Assert;

import WorkLog;

import mx.controls.Tree;

public class TestEndOfDay extends BaseTest {

    [Test]
    public function clockIsOnBeforeEnd():void {
        var endDate:Date = messageCenter.options.endTime();
        // 5 seconds before the end of the day
        endDate.setTime(endDate.getTime() - 5*1000);
        dateFactory.setCurrentDateTime(endDate);
        messageCenter.initialize();
        messageCenter.onMessageTimer(null);
        Assert.assertTrue(this.messageCenter.onTheClock);
    }

    [Test]
    public function clockIsOffAfterEnd():void {
        var endDate:Date = messageCenter.options.endTime();
        // 5 seconds after the end of the day
        endDate.setTime(endDate.getTime() + 5*1000);
        dateFactory.setCurrentDateTime(endDate);
        messageCenter.initialize();
        messageCenter.onMessageTimer(null);
        Assert.assertFalse(messageCenter.onTheClock);
    }

    [Test]
    public function clockNotifyMessageIsNotDispatchedIfClockWasOff():void {
        var tree:Tree
        var eventCatcher:GenericEventListener = new GenericEventListener();
        messageCenter.onTheClock = false;
        var endDate:Date = messageCenter.options.endTime();
        // 5 seconds after the end of the day
        endDate.setTime(endDate.getTime() + 5*1000);
        dateFactory.setCurrentDateTime(endDate);
        messageCenter.addEventListener(NotifyUserEvent.NOTIFY_USER,eventCatcher.listenForEvent);
        messageCenter.onMessageTimer(null);
        Assert.assertNull(eventCatcher.dispatchedEvent);
    }

    [Test]
    public function clockNotifyMessageIsDispatchedIfClockWasOn():void {
        var eventCatcher:GenericEventListener = new GenericEventListener();
        messageCenter.onTheClock = true;
        var endDate:Date = messageCenter.options.endTime();
        // 5 seconds after the end of the day
        endDate.setTime(endDate.getTime() + 5*1000);
        dateFactory.setCurrentDateTime(endDate);
        messageCenter.addEventListener(NotifyUserEvent.NOTIFY_USER,eventCatcher.listenForEvent);
        messageCenter.onMessageTimer(null);
        Assert.assertNotNull(eventCatcher.dispatchedEvent);
        Assert.assertEquals(NotifyUserEvent(eventCatcher.dispatchedEvent).message,WorkLog.OFF_THE_CLOCK_MESSAGE);
    }
}
}
