package  
{
	import flash.display.Sprite;
	import events.*;
	import subtitleThings.*;
	/**
	 * ...
	 * @author iam
	 */
	public class Controller extends Sprite
	{
		
		private var _video:VideoPlayer;
		private var _sound:SoundControll;
		private var _videoReady:Boolean = true;
		private var _soundReady:Boolean = true;
		private var _isWaiting:Boolean = false;
		
		public function Controller() 
		{
			
		}
		
		public function Init():void 
		{
			_videoReady = false;
			_soundReady = false;
			trace("INIT");
			_video.addEventListener(ControllerEvent.VIDEO_READY, onVideoReadyEvent, false, 0, true);
			_sound.addEventListener(ControllerEvent.SOUND_READY, onSoundReadyEvent, false, 0, true);
			dispatchEvent(new ControllerEvent(ControllerEvent.EVENT, false, false));
		}
		
		private function onSoundReadyEvent(e:ControllerEvent):void 
		{
			trace("SOUND READY");
			_soundReady = true;
			checkIfBothReady();
			_sound.removeEventListener(ControllerEvent.SOUND_READY, onSoundReadyEvent, false);
		}
		
		private function onVideoReadyEvent(e:ControllerEvent):void 
		{
			trace("VIDEO READY");
			_videoReady = true;
			checkIfBothReady();
			_video.removeEventListener(ControllerEvent.VIDEO_READY, onSoundReadyEvent, false);
		}
		
		private function checkIfBothReady():void 
		{
			if (_videoReady && _soundReady) {
				ResumePlaying();
			}
		}
		
		private function ResumePlaying():void 
		{
			_isWaiting = false;
			_videoReady = true;
			_soundReady = true;
			
			_video.Resume();
			_sound.Resume();
		}
		
		public function get video():VideoPlayer { return _video; }
		
		public function set video(value:VideoPlayer):void 
		{
			_video = value;
		}
		
		public function get sound():SoundControll { return _sound; }
		
		public function set sound(value:SoundControll):void 
		{
			_sound = value;
		}
		
		public function get isWaiting():Boolean { return _isWaiting; }
	}
}