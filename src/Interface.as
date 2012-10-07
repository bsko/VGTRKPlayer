package  
{
	import events.*;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.Timer;
	import subtitleThings.*;
	/**
	 * ...
	 * @author ...
	 */
	public class Interface extends Sprite
	{
		public static const EVENT_OPTIONS_ARRAY:Array = [ "play", "pause", "stop", "changeScreenState", "volume", "seek", "quality", "sound", "changesoundmode"];
		public static const BAR_WIDTH:int = 378;
		public static const LONG_BAR_WIDTH:int = 800;
		public static const ANIMATION_LENGTH:int = 40;
		
		private var _interface:MovieClip = new InterfaceMC();
		
		private var _playpauseBtn:MovieClip;
		private var _fullscreenBtn:SimpleButton;
		private var _soundBar:MovieClip;
		private var _seekBar:MovieClip;
		
		private var _sub_ru:MovieClip;
		private var _sub_en:MovieClip;
		private var _sub_off:MovieClip;
		
		private var _sound_ru:MovieClip;
		private var _sound_en:MovieClip;
		
		private var _lowQuality:MovieClip;
		private var _normQuality:MovieClip;
		private var _highQuality:MovieClip;
		
		private var _subtitlesObject:Object = new Object();
		private var _currentSubtitleArray:Array = [];
		private var _subtitle:Subtitle;
		private var _subtitleIndex:int = 0;
		private var _subtitleTextField:TextField;
		private var _subtitlesShowing:Boolean = false;
		private var _subtitleChanged:Boolean = false;
		private var _watermark:TextField;
		private var _watermarkText:String = "WATERMARK";
		private var _volume:Number = 1;
		private var _bufferingBar:MovieClip;
		private var _upperMask:MovieClip = new UpperMask();
		private var _isAnimating:Boolean = false;
		private var _changingVolume:Boolean = false;
		private var _currentTimeTF:TextField;
		private var _totalTimeTF:TextField;
		
		private var _draggedDown:Boolean = false;
		private var _fs_dragmenu_timer:Timer = new Timer(2000);
		
		public function Interface() 
		{	
			_interface.gotoAndStop("window");
			_bufferingBar = _interface.bufferingbar;
			_playpauseBtn = _interface.bottom_w_mc.playpauseBtn;
			_playpauseBtn.gotoAndStop("play");
			_fullscreenBtn = _interface.bottom_w_mc.fullscreenButton;
			_soundBar = _interface.bottom_w_mc.soundBtn;
			_soundBar.gotoAndStop(7);
			_seekBar = _interface.bottom_w_mc.seekbutton;
			_seekBar.buttonMode = true;
			_seekBar.sub.gotoAndStop(1);
			_subtitleTextField = _interface.subtitles;
			_subtitleTextField.selectable = false;
			_subtitleTextField.htmlText = "";
			_watermark = _interface.centertext.text;
			_currentTimeTF = _interface.bottom_w_mc.currentTime;
			_totalTimeTF = _interface.bottom_w_mc.totalTime;
			_currentTimeTF.mouseEnabled = false;
			_totalTimeTF.mouseEnabled = false;
			
			if (App.LANGUAGE == App.ENG) {
				App.Subtitles = App.SUBS_ENG;
				App.Sound = App.SOUND_ENG;
			} else {
				App.Subtitles = App.SUBS_RUS;
				App.Sound = App.SOUND_RUS;
			}
			
			_sub_ru = _interface.sub_ru;
			_sub_ru.addEventListener(MouseEvent.CLICK, onChangeSubtitles, false, 0, true);
			_sub_en = _interface.sub_en;
			_sub_en.addEventListener(MouseEvent.CLICK, onChangeSubtitles, false, 0, true);
			_sub_off = _interface.sub_off;
			_sub_off.addEventListener(MouseEvent.CLICK, onChangeSubtitles, false, 0, true);
			_sound_ru = _interface.sound_ru;
			_sound_ru.addEventListener(MouseEvent.CLICK, onChangeSound, false, 0, true);
			_sound_en = _interface.sound_en;
			_sound_en.addEventListener(MouseEvent.CLICK, onChangeSound, false, 0, true);
			
			App.Quality = App.QUALITY_LOW;
			_lowQuality = _interface.lowquality;
			_lowQuality.addEventListener(MouseEvent.CLICK, onChangeQuality, false, 0, true);
			_normQuality = _interface.normquality;
			_normQuality.addEventListener(MouseEvent.CLICK, onChangeQuality, false, 0, true);
			_highQuality = _interface.highquality;
			_highQuality.addEventListener(MouseEvent.CLICK, onChangeQuality, false, 0, true);
			
			UpdateButtons();
			
			_interface.width = 613;
			_interface.height = 342;
			
			addChild(_upperMask);
			addChild(_interface);
			
			_upperMask.alpha = 0.01;
			_upperMask.visible = false;
			
			addEventListener(MouseEvent.MOUSE_MOVE, onCheckIfDragMenuDown, false, 0, true);
			_fs_dragmenu_timer.start();
			_fs_dragmenu_timer.addEventListener(TimerEvent.TIMER, onDragDown, false, 0, true);
		}
		
		public function Init():void 
		{
			_playpauseBtn.addEventListener(MouseEvent.CLICK, onPlayPause, false, 0, true);
			_soundBar.addEventListener(MouseEvent.MOUSE_DOWN, onChangeVolume, false, 0, true);
			App.stage.addEventListener(MouseEvent.MOUSE_UP, onStopChangeVolume, false, 0, true);
			_fullscreenBtn.addEventListener(MouseEvent.CLICK, onChangeScreenMode, false, 0, true);
			_seekBar.addEventListener(MouseEvent.CLICK, onSeek, false, 0, true);
			_seekBar.addEventListener(Event.ENTER_FRAME, onUpdateSeek, false, 0, true);
			App.subtitleLoader.addEventListener(SubtitlesLoaded.SUBTITLES_LOADED, onStartSubtitles, false, 0, true);
			App.stage.addEventListener(FullScreenEvent.FULL_SCREEN, onUpdateInterfaceByScreenMode, false, 0, true);
			addEventListener(Event.ENTER_FRAME, onUpdateBufferingMovie, false, 0, true);
		}
		
		private function onStopChangeVolume(e:MouseEvent = null):void 
		{
			if (_changingVolume) {
				App.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDragAndDropChangingVolume, false);
				_changingVolume = false;
			}
		}
		
		private function onDragAndDropChangingVolume(e:MouseEvent):void 
		{
			if(App.stage.displayState == StageDisplayState.NORMAL) {
				if (mouseX > (_interface.width - 20) || mouseX < 20 || mouseY > 338 || mouseY < 200) {
					onStopChangeVolume();
					return;
				}
			}
			
			var sound:Number = mouseX - _soundBar.x * _interface.scaleX;
			
			if (sound < 0) {
				sound = 0;
			} else if (sound > _soundBar.width * _interface.scaleX) {
				sound = _soundBar.width * _interface.scaleX;
			}
			
			sound /= _soundBar.width * _interface.scaleX;
			
			_volume = sound;
			_soundBar.gotoAndStop(Math.ceil(sound * _soundBar.totalFrames) + 1);
			dispatchEvent(new InterfaceEvent(InterfaceEvent.INTERFACE_EVENT, false, false, { volume:sound } ));
		}
		
		private function onUpdateBufferingMovie(e:Event):void 
		{
			if (App.isBuffering) {
				if (!_bufferingBar.visible) {
					_bufferingBar.visible = true;
					_bufferingBar.play();
				}
			} else if(!App.isBuffering && !App.cutVideo_isBuffering) {
				if (_bufferingBar.visible) {
					_bufferingBar.visible = false;
					_bufferingBar.stop();
				}
			} else if (App.cutVideo_isBuffering) {
				if (!_bufferingBar.visible) {
					_bufferingBar.visible = true;
					_bufferingBar.play();
				}
			} 
			
			if (App.startShowingBar && !App.endShowingBar)
			{
				if (!_bufferingBar.visible) {
					_bufferingBar.visible = true;
					_bufferingBar.play();
				}
			}
		}
		
		private function onUpdateInterfaceByScreenMode(e:FullScreenEvent):void 
		{
			if (App.stage.displayState == StageDisplayState.FULL_SCREEN) {
				
				_interface.gotoAndStop("fullscreen");
				
				if (Math.abs(App.stage.fullScreenWidth / 4 - App.stage.fullScreenHeight / 3) < 30) {
					
					var height:int = App.stage.fullScreenHeight;
					var width:int = App.stage.fullScreenWidth;
					
					_interface.width = App.stage.fullScreenWidth;
					_interface.height = App.stage.fullScreenWidth / 16 * 9;
					App.video_player.width = App.stage.fullScreenWidth;
					App.video_player.height = App.stage.fullScreenWidth / 16 * 9;
					
					var offset:int = (App.stage.fullScreenHeight - _interface.height) / 2;
					
					_interface.y = offset;
					App.video_player.y = offset;
					
					if (Main.PictureIsOnScreen) {
						Main.UrlLoader.y = offset;
						Main.UrlLoader.scaleX = Main.UrlLoader.scaleY = App.stage.fullScreenWidth / Main.UrlLoader.width;
					}
					
				} else {
					
					if (Main.PictureIsOnScreen) {
						Main.UrlLoader.scaleX = App.stage.fullScreenWidth / Main.UrlLoader.width;
						Main.UrlLoader.scaleY = App.stage.fullScreenHeight / Main.UrlLoader.height;
					}
					
					_interface.width = App.stage.fullScreenWidth;
					_interface.height = App.stage.fullScreenHeight;
					App.video_player.width = App.stage.fullScreenWidth;
					App.video_player.height = App.stage.fullScreenHeight;
					
				}
				_bufferingBar = _interface.bufferingbar;
				_playpauseBtn = _interface.bottom_mc.playpauseBtn;
				if(App.isPlaying) {
					_playpauseBtn.gotoAndStop("play");
				} else {
					_playpauseBtn.gotoAndStop("pause");
				}
				_fullscreenBtn = _interface.bottom_mc.fullscreenButton;
				_soundBar = _interface.bottom_mc.soundBtn_1;
				_soundBar.gotoAndStop(Math.ceil(_volume * _soundBar.totalFrames) + 1);
				_seekBar = _interface.bottom_mc.seekbutton;
				_seekBar.buttonMode = true;
				_seekBar.sub.stop();
				//_seekBar.sub.gotoAndStop(seekBarFrame);
				_subtitleTextField = _interface.subtitles;
				_subtitleTextField.selectable = false;
				_subtitleTextField.htmlText = "";
				_watermark = _interface.centertext.text;
				_watermark.text = _watermarkText;
				_currentTimeTF = _interface.bottom_mc.currentTime;
				_totalTimeTF = _interface.bottom_mc.totalTime;
				_currentTimeTF.mouseEnabled = false;
				_totalTimeTF.mouseEnabled = false;
				
				_sub_ru = _interface.upper_mc.sub_ru;
				_sub_ru.addEventListener(MouseEvent.CLICK, onChangeSubtitles, false, 0, true);
				_sub_en = _interface.upper_mc.sub_en;
				_sub_en.addEventListener(MouseEvent.CLICK, onChangeSubtitles, false, 0, true);
				_sub_off = _interface.upper_mc.sub_off;
				_sub_off.addEventListener(MouseEvent.CLICK, onChangeSubtitles, false, 0, true);
				
				_sound_ru = _interface.upper_mc.sound_ru;
				_sound_ru.addEventListener(MouseEvent.CLICK, onChangeSound, false, 0, true);
				_sound_en = _interface.upper_mc.sound_en;
				_sound_en.addEventListener(MouseEvent.CLICK, onChangeSound, false, 0, true);
				
				_lowQuality = _interface.upper_mc.lowquality;
				_lowQuality.addEventListener(MouseEvent.CLICK, onChangeQuality, false, 0, true);
				_normQuality = _interface.upper_mc.normquality;
				_normQuality.addEventListener(MouseEvent.CLICK, onChangeQuality, false, 0, true);
				_highQuality = _interface.upper_mc.highquality;
				_highQuality.addEventListener(MouseEvent.CLICK, onChangeQuality, false, 0, true);
				
				UpdateButtons();
				_playpauseBtn.addEventListener(MouseEvent.CLICK, onPlayPause, false, 0, true);
				_soundBar.addEventListener(MouseEvent.MOUSE_DOWN, onChangeVolume, false, 0, true);
				App.stage.addEventListener(MouseEvent.MOUSE_UP, onStopChangeVolume, false, 0, true);
				_fullscreenBtn.addEventListener(MouseEvent.CLICK, onChangeScreenMode, false, 0, true);
				_seekBar.addEventListener(MouseEvent.CLICK, onSeek, false, 0, true);
				_seekBar.addEventListener(Event.ENTER_FRAME, onUpdateSeek, false, 0, true);
				
				removeEventListener(MouseEvent.MOUSE_MOVE, onCheckIfDragMenuDown, false);
				addEventListener(MouseEvent.MOUSE_MOVE, onCheckIfDragMenuDown, false, 0, true);
				_fs_dragmenu_timer.removeEventListener(TimerEvent.TIMER, onDragDown, false);
				_fs_dragmenu_timer.reset();
				_fs_dragmenu_timer.start();
				_fs_dragmenu_timer.addEventListener(TimerEvent.TIMER, onDragDown, false, 0, true);
				UpdatePlayButton();
				
			} else if (App.stage.displayState == StageDisplayState.NORMAL) {
				
				
				if (Main.PictureIsOnScreen) {
					Main.UrlLoader.y = 0;
					Main.UrlLoader.scaleX = Main.UrlLoader.scaleY = 1;
				}
				
				_interface.scaleX = _interface.scaleY = 1;
				App.video_player.scaleX = App.video_player.scaleY = 1;
				
				_interface.gotoAndStop("window");
				
				_interface.y = 0;
				App.video_player.y = 0;
				
				_bufferingBar = _interface.bufferingbar;
				_playpauseBtn = _interface.bottom_w_mc.playpauseBtn;
				if(App.isPlaying) {
					_playpauseBtn.gotoAndStop("play");
				} else {
					_playpauseBtn.gotoAndStop("pause");
				}
				
				_fullscreenBtn = _interface.bottom_w_mc.fullscreenButton;
				_soundBar = _interface.bottom_w_mc.soundBtn;
				
				_soundBar.gotoAndStop(Math.ceil(_volume * _soundBar.totalFrames) + 1);
				_seekBar = _interface.bottom_w_mc.seekbutton;
				_seekBar.buttonMode = true;
				_seekBar.sub.stop();
				//_seekBar.sub.gotoAndStop(seekBarFrame);
				_subtitleTextField = _interface.subtitles;
				_subtitleTextField.selectable = false;
				_subtitleTextField.htmlText = "";
				_watermark = _interface.centertext.text;
				_watermark.text = _watermarkText;
				
				_currentTimeTF = _interface.bottom_w_mc.currentTime;
				_totalTimeTF = _interface.bottom_w_mc.totalTime;
				_currentTimeTF.mouseEnabled = false;
				_totalTimeTF.mouseEnabled = false;
				
				_sub_ru = _interface.sub_ru;
				_sub_ru.addEventListener(MouseEvent.CLICK, onChangeSubtitles, false, 0, true);
				_sub_en = _interface.sub_en;
				_sub_en.addEventListener(MouseEvent.CLICK, onChangeSubtitles, false, 0, true);
				_sub_off = _interface.sub_off;
				_sub_off.addEventListener(MouseEvent.CLICK, onChangeSubtitles, false, 0, true);
				
				_sound_ru = _interface.sound_ru;
				_sound_ru.addEventListener(MouseEvent.CLICK, onChangeSound, false, 0, true);
				_sound_en = _interface.sound_en;
				_sound_en.addEventListener(MouseEvent.CLICK, onChangeSound, false, 0, true);
				
				_lowQuality = _interface.lowquality;
				_lowQuality.addEventListener(MouseEvent.CLICK, onChangeQuality, false, 0, true);
				_normQuality = _interface.normquality;
				_normQuality.addEventListener(MouseEvent.CLICK, onChangeQuality, false, 0, true);
				_highQuality = _interface.highquality;
				_highQuality.addEventListener(MouseEvent.CLICK, onChangeQuality, false, 0, true);
				
				UpdateButtons();
				
				_playpauseBtn.addEventListener(MouseEvent.CLICK, onPlayPause, false, 0, true);
				_soundBar.addEventListener(MouseEvent.MOUSE_DOWN, onChangeVolume, false, 0, true);
				App.stage.addEventListener(MouseEvent.MOUSE_UP, onStopChangeVolume, false, 0, true);
				_fullscreenBtn.addEventListener(MouseEvent.CLICK, onChangeScreenMode, false, 0, true);
				_seekBar.addEventListener(MouseEvent.CLICK, onSeek, false, 0, true);
				_seekBar.addEventListener(Event.ENTER_FRAME, onUpdateSeek, false, 0, true);
				
				removeEventListener(MouseEvent.MOUSE_MOVE, onCheckIfDragMenuDown, false);
				addEventListener(MouseEvent.MOUSE_MOVE, onCheckIfDragMenuDown, false, 0, true);
				_fs_dragmenu_timer.removeEventListener(TimerEvent.TIMER, onDragDown, false);
				_fs_dragmenu_timer.reset();
				_fs_dragmenu_timer.start();
				_fs_dragmenu_timer.addEventListener(TimerEvent.TIMER, onDragDown, false, 0, true);
				UpdatePlayButton();
			}
		}
		
		private function onDragDown(e:TimerEvent):void 
		{
			if (App.stage.displayState == StageDisplayState.FULL_SCREEN) {
				_draggedDown = true;
				_interface.gotoAndPlay(2);
			} else if (App.stage.displayState == StageDisplayState.NORMAL) {
				_draggedDown = true;
				_interface.gotoAndPlay(22);
				//_fs_dragmenu_timer.removeEventListener(TimerEvent.TIMER, onDragDown, false);
				//_fs_dragmenu_timer.reset();
			}
		}
		
		private function onCheckIfDragMenuDown(e:MouseEvent):void 
		{
			if (_draggedDown) {
				if (App.stage.displayState == StageDisplayState.NORMAL) {
					_interface.gotoAndPlay("menuUp_w");
				} else if (App.stage.displayState == StageDisplayState.FULL_SCREEN) {
					_interface.gotoAndPlay("menuUp");
				}
				_draggedDown = false;
			}
			
			_fs_dragmenu_timer.reset();
			_fs_dragmenu_timer.start();
		}
		
		public function ReadyToSeek():void 
		{
			//dispatchEvent(new InterfaceEvent(InterfaceEvent.INTERFACE_EVENT, false, false, { changesoundmode:true } ));
			
			var time:Number = App.video_stream.time;
			
			var offset:int = 1000;
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
			//trace(keyframe.time, keyframe.bytes);
			App.isSeeking = true;
			dispatchEvent(new InterfaceEvent(InterfaceEvent.INTERFACE_EVENT, false, false, { seek:keyframe } ));
			App.controller.Init();
		}
		
		private function onStartSubtitles(e:SubtitlesLoaded):void 
		{
			if (App.LANGUAGE == App.ENG) {
				LoadSubtitlesArray("eng");
			} else {
				LoadSubtitlesArray("rus");
			}
			addEventListener(Event.ENTER_FRAME, onSubtitles, false , 0, true);
		}
		
		private function onChangeQuality(e:MouseEvent):void 
		{
			if (_isAnimating) { return; }
			
			if (e.target is SimpleButton) {
				var sb:SimpleButton = e.target as SimpleButton;
				App.isSeeking = true;
				switch(sb.name)
				{
					case "low":
						App.Quality = App.QUALITY_LOW;
						UpdateQualityButtons();
						if (CheckIfNeedToAnimateThePicture()) {
							return;
						}
						App.isNeedToCutFile = true; 
						App.cutVideo_isBuffering = true;
						dispatchEvent(new InterfaceEvent(InterfaceEvent.INTERFACE_EVENT, false, false, { quality:App.video_stream.time } ));
						App.controller.Init();
						
					break;
					case "norm":
						App.Quality = App.QUALITY_NORM;
						UpdateQualityButtons();
						if (CheckIfNeedToAnimateThePicture()) {
							return;
						}
						App.isNeedToCutFile = true; 
						App.cutVideo_isBuffering = true;
						dispatchEvent(new InterfaceEvent(InterfaceEvent.INTERFACE_EVENT, false, false, { quality:App.video_stream.time } ));
						App.controller.Init();
					break;
					case "high":
						App.Quality = App.QUALITY_HIGH;
						UpdateQualityButtons();
						if (CheckIfNeedToAnimateThePicture()) {
							return;
						}
						App.isNeedToCutFile = true; 
						App.cutVideo_isBuffering = true;
						dispatchEvent(new InterfaceEvent(InterfaceEvent.INTERFACE_EVENT, false, false, { quality:App.video_stream.time } ));
						App.controller.Init();
					break;
				}
			}
		}
		
		private function CheckIfNeedToAnimateThePicture():Boolean 
		{
			if (Main.NotStarted && Main.PictureIsOnScreen) {
				_upperMask.visible = true;
				_isAnimating = true;
				App.video_player.startPlayingStreamAfterPicture();
				addEventListener(Event.ENTER_FRAME, onUpdateAnimation, false, 0, true);
				App.isNeedToSynchronize = true;
				return true;
			} else {
				return false;
			}
		}
		
		private function onUpdateAnimation(e:Event):void 
		{
			_upperMask.alpha += 0.9 / ANIMATION_LENGTH;
			if (_upperMask.alpha >= 0.9) {
				
				removeEventListener(Event.ENTER_FRAME, onUpdateAnimation, false);
				_isAnimating = false;
				Main.NotStarted = false;
				App.video_stream.resume();
				if(Main.UrlLoader) {
					if (Main.Layer.contains(Main.UrlLoader)) {
						Main.Layer.removeChild(Main.UrlLoader);
					}
				}
				
				App.startShowingBar = true;
				_upperMask.visible = false;
				Main.PictureIsOnScreen = false;
			}
		}
		
		private function onChangeSubtitles(e:MouseEvent):void 
		{
			if (_isAnimating) { return; }
			
			if (e.target is SimpleButton) {
				var sb:SimpleButton = e.target as SimpleButton;
				switch(sb.name)
				{
					case "en":
						App.Subtitles = App.SUBS_ENG;
						_subtitleTextField.visible = true;
						LoadSubtitlesArray("eng");
					break;
					case "ru":
						App.Subtitles = App.SUBS_RUS;
						_subtitleTextField.visible = true;
						LoadSubtitlesArray("rus");
					break;
					case "off":
						App.Subtitles = App.SUBS_OFF;
						_subtitleTextField.visible = false;
					break;
				}
				
				UpdateSubtitleButtons();
			}
		}
		
		private function onChangeSound(e:MouseEvent):void 
		{
			if (_isAnimating) { return; }
			
			if (e.target is SimpleButton) {
				var sb:SimpleButton = e.target as SimpleButton;
				if(sb.name == "ru" || sb.name == "en")
				{
					if (sb.name == "ru") {
						App.Sound = App.SOUND_RUS;
					} else if (sb.name == "en") {
						App.Sound = App.SOUND_ENG;
					}
					
					dispatchEvent(new InterfaceEvent(InterfaceEvent.INTERFACE_EVENT, false, false, { sound:true } ));
				}
				
				
				UpdateSoundButtons();
			}
		}
		
		public function LoadSubtitlesArray(language:String):void 
		{
			//App.player_interface.SetWaterMark("LOAD SUBS " + language);
			
			
			if (!_subtitlesObject[language]) { 
				_currentSubtitleArray.length = 0; 
				_subtitleTextField.visible = false;
				return; 
			}
			
			_subtitleTextField.htmlText = "";
			_subtitleTextField.visible = true;
			
			var tmpArray:Array = subtitlesObject[language];
			var length:int = tmpArray.length;
			_currentSubtitleArray.length = 0;
			for (var i:int = 0; i < length; i++)
			{
				_currentSubtitleArray.push(tmpArray[i]);
			}
		}
		
		private function onSubtitles(e:Event):void 
		{
			if (App.isPlaying)
			{
				if (App.video_duration != 0) 
				{
					
					var curr_time:int = App.video_stream.time * 1000;
					var length:int = _currentSubtitleArray.length;
					if (length == 0) { return; }
					
					var subtitle:Subtitle;
					for (var i:int = 0; i < length; i++)
					{
						subtitle = _currentSubtitleArray[i];
						if (curr_time > subtitle.startTime && curr_time < subtitle.endTime) {
							_subtitleTextField.htmlText = subtitle.text;
							return;
						}
					}
					
					_subtitleTextField.htmlText = "";
				}
			}
		}
		
		private function onSeek(e:MouseEvent):void 
		{
			if (_isAnimating) { return; }
			
			if (Main.NotStarted) {
				onPlayPause();
				Main.NotStarted = false;
				return;
			}
			
			if (e.target is MovieClip) {
				if ((e.target as MovieClip).parent) {
					if ((e.target as MovieClip).parent.name == "seekbutton") {
						
						var mc:MovieClip = e.currentTarget as MovieClip;
						var cur_part:Number = (e.localX / BAR_WIDTH);
						
						var bytes_offset:Number = 0;
						if (App.isCutedVideoLoaded) {
							bytes_offset += App.cutVideo_offset_bytes;
						} else {
							App.cutVideo_offset_bytes = 0;
							App.cutVideo_offset_seconds = 0;
							App.cutVideo_part = 0;
						}
						
						if (App.isCutedVideoLoaded && App.cutVideo_part > cur_part) {
							App.isNeedToCutFile = true; 
							App.cutVideo_isBuffering = true;
						}
						else if (App.video_stream.bytesTotal * (cur_part + bytes_offset) < App.video_stream.bytesLoaded) {
							App.isNeedToCutFile = false;
							App.cutVideo_isBuffering = false;
							if (App.isCutedVideoLoaded)
							{
								SearchOnCuttedVideoAndDispatchSeek(cur_part);
								return
							}	
						} else {
							App.isNeedToCutFile = true;
							App.cutVideo_isBuffering = true;
							App.cutVideo_part = cur_part;
						}
						
						var time:Number = cur_part * App.video_duration;
						var offset:int = 1000;
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
						
						App.isSeeking = true;
						dispatchEvent(new InterfaceEvent(InterfaceEvent.INTERFACE_EVENT, false, false, { seek:keyframe } ));
						App.controller.Init();
					}
				}
			}
			else if (e.currentTarget is ProgressBar) {
				mc = e.currentTarget as MovieClip;
				
				cur_part = (e.localX / BAR_WIDTH);
						
				bytes_offset = 0;
				if (App.isCutedVideoLoaded) {
					bytes_offset += App.cutVideo_offset_bytes;
				} else {
					App.cutVideo_offset_bytes = 0;
					App.cutVideo_offset_seconds = 0;
					App.cutVideo_part = 0;
				}
				
				if (App.cutVideo_part < cur_part) {
					App.isNeedToCutFile = true; 
					App.cutVideo_isBuffering = true;
				}
				else if (App.video_stream.bytesTotal * (cur_part + bytes_offset) < App.video_stream.bytesLoaded) {
					App.isNeedToCutFile = false;
					App.cutVideo_isBuffering = false;
					if (App.isCutedVideoLoaded)
					{
						SearchOnCuttedVideoAndDispatchSeek(cur_part);
						return
					}
					
				} else {
					App.isNeedToCutFile = true;
					App.cutVideo_isBuffering = true;
					App.cutVideo_part = cur_part;
				}
				
				time = cur_part * App.video_duration;
				offset = 1000;
				
				length = App.keyframesArray.length;
				for (i = 0; i < length; i++ ) {
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
				
				App.isSeeking = true;
				dispatchEvent(new InterfaceEvent(InterfaceEvent.INTERFACE_EVENT, false, false, { seek:keyframe } ));
				App.controller.Init();
			}
		}
		
		private function SearchOnCuttedVideoAndDispatchSeek(cur_part:Number):void 
		{
			var time:Number = cur_part * App.video_duration;
			var offset:int = 1000;
			
			var keyframe:Keyframe;
			var length:int = App.cutVideo_keyframesArray.length;
			var kf:Keyframe;
			for (var i:int = 0; i < length; i++ ) {
				kf = App.cutVideo_keyframesArray[i];
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
			
			App.isSeeking = true;
			dispatchEvent(new InterfaceEvent(InterfaceEvent.INTERFACE_EVENT, false, false, { seek:keyframe } ));
			App.controller.Init();
		}
		
		private function onUpdateSeek(e:Event):void 
		{
			if (App.video_duration != 0) {
				
				var secondsOffset:int = 0;// 
				//var secondsOffset:int = (App.isCutedVideoLoaded) ? App.cutVideo_offset_seconds : 0;
				
				var time:int = App.video_stream.time + secondsOffset;
				
				var minutes:int = time / 60;
				var seconds:int = time % 60;
				var stringMins:String = String(minutes);
				var stringSecs:String = String(seconds);
				if (stringMins.length == 1) {
					stringMins = "0" + stringMins;
				}
				if (stringSecs.length == 1) {
					stringSecs = "0" + stringSecs;
				}
				_currentTimeTF.text = stringMins + ":" + stringSecs;
				
				var dur_time:int = App.video_duration;
				minutes = dur_time / 60;
				seconds = dur_time % 60;
				stringMins = String(minutes);
				stringSecs = String(seconds);
				if (stringMins.length == 1) {
					stringMins = "0" + stringMins;
				}
				if (stringSecs.length == 1) {
					stringSecs = "0" + stringSecs;
				}
				
				_totalTimeTF.text = stringMins + ":" + stringSecs;
				
				var cur_part:int = (time / App.video_duration) * 1000;
				
				_seekBar.sub.gotoAndStop(cur_part);
			}
		}
		
		private function onChangeVolume(e:MouseEvent):void 
		{
			var sound:Number = mouseX - _soundBar.x * _interface.scaleX;
			
			if (sound < 0) {
				sound = 0;
			} else if (sound > _soundBar.width * _interface.scaleX) {
				sound = _soundBar.width * _interface.scaleX;
			}
			
			sound /= _soundBar.width * _interface.scaleX;
			
			_volume = sound;
			_soundBar.gotoAndStop(Math.ceil(sound * _soundBar.totalFrames) + 1);
			dispatchEvent(new InterfaceEvent(InterfaceEvent.INTERFACE_EVENT, false, false, { volume:sound } ));
			
			_changingVolume = true;
			App.stage.addEventListener(MouseEvent.MOUSE_MOVE, onDragAndDropChangingVolume, false, 0, true);
		}
		
		public function UpdatePlayButton():void 
		{
			if (App.isPlaying) {
				_playpauseBtn.gotoAndStop("pause");
			} else {
				_playpauseBtn.gotoAndStop("play");
			}
		}
		
		private function onChangeScreenMode(e:MouseEvent):void 
		{
			if (App.stage.displayState == StageDisplayState.NORMAL) {
				App.stage.displayState = StageDisplayState.FULL_SCREEN;
			} else if (App.stage.displayState == StageDisplayState.FULL_SCREEN) {
				App.stage.displayState = StageDisplayState.NORMAL;
			}
		}
		
		private function onStop(e:MouseEvent):void 
		{
			dispatchEvent(new InterfaceEvent(InterfaceEvent.INTERFACE_EVENT, false, false, { stop:true } ));
		}
		
		public function onPlayPause(e:MouseEvent = null):void 
		{
			if (CheckIfNeedToAnimateThePicture()) {
				return;
			}
			if (_isAnimating) { return;}
			if (Main.NeedToStart) {
				return;
			}
			
			if (App.isPlaying) {
				dispatchEvent(new InterfaceEvent(InterfaceEvent.INTERFACE_EVENT, false, false, { pause:true } ));
				App.isPlaying = false;
				_playpauseBtn.gotoAndStop("play");
			} else {
				dispatchEvent(new InterfaceEvent(InterfaceEvent.INTERFACE_EVENT, false, false, { play:true } ));
				App.isPlaying = true;
				_playpauseBtn.gotoAndStop("pause");
			}
		}
		
		public function UpdateButtons():void
		{
			UpdateQualityButtons();
			UpdateSoundButtons();
			UpdateSubtitleButtons();
		}
		
		public function UpdateSoundButtons():void
		{
			switch(App.Sound)
			{
				case App.SOUND_RUS:
					_sound_en.gotoAndStop(2);
					_sound_ru.gotoAndStop(1);
				break;
				case App.SOUND_ENG:
					_sound_en.gotoAndStop(1);
					_sound_ru.gotoAndStop(2);
				break;
			}
		}
		
		public function UpdateSubtitleButtons():void
		{
			switch(App.Subtitles)
			{
				case App.SUBS_OFF:
					_sub_en.gotoAndStop(2);
					_sub_ru.gotoAndStop(2);
					_sub_off.gotoAndStop(1);
				break;
				case App.SUBS_RUS:
					_sub_en.gotoAndStop(2);
					_sub_ru.gotoAndStop(1);
					_sub_off.gotoAndStop(2);
				break;
				case App.SUBS_ENG:
					_sub_en.gotoAndStop(1);
					_sub_ru.gotoAndStop(2);
					_sub_off.gotoAndStop(2);
				break;
			}
		}
		
		public function UpdateQualityButtons():void
		{
			switch(App.Quality)
			{
				case App.QUALITY_LOW:
					_lowQuality.gotoAndStop(1);
					_normQuality.gotoAndStop(2);
					_highQuality.gotoAndStop(2);
				break;
				case App.QUALITY_NORM:
					_lowQuality.gotoAndStop(2);
					_normQuality.gotoAndStop(1);
					_highQuality.gotoAndStop(2);
				break;
				case App.QUALITY_HIGH:
					_lowQuality.gotoAndStop(2);
					_normQuality.gotoAndStop(2);
					_highQuality.gotoAndStop(1);
				break;
			}
		}
		
		public function SetWaterMark(watermark:String):void 
		{
			_watermarkText = watermark;
			_watermark.text = _watermarkText;
		}
		
		public function get subtitlesObject():Object { return _subtitlesObject; }
		
		public function set subtitlesObject(value:Object):void 
		{
			_subtitlesObject = value;
		}
		
		public function get bufferingBar():MovieClip { return _bufferingBar; }
		
		public function get subtitleTextField():TextField { return _subtitleTextField; }
		
		//public function get subtitleTextField():TextField { return _subtitleTextField; }
	}

}