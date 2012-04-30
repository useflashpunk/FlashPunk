package net.flashpunk.tweens.motion 
{
	import net.flashpunk.Tween;
	
	/**
	 * Base class for motion Tweens.
	 */
	public class Motion extends Tween
	{
		/**
		 * Current x position of the Tween.
		 */
		public function get x():Number { return _x; }
		public function set x(value:Number):void
		{
			_x = value;
			if (_object)
				_object.x = _x;
		}
		
		/**
		 * Current y position of the Tween.
		 */
		public function get y():Number { return _y; }
		public function set y(value:Number):void
		{
			_y = value;
			if (_object)
				_object.y = _y;
		}
		
		/**
		 * Target object for the tween. Must have an x and a y property.
		 */
		public function get object():Object { return _object; }
		public function set object(value:Object):void
		{
			_object = value;
			if (_object)
			{
				_object.x = _x;
				_object.y = _y;
			}
		}
		
		/**
		 * Constructor.
		 * @param	duration	Duration of the Tween.
		 * @param	complete	Optional completion callback.
		 * @param	type		Tween type.
		 * @param	ease		Optional easer function.
		 */
		public function Motion(duration:Number, complete:Function = null, type:uint = 0, ease:Function = null) 
		{
			super(duration, type, complete, ease);
		}
		
		protected var _x:Number = 0;
		protected var _y:Number = 0;
		protected var _object:Object;
	}
}