package  events
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author iam
	 */
	public class InterfaceEvent extends Event 
	{
		public static const INTERFACE_EVENT:String = "interfaceevent";
		
		private var _object:Object;
		
		
		public function InterfaceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, options:Object = null) 
		{ 
			super(type, bubbles, cancelable);
			_object = options;
		} 
		
		public override function clone():Event 
		{ 
			return new InterfaceEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("InterfaceEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get object():Object { return _object; }
		
	}
	
}