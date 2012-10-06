package  
{
	/**
	 * ...
	 * @author iam
	 */
	public class NetStreamJournal 
	{
		private var _array:Array = [];
		private var _iterator:int;
		
		public function AddEvent(event:NetStreamEvent):void
		{
			_array.push(event);
			if (_array.length > 10) {
				_array.shift();
			}
		}
		
		public function GetLastEvent():NetStreamEvent
		{
			return _array[_array.length - 1];
		}
		
		public function GetEvent(a:int):NetStreamEvent
		{
			if (a > 0 && a < _array.length) {
				return _array[a];
			}
			else {
				return null;
			}
		}
		
		public function GetLength():int
		{
			return _array.length;
		}
	}

}