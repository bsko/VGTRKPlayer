package  
{
	import flash.display.Stage;
	import flash.media.Video;
	import flash.net.NetStream;
	/**
	 * ...
	 * @author ...
	 */
	public class App 
	{
		public static const ENG:int = 1001;
		public static const RUS:int = 1002;
		
		public static const LANGUAGE:int = RUS;

		public static const SOUND_ENG:int = 101;
		public static const SOUND_RUS:int = 102;
		public static const SUBS_ENG:int = 103;
		public static const SUBS_RUS:int = 104;
		public static const SUBS_OFF:int = 105;
		public static const QUALITY_LOW:int = 106;
		public static const QUALITY_NORM:int = 107;
		public static const QUALITY_HIGH:int = 108;
		
		public static const RTMP_CONNECTION_URL:int = 109;
		
		public static const PLAYER_WIDTH:int = 614;
		public static const PLAYER_HEIGHT:int = 345;
		
		public static var PathToXMOOVE:String;
		public static var Quality:int;
		public static var Subtitles:int;
		public static var Sound:int;
		
		public static var isPlaying:Boolean = false;
		public static var player_interface:Interface;
		public static var video_player:VideoPlayer;
		public static var stage:Stage;
		public static var soundControll:SoundControll;
		public static var video_stream:NetStream;
		public static var video_duration:Number = 0;
		public static var subtitleLoader:SubtitleLoader;
		public static var controller:Controller = new Controller();
		
		//public static var videoController:VideoController;
		//public static var soundController:SoundController;
		
		public static var goto:int;
		public static var keyframesArray:Array = [];
		public static var journal:NetStreamJournal = new NetStreamJournal();
		public static var isSeeking:Boolean = false;
		public static var isBuffering:Boolean = false;
		public static var isQualityChanged:Boolean = false;
		public static var qualityOffset:int = 0;
		public static var startShowingBar:Boolean = false;
		public static var endShowingBar:Boolean = false;
		
		public static var isCutedVideoLoaded:Boolean = false;
		public static var cutVideo_offset_seconds:Number = 0;
		public static var cutVideo_offset_bytes:int = 0;
		public static var cutVideo_part:Number = 0;
		public static var cutVideo_metaDataReceived:Boolean = false;
		public static var isNeedToCutFile:Boolean = false;
		public static var cutVideo_isBuffering:Boolean = false;
		public static var cutVideo_keyframesArray:Array = [];
		static public var isNeedToSynchronize:Boolean = false;
		static public var streamIsWaitingForSound:Boolean;
		static public var isPhotoPageOpen:Boolean = false;
	}

}