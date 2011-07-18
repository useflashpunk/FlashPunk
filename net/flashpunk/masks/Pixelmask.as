package net.flashpunk.masks
{
	import flash.display.*;
	import flash.geom.*;
	import net.flashpunk.*;
	
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
			if (!_data) throw new Error("Invalid Pixelmask source image.");
			
			// set mask properties
			_width = data.width;
			_height = data.height;
			_x = x;
			_y = y;
			
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
		/** @private */ private var _point:Point = FP.point;
		/** @private */ private var _point2:Point = FP.point2;
	}
}
