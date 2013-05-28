package {
import util.DateFactory;

public class DefaultDateFactory extends DateFactory {
    private var now:Date;
    public function setCurrentDateTime(date:Date):void {
        this.now = date;
    }

    override public function getCurrentDateTime():Date {
        return now;
    }
}
}
