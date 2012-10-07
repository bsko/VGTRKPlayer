package  events
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author iam
	 */
	public class SubtitlesLoaded extends Event 
	{
		
		public static const SUBTITLES_LOADED:String = "subtitlesloaded";
		
		public function SubtitlesLoaded(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new SubtitlesLoaded(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("SubtitlesLoaded", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}