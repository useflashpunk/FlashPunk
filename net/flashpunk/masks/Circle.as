package net.flashpunk.masks
{

	import net.flashpunk.FP;
	import net.flashpunk.Graphic;
	import net.flashpunk.Mask;
	import net.flashpunk.masks.Grid;
	import flash.display.Graphics;
	import flash.geom.Point;

	/**
	 * Uses circular area to determine collision.
	 */

	public class Circle extends Hitbox
	{
		/**
		 * Constructor.
		 * @param	radius		Radius of the circle.
		 * @param	x			X offset of the circle.
		 * @param	y			Y offset of the circle.
		 */
		public function Circle(radius:int, x:int = 0, y:int = 0)
		{
			this.radius = radius;
			_x = x + radius;
			_y = y + radius;

			_check[Mask] = collideMask;
			_check[Hitbox] = collideHitbox;
			_check[Grid] = collideGrid;
			_check[Circle] = collideCircle;
		}

		/** @private Collides against an Entity. */
		private function collideMask(other:Mask):Boolean
		{
			var _otherHalfWidth:Number = other.parent.width * 0.5;
			var _otherHalfHeight:Number = other.parent.height * 0.5;
			
			var distanceX:Number = Math.abs(parent.x + _x - other.parent.x - _otherHalfWidth),
				distanceY:Number = Math.abs(parent.y + _y - other.parent.y - _otherHalfHeight);

			if (distanceX > _otherHalfWidth + radius || distanceY > _otherHalfHeight + radius)
			{
				return false;	//The hitbox is to far away so return false
			}
			if (distanceX <= _otherHalfWidth || distanceY <= _otherHalfHeight)
			{
				return true;
			}
			var distanceToCorner:Number = (distanceX - _otherHalfWidth) * (distanceX - _otherHalfWidth)
				+ (distanceY - _otherHalfHeight) * (distanceY - _otherHalfHeight);

			return distanceToCorner <= _squaredRadius;
		}

		/** @private Collides against a Hitbox. */
		private function collideHitbox(other:Hitbox):Boolean
		{
			var _otherHalfWidth:Number = other._width * 0.5;
			var _otherHalfHeight:Number = other._height * 0.5;
			
			var distanceX:Number = Math.abs(parent.x + _x - other.parent.x - other._x - _otherHalfWidth),
				distanceY:Number = Math.abs(parent.y + _y - other.parent.y - other._y - _otherHalfHeight);

			if (distanceX > _otherHalfWidth + radius || distanceY > _otherHalfHeight + radius)
			{
				return false;	//The hitbox is to far away so return false
			}
			if (distanceX <= _otherHalfWidth || distanceY <= _otherHalfHeight)
			{
				return true;
			}
			var distanceToCorner:Number = (distanceX - _otherHalfWidth) * (distanceX - _otherHalfWidth)
				+ (distanceY - _otherHalfHeight) * (distanceY - _otherHalfHeight);

			return distanceToCorner <= _squaredRadius;
		}

		/** @private Collides against a Grid. */
		private function collideGrid(other:Grid):Boolean
		{
			var thisX:Number = parent.x + _x,
				thisY:Number = parent.y + _y,
				otherX:Number = other.parent.x + other.x,
				otherY:Number = other.parent.y + other.y,
				entityDistX:Number = thisX - otherX,
				entityDistY:Number = thisY - otherY;

			var minx:int = Math.floor((entityDistX - radius) / other.tileWidth),
				miny:int = Math.floor((entityDistY - radius) / other.tileHeight),
				maxx:int = Math.ceil((entityDistX + radius) / other.tileWidth),
				maxy:int = Math.ceil((entityDistY + radius) / other.tileHeight);

			if (minx < 0) minx = 0;
			if (miny < 0) miny = 0;
			if (maxx > other.columns) maxx = other.columns;
			if (maxy > other.rows)    maxy = other.rows;

			var hTileWidth:Number = other.tileWidth * 0.5,
				hTileHeight:Number = other.tileHeight * 0.5,
				dx:Number, dy:Number;

			for (var xx:int = minx; xx < maxx; xx++)
			{
				for (var yy:int = miny; yy < maxy; yy++)
				{
					if (other.getTile(xx, yy))
					{
						var mx:Number = otherX + xx*other.tileWidth + hTileWidth,
							my:Number = otherY + yy*other.tileHeight + hTileHeight;

						dx = Math.abs(thisX - mx);

						if (dx > hTileWidth + radius)
							continue;

						dy = Math.abs(thisY - my);

						if (dy > hTileHeight + radius)
							continue;

						if (dx <= hTileWidth || dy <= hTileHeight)
							return true;

						var xCornerDist:Number = dx - hTileWidth;
						var yCornerDist:Number = dy - hTileHeight;

						if (xCornerDist * xCornerDist + yCornerDist * yCornerDist <= _squaredRadius)
							return true;
					}
				}
			}

			return false;
		}

		/** @private Collides against a Circle. */
		private function collideCircle(other:Circle):Boolean
		{
			var dx:Number = (parent.x + _x) - (other.parent.x + other._x);
			var dy:Number = (parent.y + _y) - (other.parent.y + other._y);
			return (dx * dx + dy * dy) < Math.pow(_radius + other._radius, 2);
		}

		/** @private */
		override public function project(axis:Point, projection:Object):void
		{
			projection.min = -_radius;
			projection.max = _radius;
		}

		override public function renderDebug(graphics:Graphics):void
		{
			var sx:Number = FP.screen.scaleX * FP.screen.scale;
			var sy:Number = FP.screen.scaleY * FP.screen.scale;
			
			graphics.drawCircle((parent.x + _x - FP.camera.x) * sx, (parent.y + _y - FP.camera.y) * sy, radius * sx);
		}

		override public function get x():int { return _x - _radius; }
		override public function get y():int { return _y - _radius; }

		/**
		 * Radius.
		 */
		public function get radius():int { return _radius; }
		public function set radius(value:int):void
		{
			if (_radius == value) return;
			_radius = value;
			_squaredRadius = value * value;
			height = width = _radius + _radius;
			if (list != null) list.update();
			else if (parent != null) update();
		}

		/** Updates the parent's bounds for this mask. */
		override public function update():void
		{
			if (parent != null)
			{
				//update entity bounds
				parent.originX = -_x + radius;
				parent.originY = -_y + radius;
				parent.height = parent.width = radius + radius;

				// update parent list
				if (list != null)
					list.update();
			}
		}

		// Hitbox information.
		protected var _radius:int;
		protected var _squaredRadius:int; //Set automatically through the setter for radius
	}
}