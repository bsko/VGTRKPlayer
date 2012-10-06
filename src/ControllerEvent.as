package  
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author iam
	 */
	public class ControllerEvent extends Event 
	{
		
		public static const EVENT:String = "controllerevent";
		public static const VIDEO_READY:String = "videoready";
		public static const SOUND_READY:String = "soundready";
		
		public function ControllerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new ControllerEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ControllerEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}