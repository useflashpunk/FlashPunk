package net.flashpunk.graphics 
{
	/**
	 * Template used by Spritemap to define animations. Don't create
	 * these yourself, instead you can fetch them with Spritemap's add().
	 */
	public class Anim 
	{
		/**
		 * Constructor.
		 * @param	name		Animation name.
		 * @param	frames		Array of frame indices to animate.
		 * @param	frameRate	Animation speed.
		 * @param	loop		If the animation should loop.
		 */
		public function Anim(name:String, frames:Array, frameRate:Number = 0, loop:Boolean = true) 
		{
			_name = name;
			_frames = frames;
			_frameRate = frameRate;
			_loop = loop;
			_frameCount = frames.length;
		}
		
		/**
		 * Plays the animation.
		 * @param	reset		If the animation should force-restart if it is already playing.
		 */
		public function play(reset:Boolean = false):void
		{
			_parent.play(_name, reset);
		}
		
		/**
		 * Name of the animation.
		 */
		public function get name():String { return _name; }
		
		/**
		 * Array of frame indices to animate.
		 */
		public function get frames():Array { return _frames; }
		
		/**
		 * Animation speed.
		 */
		public function get frameRate():Number { return _frameRate; }
		
		/**
		 * Amount of frames in the animation.
		 */
		public function get frameCount():uint { return _frameCount; }
		
		/**
		 * If the animation loops.
		 */
		public function get loop():Boolean { return _loop; }
		
		/** @private */ internal var _parent:Spritemap;
		/** @private */ internal var _name:String;
		/** @private */ internal var _frames:Array;
		/** @private */ internal var _frameRate:Number;
		/** @private */ internal var _frameCount:uint;
		/** @private */ internal var _loop:Boolean;
	}
}