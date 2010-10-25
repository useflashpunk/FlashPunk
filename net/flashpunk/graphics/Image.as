package net.flashpunk.graphics 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.flashpunk.*;
	
	/**
	 * Performance-optimized non-animated image. Can be drawn to the screen with transformations.
	 */
	public class Image extends Graphic
	{
		/**
		 * Rotation of the image, in degrees.
		 */
		public var angle:Number = 0;
		
		/**
		 * Scale of the image, effects both x and y scale.
		 */
		public var scale:Number = 1;
		
		/**
		 * X scale of the image.
		 */
		public var scaleX:Number = 1;
		
		/**
		 * Y scale of the image.
		 */
		public var scaleY:Number = 1;
		
		/**
		 * X origin of the image, determines transformation point.
		 */
		public var originX:int;
		
		/**
		 * Y origin of the image, determines transformation point.
		 */
		public var originY:int;
		
		/**
		 * Optional blend mode to use when drawing this image.
		 * Use constants from the flash.display.BlendMode class.
		 */
		public var blend:String;
		
		/**
		 * If the image should be drawn transformed with pixel smoothing.
		 * This will affect drawing performance, but look less pixelly.
		 */
		public var smooth:Boolean;
		
		/**
		 * Constructor.
		 * @param	source		Source image.
		 * @param	clipRect	Optional rectangle defining area of the source image to draw.
		 */
		public function Image(source:* = null, clipRect:Rectangle = null) 
		{
			if (source is Class)
			{
				_source = FP.getBitmap(source);
				_class = String(source);
			}
			else if (source is BitmapData) _source = source;
			if (!_source) throw new Error("Invalid source image.");
			_sourceRect = _source.rect;
			if (clipRect)
			{
				if (!clipRect.width) clipRect.width = _sourceRect.width;
				if (!clipRect.height) clipRect.height = _sourceRect.height;
				_sourceRect = clipRect;
			}
			createBuffer();
			updateBuffer();
		}
		
		/** @private Creates the buffer. */
		protected function createBuffer():void
		{
			_buffer = new BitmapData(_sourceRect.width, _sourceRect.height, true, 0);
			_bufferRect = _buffer.rect;
			_bitmap.bitmapData = _buffer;
		}
		
		/** @private Renders the image. */
		override public function render(target:BitmapData, point:Point, camera:Point):void 
		{
			// quit if no graphic is assigned
			if (!_buffer) return;
			
			// determine drawing location
			_point.x = point.x + x - camera.x * scrollX;
			_point.y = point.y + y - camera.y * scrollY;
			
			// render without transformation
			if (angle == 0 && scaleX * scale == 1 && scaleY * scale == 1 && !blend)
			{
				target.copyPixels(_buffer, _bufferRect, _point, null, null, true);
				return;
			}
			
			// render with transformation
			_matrix.b = _matrix.c = 0;
			_matrix.a = scaleX * scale;
			_matrix.d = scaleY * scale;
			_matrix.tx = -originX * _matrix.a;
			_matrix.ty = -originY * _matrix.d;
			if (angle != 0) _matrix.rotate(angle * FP.RAD);
			_matrix.tx += originX + _point.x;
			_matrix.ty += originY + _point.y;
			target.draw(_bitmap, _matrix, null, blend, null, smooth);
		}
		
		/**
		 * Creates a new rectangle Image.
		 * @param	width		Width of the rectangle.
		 * @param	height		Height of the rectangle.
		 * @param	color		Color of the rectangle.
		 * @return	A new Image object.
		 */
		public static function createRect(width:uint, height:uint, color:uint = 0xFFFFFF):Image
		{
			var source:BitmapData = new BitmapData(width, height, true, 0xFF000000 | color);
			return new Image(source);
		}
		
		/**
		 * Creates a new circle Image.
		 * @param	radius		Radius of the circle.
		 * @param	color		Color of the circle.
		 * @return	A new Circle object.
		 */
		public static function createCircle(radius:uint, color:uint = 0xFFFFFF):Image
		{
			FP.sprite.graphics.clear();
			FP.sprite.graphics.beginFill(color);
			FP.sprite.graphics.drawCircle(radius, radius, radius);
			var data:BitmapData = new BitmapData(radius * 2, radius * 2, true, 0);
			data.draw(FP.sprite);
			return new Image(data);
		}
		
		/**
		 * Updates the image buffer.
		 */
		public function updateBuffer(clearBefore:Boolean = false):void
		{
			if (!_source) return;
			if (clearBefore) _buffer.fillRect(_bufferRect, 0);
			_buffer.copyPixels(_source, _sourceRect, FP.zero);
			if (_tint) _buffer.colorTransform(_bufferRect, _tint);
		}
		
		/**
		 * Clears the image buffer.
		 */
		public function clear():void
		{
			_buffer.fillRect(_bufferRect, 0);
		}
		
		/**
		 * Change the opacity of the Image, a value from 0 to 1.
		 */
		public function get alpha():Number { return _alpha; }
		public function set alpha(value:Number):void
		{
			value = value < 0 ? 0 : (value > 1 ? 1 : value);
			if (_alpha == value) return;
			_alpha = value;
			if (_alpha == 1 && _color == 0xFFFFFF)
			{
				_tint = null;
				return updateBuffer();
			}
			_tint = _colorTransform;
			_tint.redMultiplier = (_color >> 16 & 0xFF) / 255;
			_tint.greenMultiplier = (_color >> 8 & 0xFF) / 255;
			_tint.blueMultiplier = (_color & 0xFF) / 255;
			_tint.alphaMultiplier = _alpha;
			updateBuffer();
		}
		
		/**
		 * The tinted color of the Image. Use 0xFFFFFF to draw the Image normally.
		 */
		public function get color():uint { return _color; }
		public function set color(value:uint):void
		{
			value &= 0xFFFFFF;
			if (_color == value) return;
			_color = value;
			if (_alpha == 1 && _color == 0xFFFFFF)
			{
				_tint = null;
				return updateBuffer();
			}
			_tint = _colorTransform;
			_tint.redMultiplier = (_color >> 16 & 0xFF) / 255;
			_tint.greenMultiplier = (_color >> 8 & 0xFF) / 255;
			_tint.blueMultiplier = (_color & 0xFF) / 255;
			_tint.alphaMultiplier = _alpha;
			updateBuffer();
		}
		
		/**
		 * If you want to draw the Image horizontally flipped. This is
		 * faster than setting scaleX to -1 if your image isn't transformed.
		 */
		public function get flipped():Boolean { return _flipped; }
		public function set flipped(value:Boolean):void
		{
			if (_flipped == value || !_class) return;
			_flipped = value;
			var temp:BitmapData = _source;
			if (!value || _flip)
			{
				_source = _flip;
				_flip = temp;
				return updateBuffer();
			}
			if (_flips[_class])
			{
				_source = _flips[_class];
				_flip = temp;
				return updateBuffer();
			}
			_source = _flips[_class] = new BitmapData(_source.width, _source.height, true, 0);
			_flip = temp;
			FP.matrix.identity();
			FP.matrix.a = -1;
			FP.matrix.tx = _source.width;
			_source.draw(temp, FP.matrix);
			updateBuffer();
		}
		
		/**
		 * Centers the Image's originX/Y to its center.
		 */
		public function centerOrigin():void
		{
			originX = _bufferRect.width / 2;
			originY = _bufferRect.height / 2;
		}
		
		/**
		 * Centers the Image's originX/Y to its center, and negates the offset by the same amount.
		 */
		public function centerOO():void
		{
			x += originX;
			y += originY;
			centerOrigin();
			x -= originX;
			y -= originY;
		}
		
		/**
		 * Width of the image.
		 */
		public function get width():uint { return _bufferRect.width; }
		
		/**
		 * Height of the image.
		 */
		public function get height():uint { return _bufferRect.height; }
		
		/**
		 * The scaled width of the image.
		 */
		public function get scaledWidth():uint { return _bufferRect.width * scaleX * scale; }
		
		/**
		 * The scaled height of the image.
		 */
		public function get scaledHeight():uint { return _bufferRect.height * scaleY * scale; }
		
		/**
		 * Clipping rectangle for the image.
		 */
		public function get clipRect():Rectangle { return _sourceRect; }
		
		/** @private Source BitmapData image. */
		protected function get source():BitmapData { return _source; }
		
		// Source and buffer information.
		/** @private */ protected var _source:BitmapData;
		/** @private */ protected var _sourceRect:Rectangle;
		/** @private */ protected var _buffer:BitmapData;
		/** @private */ protected var _bufferRect:Rectangle;
		/** @private */ protected var _bitmap:Bitmap = new Bitmap;
		
		// Color and alpha information.
		/** @private */ private var _alpha:Number = 1;
		/** @private */ private var _color:uint = 0x00FFFFFF;
		/** @private */ protected var _tint:ColorTransform;
		/** @private */ private var _colorTransform:ColorTransform = new ColorTransform;
		/** @private */ private var _matrix:Matrix = FP.matrix;
		
		// Flipped image information.
		/** @private */ private var _class:String;
		/** @private */ protected var _flipped:Boolean;
		/** @private */ private var _flip:BitmapData;
		/** @private */ private static var _flips:Object = { };
	}
}