package net.flashpunk.graphics 
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.flashpunk.FP;
	import net.flashpunk.Graphic;
	
	/**
	 * A  multi-purpose drawing canvas, can be sized beyond the normal Flash BitmapData limits.
	 */
	public class Canvas extends Graphic
	{
		/**
		 * Optional blend mode to use (see flash.display.BlendMode for blending modes).
		 */
		public var blend:String;
		
		/**
		 * Constructor.
		 * @param	width		Width of the canvas.
		 * @param	height		Height of the canvas.
		 */
		public function Canvas(width:uint, height:uint) 
		{
			_width = width;
			_height = height;
			_refWidth = Math.ceil(width / _maxWidth);
			_refHeight = Math.ceil(height / _maxHeight);
			_ref = new BitmapData(_refWidth, _refHeight, false, 0);
			var x:uint, y:uint, w:uint, h:uint, i:uint,
				ww:uint = _width % _maxWidth,
				hh:uint = _height % _maxHeight;
			if (!ww) ww = _maxWidth;
			if (!hh) hh = _maxHeight;
			while (y < _refHeight)
			{
				h = y < _refHeight - 1 ? _maxHeight : hh;
				while (x < _refWidth)
				{
					w = x < _refWidth - 1 ? _maxWidth : ww;
					_ref.setPixel(x, y, i);
					_buffers[i] = new BitmapData(w, h, true, 0);
					i ++; x ++;
				}
				x = 0; y ++;
			}
		}
		
		/** @private Renders the canvas. */
		override public function render(point:Point, camera:Point):void 
		{
			// determine drawing location
			point.x += x - camera.x * scrollX;
			point.y += y - camera.y * scrollY;
			
			// render the buffers
			var xx:int, yy:int, buffer:BitmapData, px:Number = point.x;
			while (yy < _refHeight)
			{
				while (xx < _refWidth)
				{
					buffer = _buffers[_ref.getPixel(xx, yy)];
					if (_tint || blend)
					{
						_matrix.tx = point.x;
						_matrix.ty = point.y;
						FP.buffer.draw(buffer, _matrix, _tint, blend);
					}
					else FP.buffer.copyPixels(buffer, buffer.rect, point, null, null, true);
					point.x += _maxWidth;
					xx ++;
				}
				point.x = px;
				point.y += _maxHeight;
				xx = 0;
				yy ++;
			}
		}
		
		/**
		 * Draws to the canvas.
		 * @param	x			X position to draw.
		 * @param	y			Y position to draw.
		 * @param	source		Source BitmapData.
		 * @param	rect		Optional area of the source image to draw from. If null, the entire BitmapData will be drawn.
		 */
		public function draw(x:int, y:int, source:BitmapData, rect:Rectangle = null):void
		{
			var xx:int, yy:int;
			for each (var buffer:BitmapData in _buffers)
			{
				_point.x = x - xx;
				_point.y = y - yy;
				buffer.copyPixels(source, rect ? rect : source.rect, _point, null, null, true);
				xx += _maxWidth;
				if (xx >= _width)
				{
					xx = 0;
					yy += _maxHeight;
				}
			}
		}
		
		/**
		 * Fills the rectangular area of the canvas.
		 * @param	rect		Fill rectangle.
		 * @param	color		Fill color.
		 * @param	alpha		Fill alpha.
		 */
		public function fill(rect:Rectangle, color:uint = 0, alpha:Number = 1):void
		{
			var xx:int, yy:int, buffer:BitmapData;
			if (alpha >= 1)
			{
				_rect.width = rect.width;
				_rect.height = rect.height;
				
				for each (buffer in _buffers)
				{
					_rect.x = rect.x - xx;
					_rect.y = rect.y - yy;
					buffer.fillRect(_rect, 0xFF000000 | color);
					xx += _maxWidth;
					if (xx >= _width)
					{
						xx = 0;
						yy += _maxHeight;
					}
				}
				return;
			}
			for each (buffer in _buffers)
			{
				_graphics.clear();
				_graphics.beginFill(color, alpha);
				_graphics.drawRect(rect.x - xx, rect.y - yy, rect.width, rect.height);
				buffer.draw(FP.sprite);
				xx += _maxWidth;
				if (xx >= _width)
				{
					xx = 0;
					yy += _maxHeight;
				}
			}
			_graphics.endFill();
		}
		
		/**
		 * Fills the rectangle area of the canvas with the texture.
		 * @param	rect		Fill rectangle.
		 * @param	texture		Fill texture.
		 */
		public function fillTexture(rect:Rectangle, texture:BitmapData):void
		{
			var xx:int, yy:int;
			for each (var buffer:BitmapData in _buffers)
			{
				_graphics.clear();
				_graphics.beginBitmapFill(texture);
				_graphics.drawRect(rect.x - xx, rect.y - yy, rect.width, rect.height);
				buffer.draw(FP.sprite);
				xx += _maxWidth;
				if (xx >= _width)
				{
					xx = 0;
					yy += _maxHeight;
				}
			}
			_graphics.endFill();
		}
		
		/**
		 * Draws the Graphic object to the canvas.
		 * @param	x			X position to draw.
		 * @param	y			Y position to draw.
		 * @param	source		Graphic to draw.
		 */
		public function drawGraphic(x:int, y:int, source:Graphic):void
		{
			var temp:BitmapData = FP.buffer, xx:int, yy:int;
			for each (var buffer:BitmapData in _buffers)
			{
				FP.buffer = buffer;
				_point.x = x - xx;
				_point.y = y - yy;
				source.render(_point, FP.zero);
				xx += _maxWidth;
				if (xx >= _width)
				{
					xx = 0;
					yy += _maxHeight;
				}
			}
			FP.buffer = temp;
		}
		
		/**
		 * The tinted color of the Canvas. Use 0xFFFFFF to draw the it normally.
		 */
		public function get color():uint { return _color; }
		public function set color(value:uint):void
		{
			value %= 0xFFFFFF;
			if (_color == value) return;
			_color = value;
			if (_alpha == 1 && _color == 0xFFFFFF)
			{
				_tint = null;
				return;
			}
			_tint = _colorTransform;
			_tint.redMultiplier = (_color >> 16 & 0xFF) / 255;
			_tint.greenMultiplier = (_color >> 8 & 0xFF) / 255;
			_tint.blueMultiplier = (_color & 0xFF) / 255;
			_tint.alphaMultiplier = _alpha;
		}
		
		/**
		 * Change the opacity of the Canvas, a value from 0 to 1.
		 */
		public function get alpha():Number { return _alpha; }
		public function set alpha(value:Number):void
		{
			if (value < 0) value = 0;
			if (value > 1) value = 1;
			if (_alpha == value) return;
			_alpha = value;
			if (_alpha == 1 && _color == 0xFFFFFF)
			{
				_tint = null;
				return;
			}
			_tint = _colorTransform;
			_tint.redMultiplier = (_color >> 16 & 0xFF) / 255;
			_tint.greenMultiplier = (_color >> 8 & 0xFF) / 255;
			_tint.blueMultiplier = (_color & 0xFF) / 255;
			_tint.alphaMultiplier = _alpha;
		}
		
		/**
		 * Width of the canvas.
		 */
		public function get width():uint { return _width; }
		
		/**
		 * Height of the canvas.
		 */
		public function get height():uint { return _height; }
		
		// Buffer information.
		/** @private */ private var _buffers:Vector.<BitmapData> = new Vector.<BitmapData>;
		/** @private */ protected var _width:uint;
		/** @private */ protected var _height:uint;
		/** @private */ protected var _maxWidth:uint = 4000;
		/** @private */ protected var _maxHeight:uint = 4000;
		
		// Color tinting information.
		/** @private */ private var _color:uint = 0xFFFFFF;
		/** @private */ private var _alpha:Number = 1;
		/** @private */ private var _tint:ColorTransform;
		/** @private */ private var _colorTransform:ColorTransform = new ColorTransform;
		/** @private */ private var _matrix:Matrix = new Matrix;
		
		// Canvas reference information.
		/** @private */ private var _ref:BitmapData;
		/** @private */ private var _refWidth:uint;
		/** @private */ private var _refHeight:uint;
		
		// Global objects.
		/** @private */ private var _point:Point = FP.point;
		/** @private */ private var _rect:Rectangle = new Rectangle;
		/** @private */ private var _graphics:Graphics = FP.sprite.graphics;
	}
}