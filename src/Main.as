package  
{
	import adobe.utils.ProductManager;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.utils.Timer;
	import events.*;
	import subtitleThings.*;
	/**
	 * ...
	 * @author iam
	 */
	public class Main extends Sprite
	{
		public static var UrlLoader:Loader;
		public static var NeedToStart:Boolean = false;
		public static var NotStarted:Boolean = false;
		public static var PictureIsOnScreen:Boolean = false;
		public static var Layer:Sprite = new Sprite();
		
		private var _backMaskMovie:MovieClip = new BackMaskMovie();
		
		public function Main() 
		{	
			App.stage = stage;
			stage.align = StageAlign.LEFT;
			App.soundControll = new SoundControll();
			
			//App.soundController = new SoundController();
			
			addChild(_backMaskMovie);
			
			App.video_player = new VideoPlayer();
			addChild(App.video_player);
			
			//App.videoController = new VideoController();
			//addChild(App.videoController);
			
			addChild(Layer);
			var object:Object = stage.loaderInfo.parameters;
			
			
			if (object.picture) {
				if (object.picture != undefined) {
					
					UrlLoader = new Loader();
					UrlLoader.load(new URLRequest(object.picture));
					NeedToStart = false;
					PictureIsOnScreen = true;
					Layer.addChild(UrlLoader);
				} 
			}
			
			App.player_interface = new Interface();
			addChild(App.player_interface);
			
			App.subtitleLoader = new SubtitleLoader();
			
			//test -------------
			App.Quality = App.QUALITY_LOW;
			if (App.LANGUAGE == App.ENG) {
				App.Subtitles = App.SUBS_ENG;
				App.Sound = App.SOUND_ENG;
			} else {
				App.Subtitles = App.SUBS_RUS;
				App.Sound = App.SOUND_RUS;
			}
			
			var ensubs:String = "#";
			var rusubs:String = "#";
			
			//var rusound:String = "http://sales.vgtrk.com:80/upload/video/download/site/Agent_201/Agent_A-201-1c_Rus1.mp3";
			//var ensound:String = "http://sales.vgtrk.com:80/upload/video/download/site/Agent_201/Agent_A-201-1c_Eng1_1.mp3";
			var rusound:String = "#";
			var ensound:String = "#";
			
			var rtmp_connection:String = "rtmp://aloha.cdnvideo.ru/mc10";
			//var rtmp_connection:String = null;
			//var lowquality:String = "flv:58/upload/video/download/site/rasputin_trailer/video/B-TWEEN_RASPOUTINE-TRAILER_169-177_1080psf24_FRESTENG_1011TVS5287_H264_496KB_for_site";
			//var normquality:String = "flv:58/upload/video/download/site/rasputin_trailer/video/B-TWEEN_RASPOUTINE-TRAILER_169-177_1080psf24_FRESTENG_1011TVS5287_H264_496KB_for_site";
			var lowquality:String = "mp4:58/upload/video/download/site/Ballet/BIG_BALET_CANNES_prores-_1Mbit_640x480.mp4";
			var normquality:String = "mp4:58/upload/video/download/site/RUSSIAN SEASONS NACHO DUATO/Russkie_sezony_Nacho_Dauto_low.mp4";
			var highquality:String = "flv:58/upload/video/Marshal_gukov_VP6_1328K_25p";
			//var lowquality:String = "http://sales.vgtrk.com:80/upload/video/download/site/Agent_201/Agent_A-201-1s-_896_kb_s.flv";
			//var normquality:String = "http://sales.vgtrk.com:80/upload/video/download/site/Agent_201/Agent_A-201-1s-_896_kb_s.flv";
			//var highquality:String = "http://sales.vgtrk.com:80/upload/video/download/site/Agent_201/Agent_A-201-1s-_896_kb_s.flv";
			var pathtoxmoove:String = "http://sales.vgtrk.com:80/xmoov.php";
			
			var watermark:String = "RUSSIAN TELEVISION WATERMARK";
			//endtest ----------
			
			if (object.ensubs) {
				if (object.ensubs != undefined) {
					ensubs = object.ensubs;
				}
			}
			if (object.rusubs) {
				if (object.rusubs != undefined) {
					rusubs = object.rusubs;
				}
			}
			if (object.rusound) {
				if (object.rusound != undefined) {
					rusound = object.rusound;
				}
			}
			if (object.ensound) {
				if (object.ensound != undefined) {
					ensound = object.ensound;
				}
			}
			if (object.rtmpconnection) {
				if (object.rtmpconnection != undefined) {
					rtmp_connection = object.rtmpconnection;
				}
			}
			if (object.lowquality) {
				if (object.lowquality != undefined) {
					lowquality = object.lowquality;
				}
			}
			if (object.normquality) {
				if (object.normquality != undefined) {
					normquality = object.normquality;
				}
			}
			if (object.highquality) {
				if (object.highquality != undefined) {
					highquality = object.highquality;
				}
			}
			if (object.watermark) {
				if (object.watermark != undefined) {
					watermark = object.watermark;
				}
			}
			if (object.xmoov) {
				if (object.xmoov != undefined) {
					pathtoxmoove = object.xmoov;
				}
			}
			
			App.PathToXMOOVE = pathtoxmoove;
			
			App.video_player.LoadURLs(lowquality, normquality, highquality, rtmp_connection);
			//App.videoController.LoadURLs(lowquality, normquality, highquality);
			App.soundControll.LoadURLS(rusound, ensound);
			//App.soundController.LoadURLs(rusound, ensound);
			App.subtitleLoader.Init();
			App.subtitleLoader.LoadAllSubtitles(rusubs, ensubs);
			
			App.video_player.Init();
			//App.videoController.Init();
			
			App.player_interface.Init();
			App.player_interface.SetWaterMark(watermark);
			App.soundControll.Init();
			App.soundControll.playSound();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			if (NeedToStart) {
				App.startShowingBar = true;
			}
			
			if (ExternalInterface.available)
			{
				ExternalInterface.addCallback("PausePlayer", receivedFromJavaScriptPause);
				ExternalInterface.addCallback("PlayPlayer", receivedFromJavaScriptPlay);
				App.isPhotoPageOpen = ExternalInterface.call("isPaused");
			}
		}
		
		private	function receivedFromJavaScriptPause(str:String = null):void
		{
			if (App.player_interface && !PictureIsOnScreen)
			{
				if (App.isPlaying)
				{
					App.player_interface.onPlayPause();
				}
				App.isPhotoPageOpen = true;
			}
		}
		
		private	function receivedFromJavaScriptPlay(str:String = null):void
		{
			if (App.player_interface && !PictureIsOnScreen)
			{
				if (!App.isPlaying)
				{
					App.player_interface.onPlayPause();
				}
				App.isPhotoPageOpen = false;
			}
		}
	}
}