package net.flashpunk.graphics 
{
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import net.flashpunk.FP;
	import net.flashpunk.Graphic;

	/**
	 * Particle emitter used for emitting and rendering particle sprites.
	 * Good rendering performance with large amounts of particles.
	 */
	public class Emitter extends Graphic
	{
		/**
		 * Constructor. Sets the source image to use for newly added particle types.
		 * @param	source			Source image.
		 * @param	frameWidth		Frame width.
		 * @param	frameHeight		Frame height.
		 */
		public function Emitter(source:*, frameWidth:uint = 0, frameHeight:uint = 0) 
		{
			setSource(source, frameWidth, frameHeight);
			active = true;
		}
		
		/**
		 * Changes the source image to use for newly added particle types.
		 * @param	source			Source image.
		 * @param	frameWidth		Frame width.
		 * @param	frameHeight		Frame height.
		 */
		public function setSource(source:*, frameWidth:uint = 0, frameHeight:uint = 0):void
		{
			if (source is Class) _source = FP.getBitmap(source);
			else if (source is BitmapData) _source = source;
			if (!_source) throw new Error("Invalid source image.");
			_width = _source.width;
			_height = _source.height;
			_frameWidth = frameWidth ? frameWidth : _width;
			_frameHeight = frameHeight ? frameHeight : _height;
			_frameCount = uint(_width / _frameWidth) * uint(_height / _frameHeight);
		}
		
		override public function update():void 
		{
			// quit if there are no particles
			if (!_particle) return;
			
			// particle info
			var e:Number = FP.timeInFrames ? 1 : FP.elapsed,
				p:Particle = _particle,
				n:Particle;
			
			// loop through the particles
			while (p)
			{
				// update time scale
				p._time += e;
				
				// remove on time-out
				if (p._time >= p._duration)
				{
					if (p._next) p._next._prev = p._prev;
					if (p._prev) p._prev._next = p._next;
					else _particle = p._next;
					n = p._next;
					p._next = _cache;
					p._prev = null;
					_cache = p;
					p = n;
					_particleCount --;
					continue;
				}
				
				// get next particle
				p = p._next;
			}
		}
		
		/** @private Renders the particles. */
		override public function render(target:BitmapData, point:Point, camera:Point):void 
		{
			// quit if there are no particles
			if (!_particle) return;
			
			// get rendering position
			_point.x = point.x + x - camera.x * scrollX;
			_point.y = point.y + y - camera.y * scrollY;
			
			// particle info
			var t:Number, td:Number,
				p:Particle = _particle,
				type:ParticleType,
				rect:Rectangle;
			
			// loop through the particles
			while (p)
			{
				// get time scale
				t = p._time / p._duration;
				
				// get particle type
				type = p._type;
				rect = type._frame;
				
				// get position
				td = (type._ease == null) ? t : type._ease(t);
				_p.x = _point.x + p._x + p._moveX * td;
				_p.y = _point.y + p._y + p._moveY * td + p._gravity * td * td;
				
				// get frame
				rect.x = rect.width * type._frames[uint(td * type._frameCount)];
				rect.y = uint(rect.x / type._width) * rect.height;
				rect.x %= type._width;
				
				// draw particle
				if (type._buffer)
				{
					// get alpha
					var alphaT:Number = (type._alphaEase == null) ? t : type._alphaEase(t);
					_tint.alphaMultiplier = type._alpha + type._alphaRange * alphaT;
					
					// get color
					td = (type._colorEase == null) ? t : type._colorEase(t);
					_tint.redMultiplier = type._red + type._redRange * td;
					_tint.greenMultiplier = type._green + type._greenRange * td;
					_tint.blueMultiplier  = type._blue + type._blueRange * td;
					type._buffer.fillRect(type._bufferRect, 0);
					type._buffer.copyPixels(type._source, rect, FP.zero);
					type._buffer.colorTransform(type._bufferRect, _tint);
					
					// draw particle
					target.copyPixels(type._buffer, type._bufferRect, _p, null, null, true);
				}
				else target.copyPixels(type._source, rect, _p, null, null, true);
				
				// get next particle
				p = p._next;
			}
		}
		
		/**
		 * Creates a new Particle type for this Emitter.
		 * @param	name		Name of the particle type.
		 * @param	frames		Array of frame indices for the particles to animate.
		 * @return	A new ParticleType object.
		 */
		public function newType(name:String, frames:Array = null):ParticleType
		{
			if (! frames) frames = [0];
			if (_types[name]) throw new Error("Cannot add multiple particle types of the same name");
			return (_types[name] = new ParticleType(name, frames, _source, _frameWidth, _frameHeight));
		}
		
		/**
		 * Defines the motion range for a particle type.
		 * @param	name			The particle type.
		 * @param	angle			Launch Direction.
		 * @param	distance		Distance to travel.
		 * @param	duration		Particle duration.
		 * @param	angleRange		Random amount to add to the particle's direction.
		 * @param	distanceRange	Random amount to add to the particle's distance.
		 * @param	durationRange	Random amount to add to the particle's duration.
		 * @param	ease			Optional easer function.
		 * @return	This ParticleType object.
		 */
		public function setMotion(name:String, angle:Number, distance:Number, duration:Number, angleRange:Number = 0, distanceRange:Number = 0, durationRange:Number = 0, ease:Function = null):ParticleType
		{
			return (_types[name] as ParticleType).setMotion(angle, distance, duration, angleRange, distanceRange, durationRange, ease);
		}
		
		/**
		 * Sets the gravity range for a particle type.
		 * @param	name			The particle type.
		 * @param	gravity			Gravity amount to affect to the particle y velocity.
		 * @param	gravityRange	Random amount to add to the particle's gravity.
		 * @return	This ParticleType object.
		 */
		public function setGravity(name:String, gravity:Number = 0, gravityRange:Number = 0):ParticleType
		{
			return (_types[name] as ParticleType).setGravity(gravity, gravityRange);
		}
		
		/**
		 * Sets the alpha range of the particle type.
		 * @param	name		The particle type.
		 * @param	start		The starting alpha.
		 * @param	finish		The finish alpha.
		 * @param	ease		Optional easer function.
		 * @return	This ParticleType object.
		 */
		public function setAlpha(name:String, start:Number = 1, finish:Number = 0, ease:Function = null):ParticleType
		{
			return (_types[name] as ParticleType).setAlpha(start, finish, ease);
		}
		
		/**
		 * Sets the color range of the particle type.
		 * @param	name		The particle type.
		 * @param	start		The starting color.
		 * @param	finish		The finish color.
		 * @param	ease		Optional easer function.
		 * @return	This ParticleType object.
		 */
		public function setColor(name:String, start:uint = 0xFFFFFF, finish:uint = 0, ease:Function = null):ParticleType
		{
			return (_types[name] as ParticleType).setColor(start, finish, ease);
		}
		
		/**
		 * Emits a particle.
		 * @param	name		Particle type to emit.
		 * @param	x			X point to emit from.
		 * @param	y			Y point to emit from.
		 * @return
		 */
		public function emit(name:String, x:Number, y:Number):Particle
		{
			if (!_types[name]) throw new Error("Particle type \"" + name + "\" does not exist.");
			var p:Particle, type:ParticleType = _types[name];
			
			if (_cache)
			{
				p = _cache;
				_cache = p._next;
			}
			else p = new Particle;
			p._next = _particle;
			p._prev = null;
			if (p._next) p._next._prev = p;
			
			p._type = type;
			p._time = 0;
			p._duration = type._duration + type._durationRange * FP.random;
			var a:Number = type._angle + type._angleRange * FP.random,
				d:Number = type._distance + type._distanceRange * FP.random;
			p._moveX = Math.cos(a) * d;
			p._moveY = Math.sin(a) * d;
			p._x = x;
			p._y = y;
			p._gravity = type._gravity + type._gravityRange * FP.random;
			_particleCount ++;
			return (_particle = p);
		}
		
		/**
		 * Amount of currently existing particles.
		 */
		public function get particleCount():uint { return _particleCount; }
		
		// Particle information.
		/** @private */ private var _types:Object = { };
		/** @private */ private var _particle:Particle;
		/** @private */ private var _cache:Particle;
		/** @private */ private var _particleCount:uint;
		
		// Source information.
		/** @private */ private var _source:BitmapData;
		/** @private */ private var _width:uint;
		/** @private */ private var _height:uint;
		/** @private */ private var _frameWidth:uint;
		/** @private */ private var _frameHeight:uint;
		/** @private */ private var _frameCount:uint;
		
		// Drawing information.
		/** @private */ private var _p:Point = new Point;
		/** @private */ private var _tint:ColorTransform = new ColorTransform;
	}
}
