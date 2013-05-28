package {

import flexunit.framework.Assert;

import WorkLog;
import model.TimeTrackerOptions;

public class BaseTest {

    protected var messageCenter:WorkLog;
    protected var dateFactory:DefaultDateFactory;

    [Before]
    public function setup():void {
        dateFactory = new DefaultDateFactory();
        dateFactory.setCurrentDateTime(new Date());
        var options:TimeTrackerOptions = new DefaultTimeTrackerOptions(dateFactory);
        messageCenter = new WorkLog(options, dateFactory);
        messageCenter.initialize();
    }

}
}
