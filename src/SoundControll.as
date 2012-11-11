package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLLoader
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import events.*;
	import subtitleThings.*;
	/**
	 * ...
	 * @author ...
	 */
	public class SoundControll extends Sprite
	{
		
		public static const MAX_SOUNDS:int = 10;
		public static const SOUNDS_VOLUME:int = 1;
		public static const _url:String = "rutrack.mp3";
		
		private var _urlObject:Object = new Object();
		private var _sounds:Object = new Object();
		private var _music:Sound = new Sound();
		private var _hasSoundDevice:Boolean = false;
		private var _fightingSoundChannel:SoundChannel;
		private var _playingFightingSound:Boolean = false;
		private var _current_sound:Sound;
		private var _current_snd_channel:SoundChannel;
		private var _current_snd_transform:SoundTransform;
		private var _current_volume:Number = 1;
		private var _position:Number = 0;
		private var _isSeeking:Boolean = false;
		private var _seekingPosition:int = 0;
		private var _isQualityChanged:Boolean = false;
		private var _soundLoadingArray:Array = [];
		
		private var _noSound:Boolean = false;
		
		//new variables
		private var _isWaiting:Boolean = false;
		private var _bytesNeedToLoad:Number;
		private var _isOnPause:Boolean = true;
		//end of new variables
		
		public function Init():void 
		{
			if (Capabilities.hasAudio && Capabilities.hasMP3) {
				_hasSoundDevice = true;
			}
			App.player_interface.addEventListener(InterfaceEvent.INTERFACE_EVENT, onInterfaceListener, false, 0, true);
			App.controller.addEventListener(ControllerEvent.EVENT, onControllerEvent, false, 0, true);
			App.controller.sound = this;
			var sndloadercontext:SoundLoaderContext = new SoundLoaderContext(5000, false);
			
		}
		
		private function onControllerEvent(e:ControllerEvent):void 
		{
			if(!_noSound) {
				_isWaiting = true;
				Pause();
				CheckIfContinue();
				return;
			}
			dispatchEvent(new ControllerEvent(ControllerEvent.SOUND_READY));
		}
		
		private function CheckIfContinue():void 
		{
			trace("check if continue");
			if (_current_sound) {
				if (((_position + 10000 < _current_sound.length) || (_current_sound.bytesTotal == _current_sound.bytesLoaded)) && _current_sound.bytesTotal != 0) {
					dispatchEvent(new ControllerEvent(ControllerEvent.SOUND_READY));
				} else {
					addEventListener(Event.ENTER_FRAME, onCheckIfReady, false, 0, true);
				}
			}
		}
		
		private function onCheckIfReady(e:Event):void 
		{
			trace("check if ready");
			if (((_position + 10000 < _current_sound.length) || (_current_sound.bytesTotal == _current_sound.bytesLoaded)) && _current_sound.bytesTotal != 0) {
				removeEventListener(Event.ENTER_FRAME, onCheckIfReady, false);
				dispatchEvent(new ControllerEvent(ControllerEvent.SOUND_READY));
			}
		}
		
		public function Resume():void {
			Play();
		}
		
		public function LoadURLS(rus:String, eng:String):void 
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
					if(!App.controller.isWaiting) {
						Play();
					}
				break;
				case "pause":
					Pause();
				break;
				case "stop":
					_current_sound.close();
				break;
				case "volume":
					changeVolume(e.object.volume as Number);
				break;
				case "sound":
					ChangeSound();
				break;
				case "seek":
					Pause();
					_isSeeking = true;
					var kf:Keyframe = e.object.seek as Keyframe;
					_position = kf.time * 1000;
					_seekingPosition = kf.time * 1000;
				break;
				case "quality":
					Pause();
					_isQualityChanged = true;
				break;
			}
		}
		
		private function SeekSoundTo(arg1:Number):void 
		{
			trace("seek sound to");
			if (_noSound) {
				return;
			}
			
			Pause();
			playSound(arg1 * 1000);
		}
		
		private function ChangeSound():void 
		{
			Pause();
			
			if (_urlObject[App.Sound] == "#") {
				_noSound = true;
				return;
			}
			playSound();
			
			var startTime:int = App.video_stream.time * 1000;
			App.goto = startTime;
			App.player_interface.ReadyToSeek();
		}
		
		/*private function onTest(e:TimerEvent):void 
		{
			if(!_current_sound.isBuffering) {
				_current_snd_channel = _current_sound.play((App.video_stream.time) * 1000, 0, _current_snd_transform);
				_current_snd_channel.soundTransform = _current_snd_transform;
				(e.target as Timer).removeEventListener(TimerEvent.TIMER, onTest, false);
				(e.target as Timer).reset();
			}
		}*/
		
		public function PlayAfterSeek():void 
		{
			trace("play after seek");
			if (_noSound) {
				return;
			}
			
			var offset:Number = (App.isCutedVideoLoaded) ? App.cutVideo_offset_seconds : 0;
			
			_current_snd_channel = _current_sound.play((App.video_stream.time) * 1000);
			_soundLoadingArray.length = 0;
		}
		
		public function SeekTo(time:int = 0):void 
		{
			trace("seek to");
			if (_noSound) {
				return;
			}
			
			Pause();
			var position:int = App.video_stream.time * 1000;
			playSound(position);
		}
		
		private function changeVolume(arg1:Number):void 
		{
			if (arg1 < 0.1) { arg1 = 0; }
			if(!_noSound) {
				_current_snd_transform.volume = arg1;
				_current_snd_channel.soundTransform = _current_snd_transform;
			} else {
				var currentsndtransfrm:SoundTransform = App.video_player.stream.soundTransform;
				currentsndtransfrm.volume = arg1;
				App.video_player.stream.soundTransform = currentsndtransfrm;
			}
		}
		
		public function Pause():void 
		{
			trace("pause");
			if (_noSound) {
				return;
			}
			
			if (_current_snd_channel) {
				if(App.video_stream && App.video_stream.time) {
					_position = App.video_stream.time * 1000;
				}
				_current_snd_channel.stop();
			}
		}
		
		public function Play():void 
		{
			if (_noSound) {
				return;
			}
			trace("play");
			//if (_current_snd_channel) {
				_current_snd_channel = _current_sound.play(_position, 0, _current_snd_transform);
			//}
		}
		
		public function muteSound():void 
		{
			if(!_noSound){
				App.video_player.stream.soundTransform = new SoundTransform(0);
			} else {
				App.video_player.stream.soundTransform = new SoundTransform(_current_volume);
			}
		}
		
		public function playSound(startingTime:int = 0):void 
		{
			trace("play sound");
			if (_urlObject[App.Sound] == "#") {
				_noSound = true;
				return;
			} 
			
			_noSound = false;
			
			var url:String = _urlObject[App.Sound];
			var urlrequest:URLRequest = new URLRequest(url);
			_current_sound = new Sound(urlrequest);
			_current_sound.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
			_current_snd_transform = new SoundTransform(_current_volume);
			if (_hasSoundDevice) {
				_current_snd_channel = _current_sound.play(startingTime, 0, _current_snd_transform);
				_current_snd_channel.soundTransform = _current_snd_transform;
			}
			_current_snd_channel.stop();
			//Pause();
		}
		
		private function onIOError(e:IOErrorEvent):void 
		{
			
		}
		
		public function get current_snd_channel():SoundChannel { return _current_snd_channel; }
		
		public function get current_sound():Sound { return _current_sound; }
	}

}