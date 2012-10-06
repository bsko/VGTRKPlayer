package  
{
	
	/**
	 * ...
	 * @author iam
	 */
	public interface PlayerInterface 
	{
		function Init():void
		
		function Seek(delay:Number):void
		
		function Play(file:String, delay:Number):void
		
		function Stop():void
		
		function Resume():void
		
		function Pause():void
		
		function ChangeVolume(val:Number):void
	}
	
}