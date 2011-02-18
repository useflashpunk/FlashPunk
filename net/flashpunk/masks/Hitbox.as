package net.flashpunk.masks 
{
	import net.flashpunk.*;
	
	/**
	 * Uses parent's hitbox to determine collision. This class is used
	 * internally by FlashPunk, you don't need to use this class because
	 * this is the default behaviour of Entities without a Mask object.
	 */
	public class Hitbox extends Mask
	{
		/**
		 * Constructor.
		 * @param	width		Width of the hitbox.
		 * @param	height		Height of the hitbox.
		 * @param	x			X offset of the hitbox.
		 * @param	y			Y offset of the hitbox.
		 */
		public function Hitbox(width:uint = 1, height:uint = 1, x:int = 0, y:int = 0) 
		{
			_width = width;
			_height = height;
			_x = x;
			_y = y;
			_check[Mask] = collideMask;
			_check[Hitbox] = collideHitbox;
		}
		
		/** @private Collides against an Entity. */
		private function collideMask(other:Mask):Boolean
		{
			return parent.x + _x + _width > other.parent.x - other.parent.originX
				&& parent.y + _y + _height > other.parent.y - other.parent.originY
				&& parent.x + _x < other.parent.x - other.parent.originX + other.parent.width
				&& parent.y + _y < other.parent.y - other.parent.originY + other.parent.height;
		}
		
		/** @private Collides against a Hitbox. */
		private function collideHitbox(other:Hitbox):Boolean
		{
			return parent.x + _x + _width > other.parent.x + other._x
				&& parent.y + _y + _height > other.parent.y + other._y
				&& parent.x + _x < other.parent.x + other._x + other._width
				&& parent.y + _y < other.parent.y + other._y + other._height;
		}
		
		/**
		 * X offset.
		 */
		public function get x():int { return _x; }
		public function set x(value:int):void
		{
			if (_x == value) return;
			_x = value;
			if (list) list.update();
			else if (parent) update();
		}
		
		/**
		 * Y offset.
		 */
		public function get y():int { return _y; }
		public function set y(value:int):void
		{
			if (_y == value) return;
			_y = value;
			if (list) list.update();
			else if (parent) update();
		}
		
		/**
		 * Width.
		 */
		public function get width():int { return _width; }
		public function set width(value:int):void
		{
			if (_width == value) return;
			_width = value;
			if (list) list.update();
			else if (parent) update();
		}
		
		/**
		 * Height.
		 */
		public function get height():int { return _height; }
		public function set height(value:int):void
		{
			if (_height == value) return;
			_height = value;
			if (list) list.update();
			else if (parent) update();
		}
		
		/** @private Updates the parent's bounds for this mask. */
		override protected function update():void 
		{
			if (list)
			{
				// update parent list
				list.update();
			}
			else if (parent)
			{
				// update entity bounds
				parent.originX = -_x;
				parent.originY = -_y;
				parent.width = _width;
				parent.height = _height;
			}
		}
		
		// Hitbox information.
		/** @private */ internal var _width:uint;
		/** @private */ internal var _height:uint;
		/** @private */ internal var _x:int;
		/** @private */ internal var _y:int;
	}
}