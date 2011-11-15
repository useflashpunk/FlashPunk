package net.flashpunk.masks
{
	import flash.display.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.flashpunk.*;
	
	/**
	 * Uses a hash grid to determine collision, faster than
	 * using hundreds of Entities for tiled levels, etc.
	 */
	public class Grid extends Hitbox
	{
		/**
		 * If x/y positions should be used instead of columns/rows.
		 */
		public var usePositions:Boolean;
		
		/**
		 * Constructor.
		 * @param	width			Width of the grid, in pixels.
		 * @param	height			Height of the grid, in pixels.
		 * @param	tileWidth		Width of a grid tile, in pixels.
		 * @param	tileHeight		Height of a grid tile, in pixels.
		 * @param	x				X offset of the grid.
		 * @param	y				Y offset of the grid.
		 */
		public function Grid(width:uint, height:uint, tileWidth:uint, tileHeight:uint, x:int = 0, y:int = 0) 
		{
			// check for illegal grid size
			if (!width || !height || !tileWidth || !tileHeight) throw new Error("Illegal Grid, sizes cannot be 0.");
			
			// set grid properties
			_columns = width / tileWidth;
			_rows = height / tileHeight;
			_data = new BitmapData(_columns, _rows, true, 0);
			_tile = new Rectangle(0, 0, tileWidth, tileHeight);
			_x = x;
			_y = y;
			_width = width;
			_height = height;
			
			// set callback functions
			_check[Mask] = collideMask;
			_check[Hitbox] = collideHitbox;
			_check[Pixelmask] = collidePixelmask;
			_check[Grid] = collideGrid;
		}
		
		/**
		 * Sets the value of the tile.
		 * @param	column		Tile column.
		 * @param	row			Tile row.
		 * @param	solid		If the tile should be solid.
		 */
		public function setTile(column:uint = 0, row:uint = 0, solid:Boolean = true):void
		{
			if (usePositions)
			{
				column /= _tile.width;
				row /= _tile.height;
			}
			_data.setPixel32(column, row, solid ? 0xFFFFFFFF : 0);
		}
		
		/**
		 * Makes the tile non-solid.
		 * @param	column		Tile column.
		 * @param	row			Tile row.
		 */
		public function clearTile(column:uint = 0, row:uint = 0):void
		{
			setTile(column, row, false);
		}
		
		/**
		 * Gets the value of a tile.
		 * @param	column		Tile column.
		 * @param	row			Tile row.
		 * @return	tile value.
		 */
		public function getTile(column:uint = 0, row:uint = 0):Boolean
		{
			if (usePositions)
			{
				column /= _tile.width;
				row /= _tile.height;
			}
			return _data.getPixel32(column, row) > 0;
		}
		
		/**
		 * Sets the value of a rectangle region of tiles.
		 * @param	column		First column.
		 * @param	row			First row.
		 * @param	width		Columns to fill.
		 * @param	height		Rows to fill.
		 * @param	solid		If the tiles should be solid.
		 */
		public function setRect(column:uint = 0, row:uint = 0, width:int = 1, height:int = 1, solid:Boolean = true):void
		{
			if (usePositions)
			{
				column /= _tile.width;
				row /= _tile.height;
				width /= _tile.width;
				height /= _tile.height;
			}
			_rect.x = column;
			_rect.y = row;
			_rect.width = width;
			_rect.height = height;
			_data.fillRect(_rect, solid ? 0xFFFFFFFF : 0);
		}
		
		/**
		 * Makes the rectangular region of tiles non-solid.
		 * @param	column		First column.
		 * @param	row			First row.
		 * @param	width		Columns to fill.
		 * @param	height		Rows to fill.
		 */
		public function clearRect(column:uint = 0, row:uint = 0, width:int = 1, height:int = 1):void
		{
			setRect(column, row, width, height, false);
		}
		
		/**
		* Loads the grid data from a string.
		* @param str			The string data, which is a set of tile values (0 or 1) separated by the columnSep and rowSep strings.
		* @param columnSep		The string that separates each tile value on a row, default is ",".
		* @param rowSep			The string that separates each row of tiles, default is "\n".
		*/
		public function loadFromString(str:String, columnSep:String = ",", rowSep:String = "\n"):void
		{
			var row:Array = str.split(rowSep),
				rows:int = row.length,
				col:Array, cols:int, x:int, y:int;
			for (y = 0; y < rows; y ++)
			{
				if (row[y] == '') continue;
				col = row[y].split(columnSep),
				cols = col.length;
				for (x = 0; x < cols; x ++)
				{
					if (col[x] == '') continue;
					setTile(x, y, uint(col[x]) > 0);
				}
			}
		}
		
		/**
		* Saves the grid data to a string.
		* @param columnSep		The string that separates each tile value on a row, default is ",".
		* @param rowSep			The string that separates each row of tiles, default is "\n".
		*/
		public function saveToString(columnSep:String = ",", rowSep:String = "\n"): String
		{
			var s:String = '',
				x:int, y:int;
			for (y = 0; y < _rows; y ++)
			{
				for (x = 0; x < _columns; x ++)
				{
					s += getTile(x, y) ? '1' : '0';
					if (x != _columns - 1) s += columnSep;
				}
				if (y != _rows - 1) s += rowSep;
			}
			return s;
		}
		
		/**
		 * The tile width.
		 */
		public function get tileWidth():uint { return _tile.width; }
		
		/**
		 * The tile height.
		 */
		public function get tileHeight():uint { return _tile.height; }
		
		/**
		 * How many columns the grid has
		 */
		public function get columns():uint { return _columns; }
		
		/**
		 * How many rows the grid has.
		 */
		public function get rows():uint { return _rows; }
		
		/**
		 * The grid data.
		 */
		public function get data():BitmapData { return _data; }
		
		/** @private Collides against an Entity. */
		private function collideMask(other:Mask):Boolean
		{
			_rect.x = other.parent.x - other.parent.originX - parent.x + parent.originX;
			_rect.y = other.parent.y - other.parent.originY - parent.y + parent.originY;
			_point.x = int((_rect.x + other.parent.width - 1) / _tile.width) + 1;
			_point.y = int((_rect.y + other.parent.height -1) / _tile.height) + 1;
			_rect.x = int(_rect.x / _tile.width);
			_rect.y = int(_rect.y / _tile.height);
			_rect.width = _point.x - _rect.x;
			_rect.height = _point.y - _rect.y;
			return _data.hitTest(FP.zero, 1, _rect);
		}
		
		/** @private Collides against a Hitbox. */
		private function collideHitbox(other:Hitbox):Boolean
		{
			_rect.x = other.parent.x + other._x - parent.x - _x;
			_rect.y = other.parent.y + other._y - parent.y - _y;
			_point.x = int((_rect.x + other._width - 1) / _tile.width) + 1;
			_point.y = int((_rect.y + other._height -1) / _tile.height) + 1;
			_rect.x = int(_rect.x / _tile.width);
			_rect.y = int(_rect.y / _tile.height);
			_rect.width = _point.x - _rect.x;
			_rect.height = _point.y - _rect.y;
			return _data.hitTest(FP.zero, 1, _rect);
		}
		
		/** @private Collides against a Pixelmask. */
		private function collidePixelmask(other:Pixelmask):Boolean
		{
			var x1:int = other.parent.x + other._x - parent.x - _x,
				y1:int = other.parent.y + other._y - parent.y - _y,
				x2:int = ((x1 + other._width - 1) / _tile.width),
				y2:int = ((y1 + other._height - 1) / _tile.height);
			_point.x = x1;
			_point.y = y1;
			x1 /= _tile.width;
			y1 /= _tile.height;
			_tile.x = x1 * _tile.width;
			_tile.y = y1 * _tile.height;
			var xx:int = x1;
			while (y1 <= y2)
			{
				while (x1 <= x2)
				{
					if (_data.getPixel32(x1, y1))
					{
						if (other._data.hitTest(_point, 1, _tile)) return true;
					}
					x1 ++;
					_tile.x += _tile.width;
				}
				x1 = xx;
				y1 ++;
				_tile.x = x1 * _tile.width;
				_tile.y += _tile.height;
			}
			return false;
		}
		
		/** @private Collides against a Grid. */
		private function collideGrid(other:Grid):Boolean
		{
			// Find the X edges
			var ax1:Number = parent.x + _x;
			var ax2:Number = ax1 + _width;
			var bx1:Number = other.parent.x + other._x;
			var bx2:Number = bx1 + other._width;
			if (ax2 < bx1 || ax1 > bx2) return false;
			
			// Find the Y edges
			var ay1:Number = parent.y + _y;
			var ay2:Number = ay1 + _height;
			var by1:Number = other.parent.y + other._y;
			var by2:Number = by1 + other._height;
			if (ay2 < by1 || ay1 > by2) return false;
			
			// Find the overlapping area
			var ox1:Number = ax1 > bx1 ? ax1 : bx1;
			var oy1:Number = ay1 > by1 ? ay1 : by1;
			var ox2:Number = ax2 < bx2 ? ax2 : bx2;
			var oy2:Number = ay2 < by2 ? ay2 : by2;
			
			// Find the smallest tile size, and snap the top and left overlapping
			// edges to that tile size. This ensures that corner checking works
			// properly.
			var tw:Number, th:Number;
			if (_tile.width < other._tile.width)
			{
				tw = _tile.width;
				ox1 -= parent.x + _x;
				ox1 = int(ox1 / tw) * tw;
				ox1 += parent.x + _x;
			}
			else
			{
				tw = other._tile.width;
				ox1 -= other.parent.x + other._x;
				ox1 = int(ox1 / tw) * tw;
				ox1 += other.parent.x + other._x;
			}
			if (_tile.height < other._tile.height)
			{
				th = _tile.height;
				oy1 -= parent.y + _y;
				oy1 = int(oy1 / th) * th;
				oy1 += parent.y + _y;
			}
			else
			{
				th = other._tile.height;
				oy1 -= other.parent.y + other._y;
				oy1 = int(oy1 / th) * th;
				oy1 += other.parent.y + other._y;
			}
			
			// Step through the overlapping rectangle
			for (var y:Number = oy1; y < oy2; y += th)
			{
				// Get the row indices for the top and bottom edges of the tile
				var ar1:int = (y - parent.y - _y) / _tile.height;
				var br1:int = (y - other.parent.y - other._y) / other._tile.height;
				var ar2:int = ((y - parent.y - _y) + (th - 1)) / _tile.height;
				var br2:int = ((y - other.parent.y - other._y) + (th - 1)) / other._tile.height;
				for (var x:Number = ox1; x < ox2; x += tw)
				{
					// Get the column indices for the left and right edges of the tile
					var ac1:int = (x - parent.x - _x) / _tile.width;
					var bc1:int = (x - other.parent.x - other._x) / other._tile.width;
					var ac2:int = ((x - parent.x - _x) + (tw - 1)) / _tile.width;
					var bc2:int = ((x - other.parent.x - other._x) + (tw - 1)) / other._tile.width;
					
					// Check all the corners for collisions
					if ((_data.getPixel32(ac1, ar1) > 0 && other._data.getPixel32(bc1, br1) > 0)
					 || (_data.getPixel32(ac2, ar1) > 0 && other._data.getPixel32(bc2, br1) > 0)
					 || (_data.getPixel32(ac1, ar2) > 0 && other._data.getPixel32(bc1, br2) > 0)
					 || (_data.getPixel32(ac2, ar2) > 0 && other._data.getPixel32(bc2, br2) > 0))
					{
						return true;
					}
				}
			}
			
			return false;
		}
		
		public override function renderDebug(g:Graphics):void
		{
			var sx:Number = FP.screen.scaleX * FP.screen.scale;
			var sy:Number = FP.screen.scaleY * FP.screen.scale;
			
			var x:int, y:int;
			
			g.lineStyle(1, 0xFFFFFF, 0.25);
			
			for (y = 0; y < _rows; y ++)
			{
				for (x = 0; x < _columns; x ++)
				{
					if (_data.getPixel32(x, y))
					{
						g.drawRect((parent.x - parent.originX - FP.camera.x + x * _tile.width) * sx, (parent.y - parent.originY - FP.camera.y + y * _tile.height) * sy, _tile.width * sx, _tile.height * sy);
					}
				}
			}
		}
		
		// Grid information.
		/** @private */ private var _data:BitmapData;
		/** @private */ private var _columns:uint;
		/** @private */ private var _rows:uint;
		/** @private */ private var _tile:Rectangle;
		/** @private */ private var _rect:Rectangle = FP.rect;
		/** @private */ private var _point:Point = FP.point;
	}
}
