package  
{
	/**
	 * ...
	 * @author iam
	 */
	public class NetStreamEvent 
	{
		private var _startTime:int;
		private var _type:String;
		
		public function NetStreamEvent(start:int, text:String) 
		{
			startTime = start;
			type = text;
		}
		
		public function get startTime():int { return _startTime; }
		
		public function set startTime(value:int):void 
		{
			_startTime = value;
		}
		
		public function get type():String { return _type; }
		
		public function set type(value:String):void 
		{
			_type = value;
		}
		
	}

}