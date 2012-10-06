package SubtitleThings 
{
	/**
	 * ...
	 * @author iam
	 */
	public class Subtitle 
	{
		private var _count:int;
		private var _startTime:int;
		private var _endTime:int;
		private var _text:String;
		
		public function Subtitle(count_:int, startTime_:int, endTime_:int, text_:String)
		{
			_count = count_;
			_startTime = startTime_;
			_endTime = endTime_;
			_text = text_;
		}
		
		public function get count():int { return _count; }
		
		public function get startTime():int { return _startTime; }
		
		public function get endTime():int { return _endTime; }
		
		public function get text():String { return _text; }
		
	}

}