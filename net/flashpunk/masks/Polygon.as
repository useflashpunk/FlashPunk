package net.flashpunk.masks
{
	import flash.display.Graphics;
	import flash.geom.Point;
	import net.flashpunk.FP;
	import net.flashpunk.Mask;


	public class Polygon extends Hitbox
	{
		/**
		 * The polygon rotates around this point when the angle is set.
		 */
		public var origin:Point;

		/**
		 * Constructor.
		 * @param	points   an array of coordinates that define the polygon (must have at least 3)
		 * @param	origin   origin point of the polygon
		 */
		public function Polygon(points:Vector.<Point>, origin:Point = null)
		{
			_points = points;

			_check[Mask] = collideMask;
			_check[Hitbox] = collideHitbox;
			_check[Grid] = collideGrid;
			_check[Circle] = collideCircle;
			_check[Polygon] = collidePolygon;

			this.origin = origin != null ? origin : new Point();
			_angle = 0;

			updateAxes();
		}

		/**
		 * Checks for collisions with a Entity.
		 */
		private function collideMask(other:Mask):Boolean
		{
			var offset:Number,
				offsetX:Number = parent.x - other.parent.x,
				offsetY:Number = parent.y - other.parent.y;

			project(vertical, firstProj);//Project on the horizontal axis of the hitbox
			other.project(vertical, secondProj);

			firstProj.min += offsetY;
			firstProj.max += offsetY;

			// if firstProj overlaps secondProj
			if (firstProj.min > secondProj.max || firstProj.max < secondProj.min)
			{
				return false;
			}

			project(horizontal, firstProj);//Project on the vertical axis of the hitbox
			other.project(horizontal, secondProj);

			firstProj.min += offsetX;
			firstProj.max += offsetX;

			// if firstProj overlaps secondProj
			if (firstProj.min > secondProj.max || firstProj.max < secondProj.min)
			{
				return false;
			}

			var a:Point;
			
			for (var i:int = 0; i < _axes.length; i++)
			{
				a = _axes[i];
				project(a, firstProj);
				other.project(a, secondProj);

				offset = offsetX * a.x + offsetY * a.y;
				firstProj.min += offset;
				firstProj.max += offset;

				// if firstProj overlaps secondProj
				if (firstProj.min > secondProj.max || firstProj.max < secondProj.min)
				{
					return false;
				}
			}
			return true;
		}

		/**
		 * Checks for collisions with a hitbox.
		 */
		public function collideHitbox(hitbox:Hitbox):Boolean
		{
			var offset:Number,
				offsetX:Number = parent.x - hitbox.parent.x,
				offsetY:Number = parent.y - hitbox.parent.y;

			project(vertical, firstProj);//Project on the horizontal axis of the hitbox
			hitbox.project(vertical, secondProj);

			firstProj.min += offsetY;
			firstProj.max += offsetY;

			// if firstProj overlaps secondProj
			if (firstProj.min > secondProj.max || firstProj.max < secondProj.min)
			{
				return false;
			}

			project(horizontal, firstProj);//Project on the vertical axis of the hitbox
			hitbox.project(horizontal, secondProj);

			firstProj.min += offsetX;
			firstProj.max += offsetX;

			// if firstProj overlaps secondProj
			if (firstProj.min > secondProj.max || firstProj.max < secondProj.min)
			{
				return false;
			}

			var a:Point;
			
			for (var i:int = 0; i < _axes.length; i++)
			{
				a = _axes[i];
				project(a, firstProj);
				hitbox.project(a, secondProj);

				offset = offsetX * a.x + offsetY * a.y;
				firstProj.min += offset;
				firstProj.max += offset;

				// if firstProj overlaps secondProj
				if (firstProj.min > secondProj.max || firstProj.max < secondProj.min)
				{
					return false;
				}
			}
			return true;
		}

		/**
		 * Checks for collisions along the edges of the polygon.
		 * May be very slow, mainly added for completeness sake.
		 */
		public function collideGrid(grid:Grid):Boolean
		{
			var p1X:Number, p1Y:Number,
				p2X:Number, p2Y:Number,
				k:Number, m:Number,
				x:Number, y:Number,
				min:Number, max:Number;
				
			for (var ii:int = 0; ii < _points.length - 1; ii++)
			{
				p1X = (parent.x + _points[ii].x) / grid.tileWidth;
				p1Y = (parent.y + _points[ii].y) / grid.tileHeight;
				p2X = (parent.x + _points[ii + 1].x) / grid.tileWidth;
				p2Y = (parent.y +  _points[ii + 1].y) / grid.tileHeight;

				k = (p2Y - p1Y) / (p2X - p1X);
				m = p1Y - k * p1X;

				if (p2X > p1X) { min = p1X; max = p2X; }
				else { max = p1X; min = p2X; }

				x = min;
				while (x < max)
				{
					y = int(k * x + m);
					if (grid.getTile(int(x), y))
						return true;

					x++;
				}
			}
			
			//Check the last point -> first point
			p1X = (parent.x + _points[_points.length - 1].x) / grid.tileWidth;
			p1Y = (parent.y + _points[_points.length - 1].y) / grid.tileHeight;
			p2X = (parent.x + _points[0].x) / grid.tileWidth;
			p2Y = (parent.y +  _points[0].y) / grid.tileHeight;

			k = (p2Y - p1Y) / (p2X - p1X);
			m = p1Y - k * p1X;

			if (p2X > p1X) { min = p1X; max = p2X; }
			else { max = p1X; min = p2X; }

			x = min;
			while (x < max)
			{
				y = int(k * x + m);
				if (grid.getTile(int(x), y))
					return true;

				x++;
			}

			return false;
		}

		/**
		 * Checks for collision with a circle.
		 */
		public function collideCircle(circle:Circle):Boolean
		{
			var offset:Number;

			//First find the point closest to the circle
			var distanceSquared:Number = int.MAX_VALUE;
			var closestPoint:Point = null;
			var p:Point;
			
			for (var i:int = 0; i < _points.length; i++)
			{
				p = _points[i];
				var dx:Number = parent.x + p.x - circle.parent.x - circle.radius;
				var dy:Number = parent.y + p.y - circle.parent.y - circle.radius;
				var tempDistance:Number = dx * dx + dy * dy;

				if (tempDistance < distanceSquared)
				{
					distanceSquared = tempDistance;
					closestPoint = p;
				}
			}

			var offsetX:Number = parent.x - circle.parent.x - circle.radius;
			var offsetY:Number = parent.y - circle.parent.y - circle.radius;

			//Get the vector between the closest point and the circle
			//and get the normal of it
			_axis.x = circle.parent.y - parent.y + closestPoint.y;
			_axis.y = parent.x + closestPoint.x - circle.parent.x;
			_axis.normalize(1);

			project(_axis, firstProj);
			circle.project(_axis, secondProj);

			offset = offsetX * _axis.x + offsetY * _axis.y;
			firstProj.min += offset;
			firstProj.max += offset;

			// if firstProj overlaps secondProj
			if (firstProj.min > secondProj.max || firstProj.max < secondProj.min)
			{
				return false;
			}

			var a:Point;
			
			for (var j:int = 0; j < _axes.length; j++)
			{
				a = _axes[j];
				project(a, firstProj);
				circle.project(a, secondProj);

				offset = offsetX * a.x + offsetY * a.y;
				firstProj.min += offset;
				firstProj.max += offset;

				// if firstProj overlaps secondProj
				if (firstProj.min > secondProj.max || firstProj.max < secondProj.min)
				{
					return false;
				}
			}

			return true;
		}

		/**
		 * Checks for collision with a polygon.
		 */
		public function collidePolygon(other:Polygon):Boolean
		{
			var offsetX:Number = parent.x - other.parent.x;
			var offsetY:Number = parent.y - other.parent.y;
			var a:Point;
			
			for (var i:int = 0; i < _axes.length; i++)
			{
				a = _axes[i];
				project(a, firstProj);
				other.project(a, secondProj);

				//Shift the first info with the offset
				var offset:Number = offsetX * a.x + offsetY * a.y;
				firstProj.min += offset;
				firstProj.max += offset;

				// if firstProj overlaps secondProj
				if (firstProj.min > secondProj.max || firstProj.max < secondProj.min)
				{
					return false;
				}
			}

			for (var j:int = 0; j < other._axes.length; j++)
			{
				a = _axes[j];
				project(a, firstProj);
				other.project(a, secondProj);

				//Shift the first info with the offset
				offset = offsetX * a.x + offsetY * a.y;
				firstProj.min += offset;
				firstProj.max += offset;

				// if firstProj overlaps secondProj
				if (firstProj.min > secondProj.max || firstProj.max < secondProj.min)
				{
					return false;
				}
			}
			return true;
		}

		/** @private */
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

		private function rotate(angle:Number):void
		{
			angle *= FP.RAD;

			var p:Point;
			
			for (var i:int = 0; i < _points.length; i++)
			{
				p = _points[i];
				var dx:Number = p.x - origin.x;
				var dy:Number = p.y - origin.y;

				var pointAngle:Number = Math.atan2(dy, dx);
				var length:Number = Math.sqrt(dx * dx + dy * dy);

				p.x = Math.cos(pointAngle + angle) * length + origin.x;
				p.y = Math.sin(pointAngle + angle) * length + origin.y;
			}
			var a:Point;
			
			for (var j:int = 0; j < _axes.length; j++)
			{
				a = _axes[j];

				var axisAngle:Number = Math.atan2(a.y, a.x);

				a.x = Math.cos(axisAngle + angle);
				a.y = Math.sin(axisAngle + angle);
			}
			_angle += angle;
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
				for (var ii:int = 0; ii < _points.length; ii++)
				{
					graphics.lineTo((_points[ii].x + offsetX) * sx, (_points[ii].y + offsetY) * sy);
				}
			}
		}

		/**
		 * Angle in degress that the polygon is rotated.
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
		 * If you need to set a point yourself instead of passing in a new Array<Point> you need to call update() to makes sure the axes update as well.
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
			project(horizontal, firstProj); //width
			_x = Math.ceil(firstProj.min);
			_width = Math.ceil(firstProj.max - firstProj.min);
			project(vertical, secondProj); //height
			_y = Math.ceil(secondProj.min);
			_height = Math.ceil(secondProj.max - secondProj.min);

			if (parent != null)
			{
				//update entity bounds
				parent.width = _width;
				parent.height = _height;

				//Since the collisioninfos haven't changed we can use them to calculate hitbox placement
				parent.originX = int((_width - firstProj.max - firstProj.min)/2);
				parent.originY = int((_height - secondProj.max - secondProj.min )/2);
			}

			// update parent list
			if (list != null) list.update();
		}

		/**
		 * Creates a regular polygon.
		 * @param	sides	The number of sides in the polygon
		 * @param	radius	The distance that the corners are at
		 * @param	angle	How much the polygon is rotated
		 * @return	The polygon
		 */
		public static function createPolygon(sides:int = 3, radius:Number = 100, angle:Number = 0):Polygon
		{
			if (sides < 3) throw "The polygon needs at least 3 sides";
			// create a return polygon
			// figure out the angles required
			var rotationAngle:Number = (Math.PI * 2) / sides;

			// loop through and generate each point
			var points:Vector.<Point> = new Vector.<Point>();

			for (var ii:int = 0; ii < sides; ii++)
			{
				var tempAngle:Number = ii * rotationAngle;
				var p:Point = new Point();
				p.x = Math.cos(tempAngle) * radius;
				p.y = Math.sin(tempAngle) * radius;
				points.push(p);
			}
			// return the point
			var poly:Polygon = new Polygon(points);
			poly.angle = angle;
			return poly;
		}

		/**
		 * Creates a polygon from an array were even numbers are x and odd are y
		 * @param	points	Array containing the polygon's points.
		 * 
		 * @return	The polygon
		 */
		public static function createFromVector(points:Vector.<Number>):Polygon
		{
			var p:Vector.<Point> = new Vector.<Point>();

			var ii:int = 0;
			while (ii < points.length)
			{
				p.push(new Point(points[ii++], points[ii++]));
			}
			return new Polygon(p);
		}

		private function generateAxes():void
		{
			_axes = new Vector.<Point>();
			var store:Number;
			var numberOfPoints:int = _points.length - 1;
			var edge:Point;
			
			for (var i:int = 0; i < numberOfPoints; i++)
			{
				edge = new Point();
				edge.x = _points[i].x - _points[i + 1].x;
				edge.y = _points[i].y - _points[i + 1].y;

				//Get the axis which is perpendicular to the edge
				store = edge.y;
				edge.y = -edge.x;
				edge.x = store;
				edge.normalize(1);

				_axes.push(edge);
			}
			edge = new Point();
			//Add the last edge
			edge.x = _points[numberOfPoints].x - _points[0].x;
			edge.y = _points[numberOfPoints].y - _points[0].y;
			store = edge.y;
			edge.y = -edge.x;
			edge.x = store;
			edge.normalize(1);

			_axes.push(edge);
		}

		private function removeDuplicateAxes():void
		{
			for (var ii:int = 0; ii < _axes.length; ii++ )
			{
				for (var jj:int = 0; jj < _axes.length; jj++ )
				{
					if (ii == jj || Math.max(ii, jj) >= _axes.length) continue;
					// if the first vector is equal or similar to the second vector,
					// remove it from the list. (for example, [1, 1] and [-1, -1]
					// share the same relative path)
					if ((_axes[ii].x == _axes[jj].x && _axes[ii].y == _axes[jj].y)
						|| ( -_axes[ii].x == _axes[jj].x && -_axes[ii].y == _axes[jj].y))//First axis inverted
					{
						_axes.splice(jj, 1);
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
		
		private static var _axis:Point = new Point();
		private static var firstProj:* = { min: 0.0, max:0.0 };
		private static var secondProj:* = { min: 0.0, max:0.0 };

		public static var vertical:Point = new Point(0, 1);
		public static var horizontal:Point = new Point(1, 0);
	}
}