package  subtitleThings
{
	import events.SubtitlesLoaded;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import subtitleThings.Subtitle;
	/**
	 * ...
	 * @author iam
	 */
	public class SubtitleLoader extends Sprite
	{
		
		public static const DEFAULT_PATH:String = "subtitles.srt";
		private var _urlLoader:URLLoader;
		private var _language:String;
		private var _rusSubsURL:String;
		private var _engSubsURL:String;
		
		public function SubtitleLoader() 
		{
			
		}
		
		public function Init():void
		{
			
		}
		
		public function LoadAllSubtitles(rusSubs:String, engSubs:String):void
		{
			_rusSubsURL = rusSubs;
			_engSubsURL = engSubs;
			var timer:Timer = new Timer(2000);
			timer.start();
			timer.addEventListener(TimerEvent.TIMER, onSecure, false, 0, true);
		}
		
		private function onSecure(e:TimerEvent):void 
		{
			(e.target as Timer).reset();
			(e.target as Timer).removeEventListener(TimerEvent.TIMER, onSecure, false);
			
			if (_rusSubsURL != "#") {
				LoadSubtitles(_rusSubsURL, "rus");
			} else if (_engSubsURL != "#") {
				LoadSubtitles(_engSubsURL, "eng");
			}
		}
		
		public function LoadSubtitles(url:String = DEFAULT_PATH, language:String = "rus"):void
		{
			var urlRequest:URLRequest = new URLRequest(url);
			_language = language;
			_urlLoader = new URLLoader(urlRequest);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError, false, 0, true);
			_urlLoader.addEventListener(Event.COMPLETE, onCompleteReading, false, 0, true);
		}
		
		private function onError(e:IOErrorEvent):void 
		{	
			if ((_language == "rus") && (_engSubsURL != "#")) {
				LoadSubtitles(_engSubsURL, "eng");
			} else if (_language == "eng") {
				dispatchEvent(new SubtitlesLoaded(SubtitlesLoaded.SUBTITLES_LOADED));
			}
		}
		
		private function onCompleteReading(e:Event):void 
		{
			var subtitles:String = _urlLoader.data as String;
			var array:Array = subtitles.split("\n");
			var true_array:Array = [];
			var tmpArr:Array = [];
			var tmpString:String = "";
			var length:int = array.length;
			for (var i:int = 0; i < length; i++)
			{
				if ((String(array[i]).length == 1) && (int(array[i]) == 0)) {
					
					if (tmpString != "" && tmpString.length > 1) {
						tmpArr = tmpString.split("<-->");
						var count:int = int(tmpArr[0]);
						var time:String = tmpArr[1];
						var text:String = "";
						for (var j:int = 2; j < tmpArr.length - 1; j++)
						{
							text += tmpArr[j];
						}
						var startTime:int = convertTextToTime(time.split("-->")[0]);
						var endTime:int = convertTextToTime(time.split("-->")[1]);
						
						var subtitle:Subtitle = new Subtitle(count, startTime, endTime, text)
						true_array.push(subtitle);
					}
					
					tmpString = "";
				} else {
					tmpString += array[i];
					tmpString += "<-->";
				}
			}
			App.player_interface.subtitlesObject[_language] = true_array;
			if ((_language == "rus") && (_engSubsURL != "#")) {
				LoadSubtitles(_engSubsURL, "eng");
			} else if (_language == "eng") {
				dispatchEvent(new SubtitlesLoaded(SubtitlesLoaded.SUBTITLES_LOADED));
			} else if ((_language == "rus") && (_engSubsURL == "#")) {
				dispatchEvent(new SubtitlesLoaded(SubtitlesLoaded.SUBTITLES_LOADED));
			}
		}
		
		private function convertTextToTime(arg1:String):int 
		{
			var time:int = 0;
			var array:Array = arg1.split(":");
			var tmpseconds:String = array[2];
			var qseconds:int = int(tmpseconds.split(",")[1]) + int(tmpseconds.split(",")[0]) * 1000;
			var seconds:int = qseconds + int(array[1]) * 1000 * 60 + int(array[0]) * 60 * 60 * 1000;
			return seconds;
		}
	}

}