package net.flashpunk.tweens.sound 
{
	import net.flashpunk.Sfx;
	import net.flashpunk.Tween;
	
	/**
	 * Sound effect fader.
	 */
	public class SfxFader extends Tween
	{
		/**
		 * Constructor.
		 * @param	sfx			The Sfx object to alter.
		 * @param	complete	Optional completion callback.
		 * @param	type		Tween type.
		 */
		public function SfxFader(sfx:Sfx, complete:Function = null, type:uint = 0) 
		{
			super(0, type, finish);
			_complete = complete;
			_sfx = sfx;
		}
		
		/**
		 * Fades the Sfx to the target volume.
		 * @param	volume		The volume to fade to.
		 * @param	duration	Duration of the fade.
		 * @param	ease		Optional easer function.
		 */
		public function fadeTo(volume:Number, duration:Number, ease:Function = null):void
		{
			if (volume < 0) volume = 0;
			_start = _sfx.volume;
			_range = volume - _start;
			_target = duration;
			_ease = ease;
			start();
		}
		
		/**
		 * Fades out the Sfx, while also playing and fading in a replacement Sfx.
		 * @param	play		The Sfx to play and fade in.
		 * @param	loop		If the new Sfx should loop.
		 * @param	duration	Duration of the crossfade.
		 * @param	volume		The volume to fade in the new Sfx to.
		 * @param	ease		Optional easer function.
		 */
		public function crossFade(play:Sfx, loop:Boolean, duration:Number, volume:Number = 1, ease:Function = null):void
		{
			_crossSfx = play;
			_crossRange = volume;
			_start = _sfx.volume;
			_range = -_start;
			_target = duration;
			_ease = ease;
			if (loop) _crossSfx.loop(0);
			else _crossSfx.play(0);
			start();
		}
		
		/** Updates the Tween. */
		override public function update():void 
		{
			super.update();
			if (_sfx) _sfx.volume = _start + _range * _t;
			if (_crossSfx) _crossSfx.volume = _crossRange * _t;
		}
		
		/** When the tween completes. */
		protected function finish():void
		{
			if (_crossSfx)
			{
				if (_sfx) _sfx.stop();
				_sfx = _crossSfx;
				_crossSfx = null;
			}
			if (_complete != null) _complete();
		}
		
		/**
		 * The current Sfx this object is effecting.
		 */
		public function get sfx():Sfx { return _sfx; }
		
		// Fader information.
		protected var _sfx:Sfx;
		protected var _start:Number;
		protected var _range:Number;
		protected var _crossSfx:Sfx;
		protected var _crossRange:Number;
		protected var _complete:Function;
	}
}