package net.flashpunk
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.geom.Matrix;

	import net.flashpunk.graphics.Image;

	/**
	 * Container for the main screen buffer. Can be used to transform the screen.
	 */
	public class Screen
	{
		/**
		 * Constructor.
		 */
		public function Screen() 
		{
			// create screen buffers
			_bitmap[0] = new Bitmap(new BitmapData(FP.width, FP.height, false, _color), PixelSnapping.NEVER);
			_bitmap[1] = new Bitmap(new BitmapData(FP.width, FP.height, false, _color), PixelSnapping.NEVER);
			FP.engine.addChild(_sprite);
			_sprite.addChild(_bitmap[0]).visible = true;
			_sprite.addChild(_bitmap[1]).visible = false;
			FP.buffer = _bitmap[0].bitmapData;
			_width = FP.width;
			_height = FP.height;
			update();
		}
		
		/**
		 * Swaps screen buffers.
		 */
		public function swap():void
		{
			_current = 1 - _current;
			FP.buffer = _bitmap[_current].bitmapData;
		}
		
		/**
		 * Refreshes the screen.
		 */
		public function refresh():void
		{
			// refreshes the screen
			FP.buffer.fillRect(FP.bounds, _color);
		}
		
		/**
		 * Redraws the screen.
		 */
		public function redraw():void
		{
			// refresh the buffers
			_bitmap[_current].visible = true;
			_bitmap[1 - _current].visible = false;
		}
		
		/** @private Re-applies transformation matrix. */
		public function update():void
		{
			_matrix.b = _matrix.c = 0;
			_matrix.a = _scaleX * _scale;
			_matrix.d = _scaleY * _scale;
			_matrix.tx = -_originX * _matrix.a;
			_matrix.ty = -_originY * _matrix.d;
			if (_angle != 0) _matrix.rotate(_angle);
			_matrix.tx += _originX * _scaleX * _scale + _x;
			_matrix.ty += _originY * _scaleX * _scale + _y;
			_sprite.transform.matrix = _matrix;
		}
		
		/**
		 * Refresh color of the screen.
		 */
		public function get color():uint { return _color; }
		public function set color(value:uint):void { _color = 0xFF000000 | value; }
		
		/**
		 * X offset of the screen.
		 */
		public function get x():int { return _x; }
		public function set x(value:int):void
		{
			if (_x == value) return;
			_x = value;
			update();
		}
		
		/**
		 * Y offset of the screen.
		 */
		public function get y():int { return _y; }
		public function set y(value:int):void
		{
			if (_y == value) return;
			_y = value;
			update();
		}
		
		/**
		 * X origin of transformations.
		 */
		public function get originX():int { return _originX; }
		public function set originX(value:int):void
		{
			if (_originX == value) return;
			_originX = value;
			update();
		}
		
		/**
		 * Y origin of transformations.
		 */
		public function get originY():int { return _originY; }
		public function set originY(value:int):void
		{
			if (_originY == value) return;
			_originY = value;
			update();
		}
		
		/**
		 * X scale of the screen.
		 */
		public function get scaleX():Number { return _scaleX; }
		public function set scaleX(value:Number):void
		{
			if (_scaleX == value) return;
			_scaleX = value;
			update();
		}
		
		/**
		 * Y scale of the screen.
		 */
		public function get scaleY():Number { return _scaleY; }
		public function set scaleY(value:Number):void
		{
			if (_scaleY == value) return;
			_scaleY = value;
			update();
		}
		
		/**
		 * Scale factor of the screen. Final scale is scaleX * scale by scaleY * scale, so
		 * you can use this factor to scale the screen both horizontally and vertically.
		 */
		public function get scale():Number { return _scale; }
		public function set scale(value:Number):void
		{
			if (_scale == value) return;
			_scale = value;
			update();
		}
		
		/**
		 * Rotation of the screen, in degrees.
		 */
		public function get angle():Number { return _angle * FP.DEG; }
		public function set angle(value:Number):void
		{
			if (_angle == value * FP.RAD) return;
			_angle = value * FP.RAD;
			update();
		}
		
		/**
		 * Whether screen smoothing should be used or not.
		 */
		public function get smoothing():Boolean { return _bitmap[0].smoothing; }
		public function set smoothing(value:Boolean):void { _bitmap[0].smoothing = _bitmap[1].smoothing = value; }
		
		/**
		 * Width of the screen.
		 */
		public function get width():uint { return _width; }
		
		/**
		 * Height of the screen.
		 */
		public function get height():uint { return _height; }
		
		/**
		 * X position of the mouse on the screen.
		 */
		public function get mouseX():int { return (FP.stage.mouseX - _x) / (_scaleX * _scale); }
		
		/**
		 * Y position of the mouse on the screen.
		 */
		public function get mouseY():int { return (FP.stage.mouseY - _y) / (_scaleY * _scale); }
		
		/**
		 * Captures the current screen as an Image object.
		 * @return	A new Image object.
		 */
		public function capture():Image
		{
			return new Image(_bitmap[_current].bitmapData.clone());
		}
		
		// Screen information.
		/** @private */ private var _sprite:Sprite = new Sprite;
		/** @private */ private var _bitmap:Vector.<Bitmap> = new Vector.<Bitmap>(2);
		/** @private */ private var _current:int = 0;
		/** @private */ private var _matrix:Matrix = new Matrix;
		/** @private */ private var _x:int;
		/** @private */ private var _y:int;
		/** @private */ private var _width:uint;
		/** @private */ private var _height:uint;
		/** @private */ private var _originX:int;
		/** @private */ private var _originY:int;
		/** @private */ private var _scaleX:Number = 1;
		/** @private */ private var _scaleY:Number = 1;
		/** @private */ private var _scale:Number = 1;
		/** @private */ private var _angle:Number = 0;
		/** @private */ private var _color:uint = 0xFF202020;
	}
}
