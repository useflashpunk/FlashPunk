package net.flashpunk.masks
{
	import flash.display.*;
	import flash.geom.*;
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	
	/**
	 * A bitmap mask used for pixel-perfect collision. 
	 */
	public class Pixelmask extends Hitbox
	{
		/**
		 * Alpha threshold of the bitmap used for collision.
		 */
		public var threshold:uint = 1;
		
		/**
		 * Constructor.
		 * @param	source		The image to use as a mask.
		 * @param	x			X offset of the mask.
		 * @param	y			Y offset of the mask.
		 */
		public function Pixelmask(source:*, x:int = 0, y:int = 0)
		{
			// fetch mask data
			if (source is BitmapData) _data = source;
			if (source is Class) _data = FP.getBitmap(source);
			if (source is Image) syncWith(source, x, y);
			else
			{
				if (!_data) throw new Error("Invalid Pixelmask source image.");
				
				// set mask properties
				_width = data.width;
				_height = data.height;
				_x = x;
				_y = y;
			}
			
			// set callback functions
			_check[Mask] = collideMask;
			_check[Pixelmask] = collidePixelmask;
			_check[Hitbox] = collideHitbox;
		}
		
		/** @private Collide against an Entity. */
		private function collideMask(other:Mask):Boolean
		{
			_point.x = parent.x + _x;
			_point.y = parent.y + _y;
			_rect.x = other.parent.x - other.parent.originX;
			_rect.y = other.parent.y - other.parent.originY;
			_rect.width = other.parent.width;
			_rect.height = other.parent.height;
			return _data.hitTest(_point, threshold, _rect);
		}
		
		/** @private Collide against a Hitbox. */
		private function collideHitbox(other:Hitbox):Boolean
		{
			_point.x = parent.x + _x;
			_point.y = parent.y + _y;
			_rect.x = other.parent.x + other._x;
			_rect.y = other.parent.y + other._y;
			_rect.width = other._width;
			_rect.height = other._height;
			return _data.hitTest(_point, threshold, _rect);
		}
		
		/** @private Collide against a Pixelmask. */
		private function collidePixelmask(other:Pixelmask):Boolean
		{
			_point.x = parent.x + _x;
			_point.y = parent.y + _y;
			_point2.x = other.parent.x + other._x;
			_point2.y = other.parent.y + other._y;
			return _data.hitTest(_point, threshold, other._data, _point2, other.threshold);
		}
		
		/**
		 * Synchronises the mask with an image matching it's dimensions and using
		 * it's content as the mask.
		 * @param	image		The image sync the mask with.
		 * @param	x			X offset of the mask.
		 * @param	y			Y offset of the mask.
		 */
		public function syncWith(image:Image, x:int=0, y:int=0):void
		{
		  // find the 4 corners of the image
			_point.x = -image.x;
			_point.y = -image.y;
			_point2.x = -image.x+image.width;
			_point2.y = -image.y;
			_point3.x = -image.x;
			_point3.y = -image.y+image.height;
			_point4.x = -image.x+image.width;
			_point4.y = -image.y+image.height;
			
			// create a transformation matrix based on the image
			_matrix.b = _matrix.c = 0;
			_matrix.a = image.scaleX * image.scale;
			_matrix.d = image.scaleY * image.scale;
			_matrix.tx = -image.originX * _matrix.a;
			_matrix.ty = -image.originY * _matrix.d;
			if (image.angle != 0) _matrix.rotate(image.angle * FP.RAD);
			_matrix.tx += image.originX;
			_matrix.ty += image.originY;
			
			// transform each of the corners
			_point = _matrix.transformPoint(_point);
			_point2 = _matrix.transformPoint(_point2);
			_point3 = _matrix.transformPoint(_point3);
			_point4 = _matrix.transformPoint(_point4);
			
			// find the new bounds
			var left:Number = Math.min(_point.x, Math.min(_point2.x, Math.min(_point3.x, _point4.x)))-image.originX;
			var right:Number = Math.max(_point.x, Math.max(_point2.x, Math.max(_point3.x, _point4.x)))-image.originX;
			var top:Number = Math.min(_point.y, Math.min(_point2.y, Math.min(_point3.y, _point4.y)))-image.originY;
			var bottom:Number = Math.max(_point.y, Math.max(_point2.y, Math.max(_point3.y, _point4.y)))-image.originY;
			
			// find the new dimensions
			_width = right-left;
			_height = bottom-top;
			
			// if the data doesn't exist or is the wrong size, recreate it
			if (!_data || _data.width != _width || _data.height != _height)
			{
				if (_data) _data.dispose();
				_data = new BitmapData(_width, _height, true, 0);
			}
			// if the data already exists and is the right size, fill it with blank pixels
			else
			{
				_rect.x = 0;
				_rect.y = 0;
				_rect.width = _width;
				_rect.height = _height;
				
				_data.fillRect(_rect, 0);
			}
			
			// find the point to render the image from
			_point.x = -image.x-left;
			_point.y = -image.y-top;
			
			// render the imag to the data
			image.render(_data, _point, FP.zero);
			
			// set the mask's position
			_x = left+x;
			_y = top+y;
			
			update();
			
			// if there's a debug bitmapdata object, dispose of it
			if (_debug)
			{
				_debug.dispose();
				_debug = null;
			}
		}
		
		/**
		 * Current BitmapData mask.
		 */
		public function get data():BitmapData { return _data; }
		public function set data(value:BitmapData):void
		{
			_data = value;
			_width = value.width;
			_height = value.height;
			update();
		}
		
		public override function renderDebug(g:Graphics):void
		{
			if (! _debug) {
				_debug = new BitmapData(_data.width, _data.height, true, 0x0);
			}
			
			FP.rect.x = 0;
			FP.rect.y = 0;
			FP.rect.width = _data.width;
			FP.rect.height = _data.height;
			
			_debug.fillRect(FP.rect, 0x0);
			_debug.threshold(_data, FP.rect, FP.zero, ">=", threshold << 24, 0x40FFFFFF, 0xFF000000);
			
			var sx:Number = FP.screen.scaleX * FP.screen.scale;
			var sy:Number = FP.screen.scaleY * FP.screen.scale;
			
			FP.matrix.a = sx;
			FP.matrix.d = sy;
			FP.matrix.b = FP.matrix.c = 0;
			FP.matrix.tx = (parent.x - parent.originX - FP.camera.x)*sx;
			FP.matrix.ty = (parent.y - parent.originY - FP.camera.y)*sy;
			
			g.lineStyle();
			g.beginBitmapFill(_debug, FP.matrix);
			g.drawRect(FP.matrix.tx, FP.matrix.ty, _data.width*sx, _data.height*sy);
			g.endFill();
		}
		
		// Pixelmask information.
		/** @private */ internal var _data:BitmapData;
		/** @private */ internal var _debug:BitmapData;
		
		// Global objects.
		/** @private */ private var _rect:Rectangle = FP.rect;
		/** @private */ private var _matrix:Matrix = FP.matrix;
		/** @private */ private var _point:Point = FP.point;
		/** @private */ private var _point2:Point = FP.point2;
		/** @private */ private var _point3:Point = new Point;
		/** @private */ private var _point4:Point = new Point;
	}
}
