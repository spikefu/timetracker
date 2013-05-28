package event {
import flash.events.Event;

import mx.formatters.DateFormatter;

public class NotifyUserEvent extends Event {
    public static const NOTIFY_USER:String = "notifyUser";
    public var message:String;

    public function NotifyUserEvent(message:String) {
        super(NOTIFY_USER);
        this.message = message;
    }

    override public function clone():Event {
        return new NotifyUserEvent(this.message);
    }

}
}
