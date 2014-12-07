package net.flashpunk.masks
{
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.Mask;


	/** 
	 * Uses polygon edges to check for collisions (only works with convex polygons).
	 */
	public class Polygon extends Hitbox
	{
		/**
		 * Constructor.
		 * 
		 * @param	points		An array of coordinates that define the convex polygon (must have at least 3).
		 * @param	pivotX		X pivot for rotations.
		 * @param	pivotY		Y pivot for rotations.
		 */
		public function Polygon(points:Vector.<Point>, pivotX:Number = 0, pivotY:Number = 0)
		{
			if (points.length < 3) throw "The polygon needs at least 3 sides";
			_points = points;
			_transformedPoints = new Vector.<Point>();
			for (var i:int = 0; i < points.length; i++) _transformedPoints[i] = points[i].clone();
			
			_fakeEntity = new Entity();
			_fakeTileHitbox = new Hitbox();
			_fakePixelmask = new Pixelmask(new BitmapData(1, 1));

			_check[Mask] = collideMask;
			_check[Hitbox] = collideHitbox;
			_check[Grid] = collideGrid;
			_check[Pixelmask] = collidePixelmask;
			_check[Circle] = collideCircle;
			_check[Polygon] = collidePolygon;

			this.pivotX = pivotX;
			this.pivotY = pivotY;
			_angle = 0;
			_lastAngle = 0;

			updateAxes();
		}

		/**
		 * Checks for collisions with an Entity.
		 */
		override protected function collideMask(other:Mask):Boolean
		{
			var offset:Number,
				offsetX:Number = parent.x + _x - other.parent.x,
				offsetY:Number = parent.y + _y - other.parent.y;

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
		override protected function collideHitbox(other:Hitbox):Boolean
		{
			var offset:Number,
				offsetX:Number = parent.x + _x - other.parent.x,
				offsetY:Number = parent.y + _y - other.parent.y;

			// project on the vertical axis of the hitbox
			project(verticalAxis, firstProj);
			other.project(verticalAxis, secondProj);

			firstProj.min += offsetY;
			firstProj.max += offsetY;

			// if firstProj not overlaps secondProj
			if (firstProj.min > secondProj.max || firstProj.max < secondProj.min)
			{
				return false;
			}

			// project on the horizontal axis of the hitbox
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
			
			// project hitbox on polygon axes
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
		 * Checks for collisions with a Grid.
		 * May be slow, added for completeness sake.
		 * 
		 * Internally sets up an Hitbox out of each solid Grid tile and uses that for collision check.
		 */
		protected function collideGrid(other:Grid):Boolean
		{
			var tileW:uint = other.tileWidth;
			var tileH:uint = other.tileHeight;
			var solidTile:Boolean;
			
			_fakeEntity.width = tileW;
			_fakeEntity.height = tileH;
			_fakeEntity.x = parent.x;
			_fakeEntity.y = parent.y;
			_fakeEntity.originX = other.parent.originX + other._x;
			_fakeEntity.originY = other.parent.originY + other._y;
			
			_fakeTileHitbox._width = tileW;
			_fakeTileHitbox._height = tileH;
			_fakeTileHitbox.parent = _fakeEntity;
			
			for (var r:int = 0; r < other.rows; r++ ) {
				for (var c:int = 0; c < other.columns; c++) {
					_fakeEntity.x = other.parent.x + other._x + c * tileW;
					_fakeEntity.y = other.parent.y + other._y + r * tileH;
					solidTile = other.getTile(c, r);
					
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
		protected function collidePixelmask(other:Pixelmask):Boolean
		{
			var data:BitmapData = _fakePixelmask._data;
			
			_fakeEntity.width = parent.width;
			_fakeEntity.height = parent.height;
			_fakeEntity.x = parent.x - _x;
			_fakeEntity.y = parent.y - _y;
			_fakeEntity.originX = parent.originX;
			_fakeEntity.originY = parent.originY;

			_fakePixelmask._x = _x - parent.originX;
			_fakePixelmask._y = _y - parent.originY;
			_fakePixelmask.parent = _fakeEntity;
			
			if (data == null || (data.width < parent.width || data.height < parent.height)) {
				data = new BitmapData(parent.width, parent.height, true, 0);
			} else {
				data.fillRect(data.rect, 0);
			}
			
			var graphics:Graphics = FP.sprite.graphics;
			graphics.clear();

			graphics.beginFill(0xFFFFFF, 1);
			graphics.lineStyle(1, 0xFFFFFF, 1);
			
			var offsetX:Number = _x + parent.originX;
			var offsetY:Number = _y + parent.originY;
			
			graphics.moveTo(points[_transformedPoints.length - 1].x + offsetX, _transformedPoints[_transformedPoints.length - 1].y + offsetY);
			for (var i:int = 0; i < _transformedPoints.length; i++)
			{
				graphics.lineTo(_transformedPoints[i].x + offsetX, _transformedPoints[i].y + offsetY);
			}
			
			graphics.endFill();

			data.draw(FP.sprite);
			
			_fakePixelmask.data = data;
			
			return other.collide(_fakePixelmask);
		}
		
		/**
		 * Checks for collision with a circle.
		 */
		protected function collideCircle(other:Circle):Boolean
		{			
			var edgesCrossed:int = 0;
			var p1:Point, p2:Point;
			var i:int, j:int;
			var nPoints:int = _transformedPoints.length;
			var offsetX:Number = parent.x + _x;
			var offsetY:Number = parent.y + _y;
			

			// check if circle center is inside the polygon
			for (i = 0, j = nPoints - 1; i < nPoints; j = i, i++) {
				p1 = _transformedPoints[i];
				p2 = _transformedPoints[j];
				
				var distFromCenter:Number = (p2.x - p1.x) * (other._y + other.parent.y - p1.y - offsetY) / (p2.y - p1.y) + p1.x + offsetX;
				
				if ((p1.y + offsetY > other._y + other.parent.y) != (p2.y + offsetY > other._y + other.parent.y)
					&& (other._x + other.parent.x < distFromCenter))
				{
					edgesCrossed++;
				}
			}
			
			if (edgesCrossed & 1) return true;
			
			// check if minimum distance from circle center to each polygon side is less than radius
			var radiusSqr:Number = other.radius * other.radius;
			var cx:Number = other._x + other.parent.x;
			var cy:Number = other._y + other.parent.y;
			var minDistanceSqr:Number = 0;
			var closestX:Number;
			var closestY:Number;
			
			for (i = 0, j = nPoints - 1; i < nPoints; j = i, i++) {
				p1 = _transformedPoints[i];
				p2 = _transformedPoints[j];

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
		protected function collidePolygon(other:Polygon):Boolean
		{
			var offset:Number;
			var offsetX:Number = parent.x + _x - other.parent.x - other.x;
			var offsetY:Number = parent.y + _y - other.parent.y - other.y;
			var a:Point;
			
			// project other on this polygon axes
			// for a collision to be present all projections must overlap
			for (var i:int = 0; i < _axes.length; i++)
			{
				a = _axes[i];
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
			var p:Point = _transformedPoints[0];
			
			var min:Number = axis.x * p.x + axis.y * p.y,	// dot product
				max:Number = min;

			for (var i:int = 1; i < _transformedPoints.length; i++)
			{
				p = _transformedPoints[i];
				var cur:Number = axis.x * p.x + axis.y * p.y;	// dot product

				if (cur < min) min = cur;
				else if (cur > max) max = cur;
			}
			projection.min = min;
			projection.max = max;
		}

		override public function renderDebug(graphics:Graphics):void
		{
			if (parent != null)
			{
				var	offsetX:Number = parent.x +_x - FP.camera.x,
					offsetY:Number = parent.y +_y - FP.camera.y;

				var sx:Number = FP.screen.scaleX * FP.screen.scale;
				var sy:Number = FP.screen.scaleY * FP.screen.scale;
				
				graphics.beginFill(0xFFFFFF, .15);
				graphics.lineStyle(1, 0xFFFFFF, 0.25);
				
				graphics.moveTo((points[_transformedPoints.length - 1].x + offsetX) * sx , (_transformedPoints[_transformedPoints.length - 1].y + offsetY) * sy);
				for (var i:int = 0; i < _transformedPoints.length; i++)
				{
					graphics.lineTo((_transformedPoints[i].x + offsetX) * sx, (_transformedPoints[i].y + offsetY) * sy);
				}
				
				graphics.endFill();
				
				// draw pivot
				graphics.drawCircle((offsetX + pivotX) * sx + .5, (offsetY + pivotY) * sy + .5, 2);
			}
		}

		/**
		 * Rotation angle (in degrees) of the polygon (rotates around pivot point).
		 */
		public function get angle():Number { return _angle; }
		public function set angle(value:Number):void
		{
			if (value == _angle) return;
			_lastAngle = _angle;
			_angle = value;
			transformPoints();
			
			if (list != null || parent != null) update();
		}
	
		/** X coord to use for rotations. Defaults to top-left corner. */
		public function get pivotX():Number { return _pivotX; }
		public function set pivotX(value:Number):void
		{ 
			if (_pivotX == value) return;
			_pivotX = value;
			transformPoints();
			
			if (list != null || parent != null) update();
		}
		
		/** Y coord to use for rotations. Defaults to top-left corner. */
		public function get pivotY():Number { return _pivotY; }
		public function set pivotY(value:Number):void
		{ 
			if (_pivotY == value) return;
			_pivotY = value;
			transformPoints();
			
			if (list != null || parent != null) update();
		}
		
		/** Leftmost X coord of the polygon. */
		public function get minX():int { return _minX; }
		
		/** Rightmost X coord of the polygon. */
		public function get maxX():int { return _maxX; }
		
		/** Topmost Y coord of the polygon. */
		public function get minY():int { return _minY; }
		
		/** Bottommost Y coord of the polygon. */
		public function get maxY():int { return _maxY; }

		/**
		 * The original points (non transformed/rotated) representing the polygon.
		 * 
		 * If you need to set a point yourself instead of passing in a new Vector.<Point> you need to call update() 
		 * to makes sure the axes update as well.
		 */
		public function get points():Vector.<Point> { return _transformedPoints; }
		public function set points(value:Vector.<Point>):void
		{
			if (_transformedPoints == value) return;
			_transformedPoints = value;

			if (list != null || parent != null) updateAxes();
		}

		/**
		 * The transformed/rotated points representing the polygon.
		 */
		public function get transformedPoints():Vector.<Point> { return _transformedPoints; }

		/** Updates the parent's bounds for this mask. */
		override public function update():void
		{
			project(horizontalAxis, firstProj); // width
			var projX:int = Math.round(firstProj.min);
			_width = Math.round(firstProj.max - firstProj.min);
			project(verticalAxis, secondProj); // height
			var projY:int = Math.round(secondProj.min);
			_height = Math.round(secondProj.max - secondProj.min);

			_minX = _x + projX;
			_minY = _y + projY;
			_maxX = Math.round(minX + _width);
			_maxY = Math.round(minY + _height);
			
			if (list != null)
			{
				// update parent list
				list.update();
			}
			else if (parent != null)
			{
				parent.originX = -_x - projX;
				parent.originY = -_y - projY;
				parent.width = _width;
				parent.height = _height;
			}
		}

		/**
		 * Creates a regular polygon (edges of same length).
		 * @param	sides	The number of sides in the polygon
		 * @param	radius	The distance that the corners are at
		 * @param	angle	How much the polygon is rotated
		 * @return	The polygon
		 */
		public static function createRegular(sides:int, radius:Number, angle:Number = 0):Polygon
		{
			if (sides < 3) throw "The polygon needs at least 3 sides.";

			// figure out the angle required for each step
			var rotationAngle:Number = (Math.PI * 2) / sides;

			// loop through and generate each point
			var points:Vector.<Point> = new Vector.<Point>();

			var startAngle:Number = 0;
			for (var i:int = 0; i < sides; i++)
			{
				var p:Point = new Point();
				p.x = Math.cos(startAngle) * radius + radius;
				p.y = Math.sin(startAngle) * radius + radius;
				points.push(p);
				startAngle += rotationAngle;
			}
			
			// return the polygon
			var poly:Polygon = new Polygon(points);
			poly.angle = angle;
			return poly;
		}

		/**
		 * Creates a polygon from an array were even numbers are x and odd are y
		 * @param	points	Vector containing the polygon's points.
		 * @param	angle	How much the polygon is rotated
		 * 
		 * @return	The polygon
		 */
		public static function createFromFlatVector(points:Vector.<Number>, angle:Number = 0):Polygon
		{
			var p:Vector.<Point> = new Vector.<Point>();

			var i:int = 0;
			while (i < points.length)
			{
				p.push(new Point(points[i++], points[i++]));
			}
			var poly:Polygon = new Polygon(p);
			poly.angle = angle;
			return poly;
		}

		private function transformPoints():void 
		{
			var p:Point;
			var tp:Point;
			var angleRad:Number = _angle * FP.RAD;
			var lastAngleRad:Number = _lastAngle * FP.RAD;
			
			for (var i:int = 0; i < _points.length; i++)
			{
				p = _points[i];
				tp = _transformedPoints[i];
				var dx:Number = p.x - _pivotX;
				var dy:Number = p.y - _pivotY;

				var pointAngle:Number = Math.atan2(dy, dx);
				var length:Number = Math.sqrt(dx * dx + dy * dy);

				tp.x = Math.cos(pointAngle + angleRad) * length + _pivotX;
				tp.y = Math.sin(pointAngle + angleRad) * length + _pivotY;
			}
			var a:Point;
			
			for (var j:int = 0; j < _axes.length; j++)
			{
				a = _axes[j];

				var axisAngle:Number = Math.atan2(a.y, a.x);

				a.x = Math.cos(axisAngle + angleRad - lastAngleRad);
				a.y = Math.sin(axisAngle + angleRad - lastAngleRad);
			}
		}

		private function generateAxes():void
		{
			_axes = new Vector.<Point>();
			var temp:Number;
			var nPoints:int = _transformedPoints.length;
			var edge:Point;
			var i:int, j:int;
			
			for (i = 0, j = nPoints - 1; i < nPoints; j = i, i++) {
				edge = new Point();
				edge.x = _transformedPoints[i].x - _transformedPoints[j].x;
				edge.y = _transformedPoints[i].y - _transformedPoints[j].y;

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
			var i:int = _axes.length - 1;
			var j:int = i - 1;
			while (i > 0) 
			{
				// if the first vector is equal or similar to the second vector,
				// remove it from the list. (for example, [1, 1] and [-1, -1]
				// represent the same axis)
				if ((Math.abs(_axes[i].x - _axes[j].x) < EPSILON && Math.abs(_axes[i].y - _axes[j].y) < EPSILON)
					|| (Math.abs(_axes[j].x + _axes[i].x) < EPSILON && Math.abs(_axes[i].y + _axes[j].y) < EPSILON))	// first axis inverted
				{
					_axes.splice(i, 1);
					i--;
				}
				
				j--;
				if (j < 0) 
				{
					i--;
					j = i - 1;
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
		private var _lastAngle:Number;
		private var _points:Vector.<Point>;				// original points (non transformed/rotated) as passed in the constructor
		private var _transformedPoints:Vector.<Point>;	// transformed/rotated points
		private var _axes:Vector.<Point>;
		private var _projection:* = { min: 0.0, max:0.0 };

		// Polygon pivot point.
		private var _pivotX:Number = 0;
		private var _pivotY:Number = 0;
		
		// Polygon bounding box.
		private var _minX:int = 0;
		private var _minY:int = 0;
		private var _maxX:int = 0;
		private var _maxY:int = 0;
		
		private var _fakeEntity:Entity;			// used for Grid and Pixelmask collision
		private var _fakeTileHitbox:Hitbox;		// used for Grid collision
		private var _fakePixelmask:Pixelmask;	// used for Pixelmask collision
		
		private static var EPSILON:Number = 0.000000001;	// used for axes comparison in removeDuplicateAxes

		private static var _axis:Point = new Point();
		private static var firstProj:* = { min: 0.0, max:0.0 };
		private static var secondProj:* = { min: 0.0, max:0.0 };

		public static const verticalAxis:Point = new Point(0, 1);
		public static const horizontalAxis:Point = new Point(1, 0);
	}
}