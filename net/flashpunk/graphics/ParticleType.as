package net.flashpunk.graphics 
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	import net.flashpunk.FP;
	
	/**
	 * Template used to define a particle type used by the Emitter class. Instead
	 * of creating this object yourself, fetch one with Emitter's add() function.
	 */
	public class ParticleType 
	{
		/**
		 * Constructor.
		 * @param	name			Name of the particle type.
		 * @param	frames			Array of frame indices to animate through.
		 * @param	source			Source image.
		 * @param	frameWidth		Frame width.
		 * @param	frameHeight		Frame height.
		 */
		public function ParticleType(name:String, frames:Array, source:BitmapData, frameWidth:uint, frameHeight:uint)
		{
			_name = name;
			_source = source;
			_width = source.width;
			_frame = new Rectangle(0, 0, frameWidth, frameHeight);
			_frames = frames;
			_frameCount = frames.length;
		}
		
		/**
		 * Defines the motion range for this particle type.
		 * @param	angle			Launch Direction.
		 * @param	distance		Distance to travel.
		 * @param	duration		Particle duration.
		 * @param	angleRange		Random amount to add to the particle's direction.
		 * @param	distanceRange	Random amount to add to the particle's distance.
		 * @param	durationRange	Random amount to add to the particle's duration.
		 * @param	ease			Optional easer function.
		 * @return	This ParticleType object.
		 */
		public function setMotion(angle:Number, distance:Number, duration:Number, angleRange:Number = 0, distanceRange:Number = 0, durationRange:Number = 0, ease:Function = null):ParticleType
		{
			_angle = angle * FP.RAD;
			_distance = distance;
			_duration = duration;
			_angleRange = angleRange * FP.RAD;
			_distanceRange = distanceRange;
			_durationRange = durationRange;
			_ease = ease;
			return this;
		}
		
		/**
		 * Defines the motion range for this particle type based on the vector.
		 * @param	x				X distance to move.
		 * @param	y				Y distance to move.
		 * @param	duration		Particle duration.
		 * @param	durationRange	Random amount to add to the particle's duration.
		 * @param	ease			Optional easer function.
		 * @return	This ParticleType object.
		 */
		public function setMotionVector(x:Number, y:Number, duration:Number, durationRange:Number = 0, ease:Function = null):ParticleType
		{
			_angle = Math.atan2(y, x);
			_angleRange = 0;
			_duration = duration;
			_durationRange = durationRange;
			_ease = ease;
			return this;
		}
		
		/**
		 * Sets the gravity range of this particle type.
		 * @param	gravity			Gravity amount to affect to the particle y velocity.
		 * @param	gravityRange	Random amount to add to the particle's gravity.
		 * @return	This ParticleType object.
		 */
		public function setGravity(gravity:Number = 0, gravityRange:Number = 0):ParticleType
		{
			_gravity = gravity;
			_gravityRange = gravityRange;
			return this;
		}
		
		/**
		 * Sets the alpha range of this particle type.
		 * @param	start		The starting alpha.
		 * @param	finish		The finish alpha.
		 * @param	ease		Optional easer function.
		 * @return	This ParticleType object.
		 */
		public function setAlpha(start:Number = 1, finish:Number = 0, ease:Function = null):ParticleType
		{
			start = start < 0 ? 0 : (start > 1 ? 1 : start);
			finish = finish < 0 ? 0 : (finish > 1 ? 1 : finish);
			_alpha = start;
			_alphaRange = finish - start;
			_alphaEase = ease;
			createBuffer();
			return this;
		}
		
		/**
		 * Sets the color range of this particle type.
		 * @param	start		The starting color.
		 * @param	finish		The finish color.
		 * @param	ease		Optional easer function.
		 * @return	This ParticleType object.
		 */
		public function setColor(start:uint = 0xFFFFFF, finish:uint = 0, ease:Function = null):ParticleType
		{
			start &= 0xFFFFFF;
			finish &= 0xFFFFFF;
			_red = (start >> 16 & 0xFF) / 255;
			_green = (start >> 8 & 0xFF) / 255;
			_blue = (start & 0xFF) / 255;
			_redRange = (finish >> 16 & 0xFF) / 255 - _red;
			_greenRange = (finish >> 8 & 0xFF) / 255 - _green;
			_blueRange = (finish & 0xFF) / 255 - _blue;
			_colorEase = ease;
			createBuffer();
			return this;
		}
		
		/** Creates the buffer if it doesn't exist. */
		protected function createBuffer():void
		{
			if (_buffer) return;
			_buffer = new BitmapData(_frame.width, _frame.height, true, 0);
			_bufferRect = _buffer.rect;
		}
		
		// Particle information.
		internal var _name:String;
		internal var _source:BitmapData;
		internal var _width:uint;
		internal var _frame:Rectangle;
		internal var _frames:Array;
		internal var _frameCount:uint;
		
		// Motion information.
		internal var _angle:Number;
		internal var _angleRange:Number;
		internal var _distance:Number;
		internal var _distanceRange:Number;
		internal var _duration:Number;
		internal var _durationRange:Number;
		internal var _ease:Function;
		
		// Gravity information.
		internal var _gravity:Number = 0;
		internal var _gravityRange:Number = 0;
		
		// Alpha information.
		internal var _alpha:Number = 1;
		internal var _alphaRange:Number = 0;
		internal var _alphaEase:Function;
		
		// Color information.
		internal var _red:Number = 1;
		internal var _redRange:Number = 0;
		internal var _green:Number = 1;
		internal var _greenRange:Number = 0;
		internal var _blue:Number = 1;
		internal var _blueRange:Number = 0;
		internal var _colorEase:Function;
		
		// Buffer information.
		internal var _buffer:BitmapData;
		internal var _bufferRect:Rectangle;
	}
}