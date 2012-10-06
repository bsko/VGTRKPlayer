package  
{
	import flash.display.Sprite;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	/**
	 * ...
	 * @author iam
	 */
	public class VideoController extends Sprite implements PlayerInterface 
	{
		private var _video:Video = new Video();
		private var _stream:NetStream;
		private var _connection:NetConnection;
		private var _url:String = "bunny";
		private var _position:Number;
		
		private var _urlObject:Object = new Object();
		private var _urlForXmooveObject:Object = new Object();
		
		//new variables
		private var _isWaiting:Boolean = false;
		//end of new variables
		
		public function VideoController() 
		{
			//App.controller.video = this;
			
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(0x000000, 1);
			sprite.graphics.drawRect(0, 0, 613, 344);
			sprite.graphics.endFill();
			addChild(sprite);
		}
		
		public function Init():void {
			App.player_interface.addEventListener(InterfaceEvent.INTERFACE_EVENT, onInterfaceListener, false, 0, true);
			App.controller.addEventListener(ControllerEvent.EVENT, onControllerEvent, false, 0, true);
			
			_connection = new NetConnection();
            _connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            _connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			_connection.connect(null);
			
			_video.x = 0;
			_video.y = 0;
			
			_video.width = App.PLAYER_WIDTH;
			_video.height = App.PLAYER_HEIGHT;
			
			addChild(_video);
		}
		
		private function onInterfaceListener(e:InterfaceEvent):void 
		{
			if (!e.object) {
				return;
			}
			
			//trace(e.object.quality);
			
			var option:String = "";
			var length:int = Interface.EVENT_OPTIONS_ARRAY.length;
			for (var i:int = 0; i < length; i++) {
				if (e.object[Interface.EVENT_OPTIONS_ARRAY[i]]) {
					option = Interface.EVENT_OPTIONS_ARRAY[i];
					break;
				}
			}
			
			if (option == "") {
				return;
			}
			
			switch(option) {
				case "play":
					App.isPlaying = true;
					Resume();
				break;
				case "pause":
					App.isPlaying = false;
					Pause();
				break;
				case "stop":
					Stop();
				break;
				case "seek":
					//Seek(e.object.seek as Keyframe);
				break;
				case "quality":
					ChangeQualityTo(e.object.quality as Keyframe);
				break;
				case "changesoundmode":
					SeekWithoutCuttingFileTo(App.goto / 1000);
				break;
			}
		}
		
		private function netStatusHandler(e:NetStatusEvent):void 
		{
			trace(e.info.code);
			
			switch(e.info.code)
			{
				 case "NetConnection.Connect.Success":
                   // connectStream();
                    break;
                case "NetStream.Play.StreamNotFound":
                    trace("Unable to locate video");
					App.isBuffering = false;
                    break;
				case "NetStream.Buffer.Full":
					App.soundControll.PlayAfterSeek();
					App.isBuffering = false;
					/*if (App.cutVideo_isBuffering) {
						_stream.seek(App.cutVideo_offset_seconds);
					}*/
					App.cutVideo_isBuffering = false;
					App.endShowingBar = true;
					App.isNeedToSynchronize = false;
					//App.streamIsWaitingForSound = true;
					//_stream.pause();
					break;
				case "NetStream.Buffer.Empty":
					App.soundControll.Pause();
					App.isNeedToSynchronize = true;
					App.isBuffering = true;
					break;
				case "NetStream.Play.Stop":
					App.isBuffering = true;
					break;
				case "NetStream.Seek.Notify":
					App.isBuffering = true;
					break;
				case "NetStream.Play.Start":
					App.soundControll.Pause();
					App.isBuffering = false;
					break;
			}
		}
		
		private function securityErrorHandler(e:SecurityErrorEvent):void 
		{
			
		}
		
		private function onControllerEvent(e:ControllerEvent):void 
		{
			
		}
		
		public function LoadURLs(low:String, norm:String, high:String):void 
		{
			_urlObject[App.QUALITY_LOW] = low;
			_urlObject[App.QUALITY_NORM] = norm;
			_urlObject[App.QUALITY_HIGH] = high;
			
			var tmpArr:Array = low.split("/");
			tmpArr.shift();
			tmpArr.shift();
			tmpArr.shift();
			_urlForXmooveObject[App.QUALITY_LOW] = tmpArr.join("/");
			
			tmpArr = norm.split("/");
			tmpArr.shift();
			tmpArr.shift();
			tmpArr.shift();
			_urlForXmooveObject[App.QUALITY_NORM] = tmpArr.join("/");
			
			tmpArr = high.split("/");
			tmpArr.shift();
			tmpArr.shift();
			tmpArr.shift();
			_urlForXmooveObject[App.QUALITY_HIGH] = tmpArr.join("/");
		}
		
		public function Seek(delay:Number):void 
		{
			if (App.isNeedToCutFile) {
				//SeekWithCuttingFileTo(e.object.seek as Keyframe);
			} else {
				SeekWithoutCuttingFileTo((e.object.seek as Keyframe).time);
			}
		}
		
		public function Play(file:String, delay:Number):void 
		{
			
		}
		
		public function Stop():void 
		{
			
		}
		
		public function Resume():void 
		{
			_stream.resume();
		}
		
		public function ChangeVolume(val:Number):void
		{
			if (_stream) {
				if(_stream.soundTransform) {
					var currentsndtransfrm:SoundTransform = _stream.soundTransform;
					currentsndtransfrm.volume = val;
					_stream.soundTransform = currentsndtransfrm;
				}
			}
		}
		
		public function Pause():void 
		{
			_stream.pause();
		}
		
		private function ChangeQualityTo(keyframe:Keyframe):void 
		{
			if (!Main.PictureIsOnScreen)
			{
				App.isQualityChanged = true;
				App.isCutedVideoLoaded = true;
				_video.clear();
				_stream.close();
				_url = _urlObject[App.Quality];
				_stream.play(_url);
			}
		}
		
		private function MakeURL(kf:Keyframe):String 
		{
			//trace(kf.bytes, kf.time);
			if (kf != null) {
				//trace("http://vgtrk.vpn.kay-com.net/xmoov.php?file=" + String(_urlForXmooveObject[App.Quality]) + "&start=" + String(kf.bytes));
				return App.PathToXMOOVE + "?file=" + String(_urlForXmooveObject[App.Quality]) + "&start=" + String(kf.bytes);
			}
			
			var time:Number = App.cutVideo_offset_seconds;
			var offset:int = 1000;
			var totalKey:Number;
			
			var keyframe:Keyframe;
			var length:int = App.keyframesArray.length;
			var kf:Keyframe;
			for (var i:int = 0; i < length; i++ ) {
				kf = App.keyframesArray[i];
				if (time > kf.time)
				{ 
					if ((time - kf.time) < offset) 
					{
						offset = (time - kf.time);
						keyframe = kf;
					} 
				} 
				else {
					break;
				}
			} 
			
			App.cutVideo_offset_seconds = keyframe.time;
			
			var file:String = _urlForXmooveObject[App.Quality];
			
			return App.PathToXMOOVE + "?file=" + file + "&start=" + String(keyframe.bytes);
		}
		
		private function SeekWithCuttingFileTo(kf:Keyframe):void 
		{
			App.isCutedVideoLoaded = true;
			App.cutVideo_offset_seconds = kf.time;
			App.cutVideo_offset_bytes = kf.bytes;
			var string:String = MakeURL(kf);
			_stream.close();
			_stream.play(string);
			Pause();
		}
		
		private function SeekWithoutCuttingFileTo(arg:Number):void 
		{
			_stream.seek(arg);
			Pause();
		}
	}
}