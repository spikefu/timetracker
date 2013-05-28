package {
import event.NotifyUserEvent;

import flexunit.framework.Assert;

import WorkLog;

public class TestStartOfDay extends BaseTest {



    [Test]
    public function isOffClockBeforeStart():void {
        var startDate:Date = messageCenter.options.startTime();
        // 5 seconds before the start of the day
        startDate.setTime(startDate.getTime() - 5*1000);
        dateFactory.setCurrentDateTime(startDate);
        messageCenter.initialize();
        messageCenter.onMessageTimer(null);
        Assert.assertFalse(this.messageCenter.onTheClock);
    }

    [Test]
    public function isOnClockAfterStart():void {
        var startDate:Date = messageCenter.options.startTime();
        // 5 seconds after the start of the day
        startDate.setTime(startDate.getTime() + 5*1000);
        dateFactory.setCurrentDateTime(startDate);
        messageCenter.initialize();
        messageCenter.onMessageTimer(null);
        Assert.assertTrue(messageCenter.onTheClock);
    }

    [Test]
    public function clockNotifyMessageIsDispatchedIfClockWasOff():void {
        var eventCatcher:GenericEventListener = new GenericEventListener();
        messageCenter.onTheClock = false;
        var startDate:Date = messageCenter.options.startTime();
        // 5 seconds after the start of the day
        startDate.setTime(startDate.getTime() + 5*1000);
        dateFactory.setCurrentDateTime(startDate);
        messageCenter.addEventListener(NotifyUserEvent.NOTIFY_USER,eventCatcher.listenForEvent);
        messageCenter.onMessageTimer(null);
        Assert.assertTrue(eventCatcher.dispatchedEvent != null);
        Assert.assertEquals(NotifyUserEvent(eventCatcher.dispatchedEvent).message,WorkLog.ON_THE_CLOCK_MESSAGE);
    }

    [Test]
    public function clockNotifyMessageIsNotDispatchedIfClockWasOn():void {
        var eventCatcher:GenericEventListener = new GenericEventListener();
        messageCenter.onTheClock = true;
        var startDate:Date = messageCenter.options.startTime();
        // 5 seconds after the start of the day
        startDate.setTime(startDate.getTime() + 5*1000);
        dateFactory.setCurrentDateTime(startDate);
        messageCenter.addEventListener(NotifyUserEvent.NOTIFY_USER,eventCatcher.listenForEvent);
        messageCenter.onMessageTimer(null);
        Assert.assertNull(eventCatcher.dispatchedEvent);
    }
}
}
