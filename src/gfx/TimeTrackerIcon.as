package gfx
{
    import flash.desktop.Icon;
    import flash.display.Loader;
    import flash.events.Event;
import flash.filters.BitmapFilter;
import flash.net.URLRequest;
      
    public class TimeTrackerIcon extends Icon
    {		
		private var imageURLs:Array = ['gfx/TimeTrackerIcon_16.png','gfx/TimeTrackerIcon_32.png',
										'gfx/TimeTrackerIcon_48.png','gfx/TimeTrackerIcon_128.png'];

        public var onTheClock:Boolean = false;

        private var filter:BitmapFilter

        public function TimeTrackerIcon(onTheClock:Boolean):void{
            super();
            this.onTheClock = onTheClock;
            bitmaps = new Array();
        }
        
        public function loadImages(event:Event = null):void{
        	if(event != null){
        		bitmaps.push(event.target.content.bitmapData);
        	}
        	if(imageURLs.length > 0){
        		var urlString:String = imageURLs.pop();
        		var loader:Loader = new Loader();
        		loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadImages,false,0,true);
				loader.load(new URLRequest(urlString));
        	} else {
        		var complete:Event = new Event(Event.COMPLETE,false,false);
        		dispatchEvent(complete);
        	}
        }
    }
}