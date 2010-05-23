package net.flashpunk 
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.system.System;
	import net.flashpunk.*;
	
	/**
	 * Static catch-all class used to access global properties and functions.
	 */
	public class FP 
	{
		/**
		 * The FlashPunk major version.
		 */
		public static const VERSION:String = "1.0";
		
		/**
		 * Width of the game.
		 */
		public static var width:uint;
		
		/**
		 * Height of the game.
		 */
		public static var height:uint;
		
		/**
		 * If the game is running at a fixed framerate.
		 */
		public static var fixed:Boolean;
		
		/**
		 * The framerate assigned to the stage.
		 */
		public static var frameRate:Number;
		
		/**
		 * Time elapsed since the last frame (non-fixed framerate only).
		 */
		public static var elapsed:Number;
		
		/**
		 * Timescale applied to FP.elapsed (non-fixed framerate only).
		 */
		public static var rate:Number = 1;
		
		/**
		 * The Screen object, use to transform or offset the Screen.
		 */
		public static var screen:Screen;
		
		/**
		 * The current screen buffer, drawn to in the render loop.
		 */
		public static var buffer:BitmapData;
		
		/**
		 * A rectangle representing the size of the screen.
		 */
		public static var bounds:Rectangle;
		
		/**
		 * Point used to determine drawing offset in the render loop.
		 */
		public static var camera:Point = new Point;
		
		/**
		 * The currently active World object. When you set this, the World is flagged
		 * to switch, but won't actually do so until the end of the current frame.
		 */
		public static function get world():World { return _world; }
		public static function set world(value:World):void
		{
			if (_world == value) return;
			_goto = value;
		}
		
		// switches world, optionally inheriting entities
		/**
		 * Switches the current World at the end of the frame. Call this only if
		 * you want to use Entity persistence, otherwise just assign FP.world.
		 * @param	to				The World to switch to.
		 * @param	inheritAll		If all Entities (not just persistent ones) should be inherited.
		 */
		public static function switchWorld(to:World, inheritAll:Boolean = false):void
		{
			if (_world == to) return;
			to._inherit = true;
			to._inheritAll = inheritAll;
			_goto = to;
		}
		
		/**
		 * Global volume factor for all sounds, a value from 0 to 1.
		 */
		public static function get volume():Number { return _volume; }
		public static function set volume(value:Number):void
		{
			if (value < 0) value = 0;
			if (_volume == value) return;
			_soundTransform.volume = _volume = value;
			SoundMixer.soundTransform = _soundTransform;
		}
		
		/**
		 * Global panning factor for all sounds, a value from -1 to 1.
		 */
		public static function get pan():Number { return _pan; }
		public static function set pan(value:Number):void
		{
			if (value < -1) value = -1;
			if (value > 1) value = 1;
			if (_pan == value) return;
			_soundTransform.pan = _pan = value;
			SoundMixer.soundTransform = _soundTransform;
		}
		
		/**
		 * Randomly chooses and returns one of the provided values.
		 * @param	...objs		The Objects you want to randomly choose from. Can be ints, Numbers, Points, etc.
		 * @return	A randomly chosen one of the provided parameters.
		 */
		public static function choose(...objs):*
		{
			return objs[int(objs.length * random)];
		}
		
		/**
		 * Finds the sign of the provided value.
		 * @param	value		The Number to evaluate.
		 * @return	1 if value > 0, -1 if value < 0, and 0 when value == 0.
		 */
		public static function sign(value:Number):int
		{
			return value < 0 ? -1 : (value > 0 ? 1 : 0);
		}
		
		/**
		 * Approaches the value towards the target, by the specified amount, without overshooting the target.
		 * @param	value	The starting value.
		 * @param	target	The target that you want value to approach.
		 * @param	amount	How much you want the value to approach target by.
		 * @return	The new value.
		 */
		public static function approach(value:Number, target:Number, amount:Number):Number
		{
			return value < target ? (target < value + amount ? target : value + amount) : (target > value - amount ? target : value - amount);
		}
		
		/**
		 * Finds the angle (in degrees) from point 1 to point 2.
		 * @param	x1		The first x-position.
		 * @param	y1		The first y-position.
		 * @param	x2		The second x-position.
		 * @param	y2		The second y-position.
		 * @return	The angle from (x1, y1) to (x2, y2).
		 */
		public static function angle(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
			var a:Number = Math.atan2(y2 - y1, x2 - x1) * DEG;
			return a < 0 ? a + 360 : a;
		}
		
		/**
		 * Sets the x/y values of the provided point to a vector of the specified angle and length.
		 * @param	point		The point object to return.
		 * @param	angle		The angle of the vector, in degrees.
		 * @param	length		The distance to the vector from (0, 0).
		 * @return	The point object with x/y set to the length and angle from (0, 0).
		 */
		public static function angleXY(point:Point, angle:Number, length:Number = 1):Point
		{
			angle *= RAD;
			point.x = Math.cos(angle) * length;
			point.y = Math.sin(angle) * length;
			return point;
		}
		
		/**
		 * Find the distance between two points.
		 * @param	x1		The first x-position.
		 * @param	y1		The first y-position.
		 * @param	x2		The second x-position.
		 * @param	y2		The second y-position.
		 * @return	The distance.
		 */
		public static function distance(x1:Number, y1:Number, x2:Number = 0, y2:Number = 0):Number
		{
			return Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
		}
		
		/**
		 * Find the distance between two rectangles. Will return 0 if the rectangles overlap.
		 * @param	x1		The x-position of the first rect.
		 * @param	y1		The y-position of the first rect.
		 * @param	w1		The width of the first rect.
		 * @param	h1		The height of the first rect.
		 * @param	x2		The x-position of the second rect.
		 * @param	y2		The y-position of the second rect.
		 * @param	w2		The width of the second rect.
		 * @param	h2		The height of the second rect.
		 * @return	The distance.
		 */
		public static function distanceRects(x1:Number, y1:Number, w1:Number, h1:Number, x2:Number, y2:Number, w2:Number, h2:Number):Number
		{
			if (x1 < x2 + w2 && x2 < x1 + w1)
			{
				if (y1 < y2 + h2 && y2 < y1 + h1) return 0;
				if (y1 > y2) return y1 - (y2 + h2);
				return y2 - (y1 + h1);
			}
			if (y1 < y2 + h2 && y2 < y1 + h1)
			{
				if (x1 > x2) return x1 - (x2 + w2);
				return x2 - (x1 + w1)
			}
			if (x1 > x2)
			{
				if (y1 > y2) return distance(x1, y1, (x2 + w2), (y2 + h2));
				return distance(x1, y1 + h1, x2 + w2, y2);
			}
			if (y1 > y2) return distance(x1 + w1, y1, x2, y2 + h2)
			return distance(x1 + w1, y1 + h1, x2, y2);
		}
		
		/**
		 * Find the distance between a point and a rectangle. Returns 0 if the point is within the rectangle.
		 * @param	px		The x-position of the point.
		 * @param	py		The y-position of the point.
		 * @param	rx		The x-position of the rect.
		 * @param	ry		The y-position of the rect.
		 * @param	rw		The width of the rect.
		 * @param	rh		The height of the rect.
		 * @return	The distance.
		 */
		public static function distanceRectPoint(px:Number, py:Number, rx:Number, ry:Number, rw:Number, rh:Number):Number
		{
			if (px >= rx && px <= rx + rw)
			{
				if (py >= ry && py <= ry + rh) return 0;
				if (py > ry) return py - (ry + rh);
				return ry - py;
			}
			if (py >= ry && py <= ry + rh)
			{
				if (px > rx) return px - (rx + rw);
				return rx - px;
			}
			if (px > rx)
			{
				if (py > ry) return distance(px, py, rx + rw, ry + rh);
				return distance(px, py, rx + rw, ry);
			}
			if (py > ry) return distance(px, py, rx, ry + rh)
			return distance(px, py, rx, ry);
		}
		
		/**
		 * Clamps the value within the minimum and maximum values.
		 * @param	value		The Number to evaluate.
		 * @param	min			The minimum range.
		 * @param	max			The maximum range.
		 * @return	The clamped value.
		 */
		public static function clamp(value:Number, min:Number, max:Number):Number
		{
			if (max > min)
			{
				value = value < max ? value : max;
				return value > min ? value : min;
			}
			value = value < min ? value : min;
			return value > max ? value : max;
		}
		
		/**
		 * Transfers a value from one scale to another scale. For example, scale(.5, 0, 1, 10, 20) == 15, and scale(3, 0, 5, 100, 0) == 40.
		 * @param	value		The value on the first scale.
		 * @param	min			The minimum range of the first scale.
		 * @param	max			The maximum range of the first scale.
		 * @param	min2		The minimum range of the second scale.
		 * @param	max2		The maximum range of the second scale.
		 * @return	The scaled value.
		 */
		public static function scale(value:Number, min:Number, max:Number, min2:Number, max2:Number):Number
		{
			return min2 + ((value - min) / (max - min)) * (max2 - min2);
		}
		
		/**
		 * Transfers a value from one scale to another scale, but clamps the return value within the second scale.
		 * @param	value		The value on the first scale.
		 * @param	min			The minimum range of the first scale.
		 * @param	max			The maximum range of the first scale.
		 * @param	min2		The minimum range of the second scale.
		 * @param	max2		The maximum range of the second scale.
		 * @return	The scaled and clamped value.
		 */
		public static function scaleClamp(value:Number, min:Number, max:Number, min2:Number, max2:Number):Number
		{
			value = min2 + ((value - min) / (max - min)) * (max2 - min2);
			if (max2 > min2)
			{
				value = value < max2 ? value : max2;
				return value > min2 ? value : min2;
			}
			value = value < min2 ? value : min2;
			return value > max2 ? value : max2;
		}
		
		/**
		 * The random seed used by FP's random functions.
		 */
		public static function get randomSeed():uint { return _getSeed; }
		public static function set randomSeed(value:uint):void
		{
			_seed = clamp(value, 1, 2147483646);
			_getSeed = _seed;
		}
		
		/**
		 * Randomizes the random seed using Flash's Math.random() function.
		 */
		public static function randomizeSeed():void
		{
			randomSeed = 2147483647 * Math.random();
		}
		
		/**
		 * A pseudo-random Number produced using FP's random seed, where 0 <= Number < 1.
		 */
		public static function get random():Number
		{
			_seed = (_seed * 16807) % 2147483647;
			return _seed / 2147483647;
		}
		
		/**
		 * Returns a pseudo-random uint.
		 * @param	amount		The returned uint will always be 0 <= uint < amount.
		 * @return	The uint.
		 */
		public static function rand(amount:uint):uint
		{
			_seed = (_seed * 16807) % 2147483647;
			return (_seed / 2147483647) * amount;
		}
		/**
		 * Creates a color value by combining the chosen RGB values.
		 * @param	R		The red value of the color, from 0 to 255.
		 * @param	G		The green value of the color, from 0 to 255.
		 * @param	B		The blue value of the color, from 0 to 255.
		 * @return	The color uint.
		 */
		public static function getColorRGB(R:uint = 0, G:uint = 0, B:uint = 0):uint
		{
			return R << 16 | G << 8 | B;
		}
		
		/**
		 * Finds the red factor of a color.
		 * @param	color		The color to evaluate.
		 * @return	A uint from 0 to 255.
		 */
		public static function getRed(color:uint):uint
		{
			return color >> 16 & 0xFF;
		}
		
		/**
		 * Finds the green factor of a color.
		 * @param	color		The color to evaluate.
		 * @return	A uint from 0 to 255.
		 */
		public static function getGreen(color:uint):uint
		{
			return color >> 8 & 0xFF;
		}
		
		/**
		 * Finds the blue factor of a color.
		 * @param	color		The color to evaluate.
		 * @return	A uint from 0 to 255.
		 */
		public static function getBlue(color:uint):uint
		{
			return color & 0xFF;
		}
		
		/**
		 * Fetches a stored BitmapData object represented by the source.
		 * @param	source		Embedded Bitmap class.
		 * @return	The stored BitmapData object.
		 */
		public static function getBitmap(source:Class):BitmapData
		{
			if (_bitmap[String(source)]) return _bitmap[String(source)];
			return (_bitmap[String(source)] = (new source).bitmapData);
		}
		
		/**
		 * Removes all nulls from the array.
		 * @param	a		The array to clean.
		 * @return	The provided array with nulls removed.
		 */
		public static function removeNulls(a:Array):Array
		{
			var i:int = 0,
				j:int = a.length;
			while (i < j)
			{
				while (a[i] != null) i ++;
				while (a[j] == null) j --;
				a[i] = a[j];
				a[j] = null;
			}
			a[j] = a[i];
			a[i] = null;
			a.length -= a.length - a.indexOf(null);
			return a;
		}
		
		/**
		 * Forces a garbage collector sweep.
		 */
		public static function cleanup():void
		{
			System.gc();
			System.gc();
		}
		
		// World information
		/** @private */ internal static var _world:World;
		/** @private */ internal static var _goto:World;
		
		// Bitmap storage.
		/** @private */ private static var _bitmap:Object = { };
		
		// Pseudo-random number generation (the seed is set in Engine's contructor).
		/** @private */ private static var _seed:uint = 0;
		/** @private */ private static var _getSeed:uint;
		
		// Volume control.
		/** @private */ private static var _volume:Number = 1;
		/** @private */ private static var _pan:Number = 0;
		/** @private */ private static var _soundTransform:SoundTransform = new SoundTransform;
		
		// Used for rad-to-deg and deg-to-rad conversion.
		/** @private */ public static const DEG:Number = -180 / Math.PI;
		/** @private */ public static const RAD:Number = Math.PI / -180;
		
		// Global Flash objects.
		/** @private */ public static var stage:Stage;
		/** @private */ public static var engine:Sprite;
		
		// Global objects used for rendering, collision, etc.
		/** @private */ public static var point:Point = new Point;
		/** @private */ public static var point2:Point = new Point;
		/** @private */ public static var zero:Point = new Point;
		/** @private */ public static var rect:Rectangle = new Rectangle;
		/** @private */ public static var matrix:Matrix = new Matrix;
		/** @private */ public static var sprite:Sprite = new Sprite;
		/** @private */ public static var entity:Entity;
	}
}