package  
{
	/**
	 * ...
	 * @author ...
	 */
	public class CustomClient 
	{
		public function onMetaData(info:Object):void
		{
			App.video_duration = info.duration;
			
			if (info.keyframes) {
				App.keyframesArray.length = 0;
				var kfObject:Object = info.keyframes;
				var timesArray:Array = kfObject["times"];
				var bytesArray:Array = kfObject["filepositions"];
				var length:int = timesArray.length;
				
				for (var i:int = 0; i < length; i++ ) {
					var kf:Keyframe = new Keyframe();
					kf.time = timesArray[i];
					kf.bytes = bytesArray[i];
					App.keyframesArray.push(kf);
				}
			} else if (info.seekpoints) {
				App.keyframesArray.length = 0;
				length = info.seekpoints.length;
				timesArray = [];
				bytesArray = [];
				for (i = 0; i < length; i++)
				{
					var tmpObj:Object = info.seekpoints[i];
					kf = new Keyframe();
					kf.time = tmpObj.time;
					kf.bytes = tmpObj.offset;
					App.keyframesArray.push(kf);
				}
			}
		}
		
		public function onCaptionInfo(info:Object):void
		{
			
		}
		
		public function onCaption(cps:String, spk:Number):void
		{
			
		}
		
		public function onLastSecond(info:Object):void
		{
			
		}
		
		public function onPlayStatus(infoObject:Object):void
		{
			
		}
	}

}