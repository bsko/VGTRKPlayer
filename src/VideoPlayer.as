package  
{
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import events.*;
	import subtitleThings.*;
	/**
	 * ...
	 * @author ...
	 */
	public class VideoPlayer extends Sprite
	{
		private var _video:Video = new Video();
		private var _stream:NetStream;
		private var _connection:NetConnection;
		
		private var _url:String = "bunny";
		private var _position:Number;
		
		private var _urlObject:Object = new Object();
		
		private var _seeking:Boolean = false;
		
		public function VideoPlayer() 
		{
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(0x000000, 1);
			sprite.graphics.drawRect(0, 0, App.PLAYER_WIDTH, App.PLAYER_HEIGHT);
			sprite.graphics.endFill();
			addChild(sprite);
		}
		
		public function Init():void 
		{
			App.controller.video = this;
			App.player_interface.addEventListener(InterfaceEvent.INTERFACE_EVENT, onInterfaceListener, false, 0, true);
			App.controller.addEventListener(ControllerEvent.EVENT, onControllerEvent, false, 0, true);
			
			_connection = new NetConnection();
            _connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            _connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			if (_urlObject[App.RTMP_CONNECTION_URL] != null) {
				_connection.connect(_urlObject[App.RTMP_CONNECTION_URL]);
			} else {
				_connection.connect(null);
			}
			_connection.client = { onBWDone: function():void { } };
			
			_video.x = 0;
			_video.y = 0;
			
			_video.width = App.PLAYER_WIDTH;
			_video.height = App.PLAYER_HEIGHT;
			
			addChild(_video);
		}
		
		private function onControllerEvent(e:ControllerEvent):void 
		{
			dispatchEvent(new ControllerEvent(ControllerEvent.VIDEO_READY));
		}
		
		public function Resume():void {
			if(_stream != null) {
				App.isPlaying = true;
				_stream.resume();
			}
		}
		
		public function LoadURLs(low:String, norm:String, high:String, rtmp:String):void 
		{
			trace(low.lastIndexOf("mp4"));
			if (low.lastIndexOf("mp4") == 0) {
				low += ".mp4";
			}
			trace(low);
			_urlObject[App.QUALITY_LOW] = low;
			_urlObject[App.QUALITY_NORM] = norm;
			_urlObject[App.QUALITY_HIGH] = high;
			_urlObject[App.RTMP_CONNECTION_URL] = rtmp;
		}
		
		private function onInterfaceListener(e:InterfaceEvent):void 
		{
			if (!e.object) {
				return;
			}
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
					if(!App.controller.isWaiting) {
						Resume();
					}
				break;
				case "pause":
					App.isPlaying = false;
					_stream.pause();
				break;
				case "stop":
					
				break;
			case "seek":
					SeekWithoutCuttingFileTo((e.object.seek as Keyframe).time);
				break;
				case "quality":
					ChangeQualityTo(e.object.quality as Number);
				break;
				case "changesoundmode":
					SeekWithoutCuttingFileTo(App.goto / 1000);
					var timer:Timer = new Timer(500);
					timer.start();
					timer.addEventListener(TimerEvent.TIMER, onSynchronize, false, 0, true);
					
				break;
			}
		}
		
		private function onSynchronize(e:TimerEvent):void 
		{
			App.soundControll.SeekTo();
			(e.target as Timer).removeEventListener(TimerEvent.TIMER, onSynchronize, false);
			(e.target as Timer).reset();
		}
		
		private function ChangeQualityTo(offsetTo:Number):void 
		{
			if (!Main.PictureIsOnScreen)
			{
				App.isQualityChanged = true;
				_url = _urlObject[App.Quality];
				_stream.play(_url);
				var time:Number = offsetTo;
				var offset:int = 1000;
				
				var keyframe:Keyframe;
				var length:int = App.keyframesArray.length;
				var kf:Keyframe;
				
				for (var i:int = 0; i < length; i++ ) {
					kf = App.keyframesArray[i];
					if (time > kf.time)	{ 
						if ((time - kf.time) < offset) {
							offset = (time - kf.time);
							keyframe = kf;
						} 
					} 
					else {
						break;
					}
				}
				if (!keyframe) { keyframe = App.keyframesArray[0]; }
				if (!keyframe) { keyframe = new Keyframe(); keyframe.time = offsetTo; }
				_stream.seek(keyframe.time);
			}
		}
		
		private function SeekWithoutCuttingFileTo(arg:Number):void 
		{
			trace(arg);
			_stream.seek(arg);
			_stream.pause();
		}
		
		private function netStatusHandler(e:NetStatusEvent):void 
		{
			trace(e.info.code);
			
			switch(e.info.code)
			{
				 case "NetConnection.Connect.Success":
                    connectStream();
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
				case "NetStream.Buffer.Flush":
					App.isBuffering = true;
					break;
				case "NetStream.Play.Stop":
					App.isBuffering = true;
					break;
				case "NetStream.Seek.Notify":
					App.isBuffering = true;
					break;
				case "NetStream.Play.Start":
					App.soundControll.muteSound();
					App.soundControll.Pause();
					App.isBuffering = false;
					break;
			}
		}
		
		public function soundLoadedResumeStream():void
		{
			if (App.streamIsWaitingForSound)
			{
				App.streamIsWaitingForSound = false;
				_stream.resume();
			}
		}
		
		private function connectStream():void 
		{
			_stream = new NetStream(_connection);
			_stream.client = new CustomClient();
            _stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            _stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
            _video.attachNetStream(_stream);
			
			if(!Main.PictureIsOnScreen) {
				var url:String = _urlObject[App.Quality];
				_stream.play(url);
				_stream.soundTransform = new SoundTransform(0);
				App.video_stream = _stream;
				_stream.bufferTime = 5;
				
				_video.width = App.PLAYER_WIDTH;
				_video.height = App.PLAYER_HEIGHT;
				
				_stream.pause();
			}
		}
		
		public function startPlayingStreamAfterPicture():void 
		{
			if (Main.PictureIsOnScreen) 
			{
				var url:String = _urlObject[App.Quality];
				
				_stream.play(url);
				_stream.soundTransform = new SoundTransform(0);
				App.video_stream = _stream;
				_stream.bufferTime = 5;
				App.isPlaying = true;
				App.player_interface.UpdatePlayButton();
				_video.width = App.PLAYER_WIDTH;
				_video.height = App.PLAYER_HEIGHT;
				_stream.pause();
			}
		}
		
		private function asyncErrorHandler(e:AsyncErrorEvent):void 
		{
			
		}
		
		private function securityErrorHandler(e:SecurityErrorEvent):void 
		{
			
		}
		
		public function get seeking():Boolean { return _seeking; }
		
		public function set seeking(value:Boolean):void 
		{
			_seeking = value;
		}
		
		public function get connection():NetConnection { return _connection; }
		
		public function get video():Video { return _video; }
		
		public function get stream():NetStream { return _stream; }
	}
}