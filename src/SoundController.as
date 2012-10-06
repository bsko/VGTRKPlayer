package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author iam
	 */
	public class SoundController extends Sprite implements PlayerInterface
	{
		public static const MAX_SOUNDS:int = 10;
		public static const SOUNDS_VOLUME:int = 1;
		
		public static const _url:String = "rutrack.mp3";
		
		private var _urlObject:Object = new Object();
		private var _sounds:Object = new Object();
		
		private var _current_sound:Sound;
		private var _current_snd_channel:SoundChannel;
		private var _current_snd_transform:SoundTransform;
		
		private var _current_volume:Number = SOUNDS_VOLUME;
		private var _position:Number = 0;
		
		private var _seekingPosition:int = 0;
		private var _soundLoadingArray:Array = [];
		
		private var _noSound:Boolean = false;
		
		//new variables
		private var _isWaiting:Boolean = false;
		private var _bytesNeedToLoad:Number;
		private var _isOnPause:Boolean = true;
		//end of new variables
		
		public function SoundController() 
		{
			//App.controller.sound = this;
		}
		
		public function Init():void {
			App.player_interface.addEventListener(InterfaceEvent.INTERFACE_EVENT, onInterfaceListener, false, 0, true);
			App.controller.addEventListener(ControllerEvent.EVENT, onControllerEvent, false, 0, true);
		}
		
		private function onControllerEvent(e:ControllerEvent):void 
		{
			if(_noSound) {
				if (!_isWaiting) {
					_isWaiting = true;
					Pause();
					CheckIfContinue();
					return;
				}
			}
			
			dispatchEvent(new ControllerEvent(ControllerEvent.SOUND_READY));
		}
		
		private function CheckIfContinue():void 
		{
			if (_current_sound) {
				var neededPosition:Number;
				if (_position + 10000 < _current_sound.length) {
					neededPosition = _position + 10000;
				} else {
					neededPosition = _current_sound.length;
				}
				var part:Number = neededPosition / _current_sound.length;
				_bytesNeedToLoad = part * _current_sound.bytesTotal;
				if (_bytesNeedToLoad < _current_sound.bytesLoaded) {
					addEventListener(Event.ENTER_FRAME, onCheckIfReady, false, 0, true);
				}
			}
		}
		
		private function onCheckIfReady(e:Event):void 
		{
			if (_bytesNeedToLoad >= _current_sound.bytesLoaded) {
				removeEventListener(Event.ENTER_FRAME, onCheckIfReady, false);
				dispatchEvent(new ControllerEvent(ControllerEvent.SOUND_READY));
			}
		}
		
		public function LoadURLs(rus:String, eng:String):void
		{
			_urlObject[App.SOUND_RUS] = rus;
			_urlObject[App.SOUND_ENG] = eng;
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
				}
			}
			
			if (option == "") {
				return;
			}
			
			switch(option) {
				case "play":
					Resume();
				break;
				case "pause":
					Pause();
				break;
				case "stop":
					Stop();
				break;
				case "volume":
					ChangeVolume(e.object.volume as Number);
				break;
				case "sound":
					ChangeSound();
				break;
				case "seek":
					Seek((e.object.seek as Number) * 1000);
				break;
			}
		}
		
		private function ChangeSound():void 
		{
			
		}
		
		public function Seek(delay:Number):void 
		{
			
		}
		
		public function Play(file:String, delay:Number):void 
		{
			if (_urlObject[App.Sound] == "#") {
				_noSound = true;
				App.videoController.ChangeVolume(_current_volume);
			} else {
				_noSound = false;
				
				App.videoController.ChangeVolume(0);
				var url:String = _urlObject[App.Sound];
				var urlrequest:URLRequest = new URLRequest(url);
				_current_sound = new Sound(urlrequest);
				_current_sound.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
				_current_snd_transform = new SoundTransform(_current_volume);
				_current_snd_channel = _current_sound.play(delay, 0, _current_snd_transform);
				_current_snd_channel.soundTransform = _current_snd_transform;
				_isOnPause = false;
				Pause();
			}
		}
		
		private function onIOError(e:IOErrorEvent):void 
		{
			trace(e);
		}
		
		public function Stop():void 
		{
			if (_current_sound) {
				_current_sound.close();
			}
		}
		
		public function Resume():void 
		{
			if (_noSound) {
				return;
			}
			if(_isOnPause) {
				if (_current_snd_channel) {
					_current_snd_channel = _current_sound.play(_position, 0, _current_snd_transform);
				}
				_isOnPause = false;
			}
		}
		
		public function ChangeVolume(val:Number):void
		{
			if (val < 0.1) { val = 0; }
			if(!_noSound) {
				_current_snd_transform.volume = val;
				_current_snd_channel.soundTransform = _current_snd_transform;
			} else {
				App.videoController.ChangeVolume(val);
			}
		}
		
		public function Pause():void 
		{
			if (_noSound) {
				return;
			}
			if(!_isOnPause) {
				if (_current_snd_channel) {
					if(App.video_stream && App.video_stream.time) {
						_position = App.video_stream.time * 1000;
					}
					_current_snd_channel.stop();
				}
				_isOnPause = true;
			}
		}
		
	}

}