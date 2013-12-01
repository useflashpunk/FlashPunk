package net.flashpunk.masks
{
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.Mask;
	import net.flashpunk.utils.Draw;


	/** 
	 * Uses polygonal structure to check for collisions.
	 */
	public class Polygon extends Hitbox
	{
		/**
		 * The polygon rotates around this point when the angle is set.
		 */
		public var origin:Point;

		/**
		 * Constructor.
		 * @param	points   a vector of coordinates that define the polygon (must have at least 3)
		 * @param	origin   origin point of the polygon
		 */
		public function Polygon(points:Vector.<Point>, origin:Point = null)
		{
			if (points.length < 3) throw "The polygon needs at least 3 sides";
			_points = points;
			_fakeEntity = new Entity();
			_fakeTileHitbox = new Hitbox();
			_fakePixelmask = new Pixelmask(new BitmapData(1, 1));

			_check[Mask] = collideMask;
			_check[Hitbox] = collideHitbox;
			_check[Grid] = collideGrid;
			_check[Pixelmask] = collidePixelmask;
			_check[Circle] = collideCircle;
			_check[Polygon] = collidePolygon;

			this.origin = origin != null ? origin : new Point();
			_angle = 0;

			updateAxes();
		}

		/**
		 * Checks for collisions with an Entity.
		 */
		private function collideMask(other:Mask):Boolean
		{
			var offset:Number,
				offsetX:Number = parent.x - other.parent.x,
				offsetY:Number = parent.y - other.parent.y;

			// project on the vertical axis of the hitbox/mask
			project(verticalAxis, firstProj);
			other.project(verticalAxis, secondProj);

			firstProj.min += offsetY;
			firstProj.max += offsetY;

			// if firstProj not overlaps secondProj
			if (firstProj.min > secondProj.max || firstProj.max < secondProj.min)
			{
				return false;
			}
			
			// project on the horizontal axis of the hitbox/mask
			project(horizontalAxis, firstProj);
			other.project(horizontalAxis, secondProj);

			firstProj.min += offsetX;
			firstProj.max += offsetX;

			// if firstProj not overlaps secondProj
			if (firstProj.min > secondProj.max || firstProj.max < secondProj.min)
			{
				return false;
			}

			var a:Point;
			
			// project hitbox/mask on polygon axes
			// for a collision to be present all projections must overlap
			for (var i:int = 0; i < _axes.length; i++)
			{
				a = _axes[i];
				project(a, firstProj);
				other.project(a, secondProj);

				offset = offsetX * a.x + offsetY * a.y;
				firstProj.min += offset;
				firstProj.max += offset;

				// if firstProj not overlaps secondProj
				if (firstProj.min > secondProj.max || firstProj.max < secondProj.min)
				{
					return false;
				}
			}
			return true;
		}

		/**
		 * Checks for collisions with a Hitbox.
		 */
		private function collideHitbox(hitbox:Hitbox):Boolean
		{
			var offset:Number,
				offsetX:Number = parent.x - hitbox.parent.x,
				offsetY:Number = parent.y - hitbox.parent.y;

			// project on the vertical axis of the hitbox
			project(verticalAxis, firstProj);
			hitbox.project(verticalAxis, secondProj);

			firstProj.min += offsetY;
			firstProj.max += offsetY;

			// if firstProj not overlaps secondProj
			if (firstProj.min > secondProj.max || firstProj.max < secondProj.min)
			{
				return false;
			}

			// project on the horizontal axis of the hitbox
			project(horizontalAxis, firstProj);
			hitbox.project(horizontalAxis, secondProj);

			firstProj.min += offsetX;
			firstProj.max += offsetX;

			// if firstProj not overlaps secondProj
			if (firstProj.min > secondProj.max || firstProj.max < secondProj.min)
			{
				return false;
			}

			var a:Point;
			
			// project hitbox on polygon axes
			// for a collision to be present all projections must overlap
			for (var i:int = 0; i < _axes.length; i++)
			{
				a = _axes[i];
				project(a, firstProj);
				hitbox.project(a, secondProj);

				offset = offsetX * a.x + offsetY * a.y;
				firstProj.min += offset;
				firstProj.max += offset;

				// if firstProj not overlaps secondProj
				if (firstProj.min > secondProj.max || firstProj.max < secondProj.min)
				{
					return false;
				}
			}
			return true;
		}

		/**
		 * Checks for collisions with a Grid.
		 * May be slow, added for completeness sake.
		 * 
		 * Internally sets up an Hitbox out of each solid Grid tile and uses that for collision check.
		 */
		private function collideGrid(grid:Grid):Boolean
		{
			var tileW:uint = grid.tileWidth;
			var tileH:uint = grid.tileHeight;
			var solidTile:Boolean;
			
			_fakeEntity.width = tileW;
			_fakeEntity.height = tileH;
			_fakeEntity.originX = grid.parent.originX + grid._x;
			_fakeEntity.originY = grid.parent.originY + grid._y;
			
			_fakeTileHitbox._width = tileW;
			_fakeTileHitbox._height = tileH;
			_fakeTileHitbox.parent = _fakeEntity;
			
			for (var r:int = 0; r < grid.rows; r++ ) {
				for (var c:int = 0; c < grid.columns; c++) {
					_fakeEntity.x = grid.parent.x + grid._x + c * tileW;
					_fakeEntity.y = grid.parent.y + grid._y + r * tileH;
					solidTile = grid.getTile(c, r);
					
					if (solidTile && collideHitbox(_fakeTileHitbox)) return true;
				}
			}
			return false;
		}

		/**
		 * Checks for collision with a Pixelmask.
		 * May be slow (especially with big polygons), added for completeness sake.
		 * 
		 * Internally sets up a Pixelmask using the polygon representation and uses that for collision check.
		 */
		private function collidePixelmask(pixelmask:Pixelmask):Boolean
		{
			var data:BitmapData = _fakePixelmask._data;
			
			_fakePixelmask._x = _x;
			_fakePixelmask._y = _y;
			_fakePixelmask.parent = parent;
			
			if (data == null || (data.width < _width || data.height < _height)) {
				data = new BitmapData(_width, height, true, 0);
			} else {
				data.fillRect(data.rect, 0);
			}
			
			var graphics:Graphics = FP.sprite.graphics;
			graphics.clear();

			graphics.beginFill(0xFFFFFF, 1);
			graphics.lineStyle(1, 0xFFFFFF, 1);
			
			var offsetX:Number = _x + parent.originX * 2;
			var offsetY:Number = _y + parent.originY * 2;
			
			graphics.moveTo(points[_points.length - 1].x + offsetX, _points[_points.length - 1].y + offsetY);
			for (var i:int = 0; i < _points.length; i++)
			{
				graphics.lineTo(_points[i].x + offsetX, _points[i].y + offsetY);
			}
			
			graphics.endFill();

			data.draw(FP.sprite);
			
			_fakePixelmask.data = data;
			
			return pixelmask.collide(_fakePixelmask);
		}
		
		/**
		 * Checks for collision with a circle.
		 */
		private function collideCircle(circle:Circle):Boolean
		{			
			var edgesCrossed:int = 0;
			var p1:Point, p2:Point;
			var i:int, j:int;
			var nPoints:int = _points.length;
			var offsetX:Number = parent.x + _x + parent.originX;
			var offsetY:Number = parent.y + _y + parent.originY;
			

			// check if circle center is inside the polygon
			for (i = 0, j = nPoints - 1; i < nPoints; j = i, i++) {
				p1 = _points[i];
				p2 = _points[j];
				
				var distFromCenter:Number = (p2.x - p1.x) * (circle._y + circle.parent.y - p1.y - offsetY) / (p2.y - p1.y) + p1.x + offsetX;
				
				if ((p1.y + offsetY > circle._y + circle.parent.y) != (p2.y + offsetY > circle._y + circle.parent.y)
					&& (circle._x + circle.parent.x < distFromCenter))
				{
					edgesCrossed++;
				}
			}
			
			if (edgesCrossed & 1) return true;
			
			// check if minimum distance from circle center to each polygon side is less than radius
			var radiusSqr:Number = circle.radius * circle.radius;
			var cx:Number = circle._x + circle.parent.x;
			var cy:Number = circle._y + circle.parent.y;
			var minDistanceSqr:Number = 0;
			var closestX:Number;
			var closestY:Number;
			
			for (i = 0, j = nPoints - 1; i < nPoints; j = i, i++) {
				p1 = _points[i];
				p2 = _points[j];

				var segmentLenSqr:Number = (p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y);
				
				// find projection of center onto line (extended segment)
				var t:Number = ((cx - p1.x - offsetX) * (p2.x - p1.x) + (cy - p1.y - offsetY) * (p2.y - p1.y)) / segmentLenSqr;
				
				if (t < 0) {
					closestX = p1.x;
					closestY = p1.y;
				} else if (t > 1) {
					closestX = p2.x;
					closestY = p2.y;
				} else {
					closestX = p1.x + t * (p2.x - p1.x);
					closestY = p1.y + t * (p2.y - p1.y);
				}
				closestX += offsetX;
				closestY += offsetY;
				
				minDistanceSqr = (cx - closestX) * (cx - closestX) + (cy - closestY) * (cy - closestY);
				
				if (minDistanceSqr <= radiusSqr) return true;
			}

			return false;
		}

		/**
		 * Checks for collision with a polygon.
		 */
		private function collidePolygon(other:Polygon):Boolean
		{
			var offsetX:Number = parent.x - other.parent.x;
			var offsetY:Number = parent.y - other.parent.y;
			var a:Point;
			
			// project other on this polygon axes
			// for a collision to be present all projections must overlap
			for (var i:int = 0; i < _axes.length; i++)
			{
				a = _axes[i];
				project(a, firstProj);
				other.project(a, secondProj);

				// shift the first info with the offset
				var offset:Number = offsetX * a.x + offsetY * a.y;
				firstProj.min += offset;
				firstProj.max += offset;

				// if firstProj not overlaps secondProj
				if (firstProj.min > secondProj.max || firstProj.max < secondProj.min)
				{
					return false;
				}
			}

			// project this polygon on other polygon axes
			// for a collision to be present all projections must overlap
			for (var j:int = 0; j < other._axes.length; j++)
			{
				a = other._axes[j];
				project(a, firstProj);
				other.project(a, secondProj);

				// shift the first info with the offset
				offset = offsetX * a.x + offsetY * a.y;
				firstProj.min += offset;
				firstProj.max += offset;

				// if firstProj not overlaps secondProj
				if (firstProj.min > secondProj.max || firstProj.max < secondProj.min)
				{
					return false;
				}
			}
			return true;
		}

		/** @private Projects this polygon points on axis and returns min and max values in projection object. */
		override public function project(axis:Point, projection:Object):void
		{
			var p:Point = _points[0];
			
			var min:Number = axis.x * p.x + axis.y * p.y,	// dot product
				max:Number = min;

			for (var i:int = 1; i < _points.length; i++)
			{
				p = _points[i];
				var cur:Number = axis.x * p.x + axis.y * p.y;	// dot product

				if (cur < min)
				{
					min = cur;
				}
				else if (cur > max)
				{
					max = cur;
				}
			}
			projection.min = min;
			projection.max = max;
		}

		override public function renderDebug(graphics:Graphics):void
		{
			if (parent != null)
			{
				var	offsetX:Number = parent.x - FP.camera.x,
					offsetY:Number = parent.y - FP.camera.y;

				var sx:Number = FP.screen.scaleX * FP.screen.scale;
				var sy:Number = FP.screen.scaleY * FP.screen.scale;
				
				graphics.beginFill(0xFFFFFF, .15);
				graphics.lineStyle(1, 0xFFFFFF, 0.25);
				
				graphics.moveTo((points[_points.length - 1].x + offsetX) * sx , (_points[_points.length - 1].y + offsetY) * sy);
				for (var i:int = 0; i < _points.length; i++)
				{
					graphics.lineTo((_points[i].x + offsetX) * sx, (_points[i].y + offsetY) * sy);
				}
				
				graphics.endFill();
			}
		}

		/**
		 * Rotation angle (in degress) of the polygon (rotates around origin point).
		 */
		public function get angle():Number { return _angle; }
		public function set angle(value:Number):void
		{
			if (value == _angle) return;
			rotate(_angle - value);
			if (list != null || parent != null) update();
		}

		/**
		 * The points representing the polygon.
		 * 
		 * If you need to set a point yourself instead of passing in a new Array<Point> you need to call update() 
		 * to makes sure the axes update as well.
		 */
		public function get points():Vector.<Point> { return _points; }
		public function set points(value:Vector.<Point>):void
		{
			if (_points == value) return;
			_points = value;

			if (list != null || parent != null) updateAxes();
		}

		/** Updates the parent's bounds for this mask. */
		override public function update():void
		{
			project(horizontalAxis, firstProj); // width
			_x = Math.ceil(firstProj.min);
			_width = Math.ceil(firstProj.max - firstProj.min);
			project(verticalAxis, secondProj); // height
			_y = Math.ceil(secondProj.min);
			_height = Math.ceil(secondProj.max - secondProj.min);

			if (parent != null)
			{
				// update entity bounds
				parent.width = _width;
				parent.height = _height;

				// since the collision infos haven't changed we can use them to calculate hitbox placement
				parent.originX = int((_width - firstProj.max - firstProj.min)/2);
				parent.originY = int((_height - secondProj.max - secondProj.min )/2);
			}

			// update parent list
			if (list != null) list.update();
		}

		/**
		 * Creates a regular polygon (edges of same length).
		 * @param	sides	The number of sides in the polygon
		 * @param	radius	The distance that the corners are at
		 * @param	angle	How much the polygon is rotated
		 * @return	The polygon
		 */
		public static function createPolygon(sides:int = 3, radius:Number = 100, angle:Number = 0):Polygon
		{
			if (sides < 3) throw "The polygon needs at least 3 sides";

			// figure out the angle required for each step
			var rotationAngle:Number = (Math.PI * 2) / sides;

			// loop through and generate each point
			var points:Vector.<Point> = new Vector.<Point>();

			for (var i:int = 0; i < sides; i++)
			{
				var tempAngle:Number = i * rotationAngle;
				var p:Point = new Point();
				p.x = Math.cos(tempAngle) * radius;
				p.y = Math.sin(tempAngle) * radius;
				points.push(p);
			}
			
			// return the polygon
			var poly:Polygon = new Polygon(points);
			poly.angle = angle;
			return poly;
		}

		/**
		 * Creates a polygon from an array were even numbers are x and odd are y
		 * @param	points	Vector containing the polygon's points.
		 * 
		 * @return	The polygon
		 */
		public static function createFromVector(points:Vector.<Number>):Polygon
		{
			var p:Vector.<Point> = new Vector.<Point>();

			var i:int = 0;
			while (i < points.length)
			{
				p.push(new Point(points[i++], points[i++]));
			}
			return new Polygon(p);
		}

		private function rotate(angleDelta:Number):void
		{
			_angle += angleDelta;
			
			angleDelta *= FP.RAD;

			var p:Point;
			
			for (var i:int = 0; i < _points.length; i++)
			{
				p = _points[i];
				var dx:Number = p.x - origin.x;
				var dy:Number = p.y - origin.y;

				var pointAngle:Number = Math.atan2(dy, dx);
				var length:Number = Math.sqrt(dx * dx + dy * dy);

				p.x = Math.cos(pointAngle + angleDelta) * length + origin.x;
				p.y = Math.sin(pointAngle + angleDelta) * length + origin.y;
			}
			var a:Point;
			
			for (var j:int = 0; j < _axes.length; j++)
			{
				a = _axes[j];

				var axisAngle:Number = Math.atan2(a.y, a.x);

				a.x = Math.cos(axisAngle + angleDelta);
				a.y = Math.sin(axisAngle + angleDelta);
			}
		}

		private function generateAxes():void
		{
			_axes = new Vector.<Point>();
			var temp:Number;
			var nPoints:int = _points.length - 1;
			var edge:Point;
			var i:int, j:int;
			
			for (i = 0, j = nPoints - 1; i < nPoints; j = i, i++) {
				edge = new Point();
				edge.x = _points[i].x - _points[j].x;
				edge.y = _points[i].y - _points[j].y;

				// get the axis which is perpendicular to the edge
				temp = edge.y;
				edge.y = -edge.x;
				edge.x = temp;
				edge.normalize(1);

				_axes.push(edge);
			}
		}

		private function removeDuplicateAxes():void
		{
			for (var i:int = 0; i < _axes.length; i++ )
			{
				for (var j:int = 0; j < _axes.length; j++ )
				{
					if (i == j || Math.max(i, j) >= _axes.length) continue;
					
					// if the first vector is equal or similar to the second vector,
					// remove it from the list. (for example, [1, 1] and [-1, -1]
					// represent the same axis)
					if ((_axes[i].x == _axes[j].x && _axes[i].y == _axes[j].y)
						|| ( -_axes[i].x == _axes[j].x && -_axes[i].y == _axes[j].y))	// first axis inverted
					{
						_axes.splice(j, 1);
					}
				}
			}
		}

		private function updateAxes():void
		{
			generateAxes();
			removeDuplicateAxes();
			update();
		}

		// Hitbox information.
		private var _angle:Number;
		private var _points:Vector.<Point>;
		private var _axes:Vector.<Point>;
		private var _projection:* = { min: 0.0, max:0.0 };

		private var _fakeEntity:Entity;			// used for Grid collision
		private var _fakeTileHitbox:Hitbox;		// used for Grid collision
		private var _fakePixelmask:Pixelmask;	// used for Pixelmask collision
		
		private static var _axis:Point = new Point();
		private static var firstProj:* = { min: 0.0, max:0.0 };
		private static var secondProj:* = { min: 0.0, max:0.0 };

		public static const verticalAxis:Point = new Point(0, 1);
		public static const horizontalAxis:Point = new Point(1, 0);
	}
}