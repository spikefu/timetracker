package {
import flash.events.Event;

public class GenericEventListener {
    public var dispatchedEvent:Event;

    public function listenForEvent(event:Event):void {
        this.dispatchedEvent = event;
    }
}
}
