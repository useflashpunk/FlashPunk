package net.flashpunk.graphics 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.flashpunk.FP;
	import net.flashpunk.Graphic;
	import net.flashpunk.masks.Grid;
	import net.flashpunk.utils.Draw;
	
	/**
	 * A canvas to which Tiles can be drawn for fast multiple tile rendering.
	 */
	public class Tilemap extends Canvas
	{
		/**
		 * If x/y positions should be used instead of columns/rows.
		 */
		public var usePositions:Boolean;
		
		/**
		 * Constructor.
		 * @param	tileset			The source tileset image.
		 * @param	width			Width of the tilemap, in pixels.
		 * @param	height			Height of the tilemap, in pixels.
		 * @param	tileWidth		Tile width.
		 * @param	tileHeight		Tile height.
		 */
		public function Tilemap(tileset:*, width:uint, height:uint, tileWidth:uint, tileHeight:uint) 
		{
			// set some tilemap information
			_width = width;
			_height = height;
			_columns = Math.ceil(_width / tileWidth);
			_rows = Math.ceil(_height / tileHeight);
			_map = new BitmapData(_columns, _rows, false, 0);
			_temp = _map.clone();
			_tile = new Rectangle(0, 0, tileWidth, tileHeight);
			
			// create the canvas
			_maxWidth -= _maxWidth % tileWidth;
			_maxHeight -= _maxHeight % tileHeight;
			super(_width, _height);
			
			// load the tileset graphic
			if (tileset is Class) _set = FP.getBitmap(tileset);
			else if (tileset is BitmapData) _set = tileset;
			if (!_set) throw new Error("Invalid tileset graphic provided.");
			_setColumns = Math.ceil(_set.width / tileWidth);
			_setRows = Math.ceil(_set.height / tileHeight);
			_setCount = _setColumns * _setRows;
		}
		
		/**
		 * Sets the index of the tile at the position.
		 * @param	column		Tile column.
		 * @param	row			Tile row.
		 * @param	index		Tile index.
		 */
		public function setTile(column:uint, row:uint, index:uint = 0):void
		{
			if (usePositions)
			{
				column /= _tile.width;
				row /= _tile.height;
			}
			index %= _setCount;
			column %= _columns;
			row %= _rows;
			_tile.x = (index % _setColumns) * _tile.width;
			_tile.y = uint(index / _setColumns) * _tile.height;
			_point.x = column * _tile.width;
			_point.y = row * _tile.height;
			_map.setPixel(column, row, index);
			copyPixels(_set, _tile, _point, null, null, false);
		}
		
		/**
		 * Clears the tile at the position.
		 * @param	column		Tile column.
		 * @param	row			Tile row.
		 */
		public function clearTile(column:uint, row:uint):void
		{
			if (usePositions)
			{
				column /= _tile.width;
				row /= _tile.height;
			}
			column %= _columns;
			row %= _rows;
			_tile.x = column * _tile.width;
			_tile.y = row * _tile.height;
			fill(_tile, 0, 0);
		}
		
		/**
		 * Gets the tile index at the position.
		 * @param	column		Tile column.
		 * @param	row			Tile row.
		 * @return	The tile index.
		 */
		public function getTile(column:uint, row:uint):uint
		{
			if (usePositions)
			{
				column /= _tile.width;
				row /= _tile.height;
			}
			return _map.getPixel(column % _columns, row % _rows);
		}
		
		/**
		 * Sets a rectangular region of tiles to the index.
		 * @param	column		First tile column.
		 * @param	row			First tile row.
		 * @param	width		Width in tiles.
		 * @param	height		Height in tiles.
		 * @param	index		Tile index.
		 */
		public function setRect(column:uint, row:uint, width:uint = 1, height:uint = 1, index:uint = 0):void
		{
			if (usePositions)
			{
				column /= _tile.width;
				row /= _tile.height;
				width /= _tile.width;
				height /= _tile.height;
			}
			column %= _columns;
			row %= _rows;
			var c:uint = column,
				r:uint = column + width,
				b:uint = row + height,
				u:Boolean = usePositions;
			usePositions = false;
			while (row < b)
			{
				while (column < r)
				{
					setTile(column, row, index);
					column ++;
				}
				column = c;
				row ++;
			}
			usePositions = u;
		}
		
		/**
		 * Makes a flood fill on the tilemap
		 * @param	column		Column to place the flood fill
		 * @param	row			Row to place the flood fill
		 * @param	index		Tile index.
		 */
		public function floodFill(column:uint, row:uint, index:uint = 0):void
		{
			if(usePositions)
			{
				column /= _tile.width;
				row /= _tile.height;
			}
			
			column %= _columns;
			row %= _rows;
			
			_map.floodFill(column, row, index);
			
			updateAll();
		}
		
		/**
		 * Draws a line of tiles
		 *  
		 * @param	x1		The x coordinate to start
		 * @param	y1		The y coordinate to start
		 * @param	x2		The x coordinate to end
		 * @param	y2		The y coordinate to end
		 * @param	id		The tiles id to draw
		 * 
		 */		
		public function line(x1:int, y1:int, x2:int, y2:int, id:int):void
		{
			if(usePositions)
			{
				x1 /= _tile.width;
				y1 /= _tile.height;
				x2 /= _tile.width;
				y2 /= _tile.height;
			}
			
			x1 %= _columns;
			y1 %= _rows;
			x2 %= _columns;
			y2 %= _rows;
			
			Draw.setTarget(_map);
			Draw.line(x1, y1, x2, y2, id, 0);
			updateAll();
		}
		
		/**
		 * Draws an outline of a rectangle of tiles
		 *  
		 * @param	x		The x coordinate of the rectangle
		 * @param	y		The y coordinate of the rectangle
		 * @param	width	The width of the rectangle
		 * @param	height	The height of the rectangle
		 * @param	id		The tiles id to draw
		 * 
		 */		
		public function setRectOutline(x:int, y:int, width:int, height:int, id:int):void
		{
			if(usePositions)
			{
				x /= _tile.width;
				y /= _tile.height;
				
				// TODO: might want to use difference between converted start/end coordinates instead?
				width /= _tile.width;
				height /= _tile.height;
			}
			
			x %= _columns;
			y %= _rows;
			
			Draw.setTarget(_map);
			Draw.line(x, y, x + width, y, id, 0);
			Draw.line(x, y + height, x + width, y + height, id, 0);
			Draw.line(x, y, x, y + height, id, 0);
			Draw.line(x + width, y, x + width, y + height, id, 0);
			updateAll();
		}
		
		/**
		 * Updates the graphical cache for the whole tilemap.
		 */		
		public function updateAll():void
		{
			_rect.x = 0;
			_rect.y = 0;
			_rect.width = _columns;
			_rect.height = _rows;
			updateRect(_rect, false);
		}
		
		/**
		 * Clears the rectangular region of tiles.
		 * @param	column		First tile column.
		 * @param	row			First tile row.
		 * @param	width		Width in tiles.
		 * @param	height		Height in tiles.
		 */
		public function clearRect(column:uint, row:uint, width:uint = 1, height:uint = 1):void
		{
			if (usePositions)
			{
				column /= _tile.width;
				row /= _tile.height;
				width /= _tile.width;
				height /= _tile.height;
			}
			column %= _columns;
			row %= _rows;
			var c:uint = column,
				r:uint = column + width,
				b:uint = row + height,
				u:Boolean = usePositions;
			usePositions = false;
			while (row < b)
			{
				while (column < r)
				{
					clearTile(column, row);
					column ++;
				}
				column = c;
				row ++;
			}
			usePositions = u;
		}
		
		/**
		* Loads the Tilemap tile index data from a string.
		* @param str			The string data, which is a set of tile values separated by the columnSep and rowSep strings.
		* @param columnSep		The string that separates each tile value on a row, default is ",".
		* @param rowSep			The string that separates each row of tiles, default is "\n".
		*/
		public function loadFromString(str:String, columnSep:String = ",", rowSep:String = "\n"):void
		{
			var u:Boolean = usePositions;
			usePositions = false;
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
					setTile(x, y, uint(col[x]));
				}
			}
			
			usePositions = u;
		}
		
		/**
		* Saves the Tilemap tile index data to a string.
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
					s += String(_map.getPixel(x, y));
					if (x != _columns - 1) s += columnSep;
				}
				if (y != _rows - 1) s += rowSep;
			}
			return s;
		}
		
		/**
		 * Gets the 1D index of a tile from a 2D index (its column and row in the tileset image).
		 * @param	tilesColumn		Tileset column.
		 * @param	tilesRow		Tileset row.
		 * @return	Index of the tile.
		 */
		public function getIndex(tilesColumn:uint, tilesRow:uint):uint
		{
			if (usePositions) {
				tilesColumn /= _tile.width;
				tilesRow /= _tile.height;
			}
			
			return (tilesRow % _setRows) * _setColumns + (tilesColumn % _setColumns);
		}
		
		/**
		 * Shifts all the tiles in the tilemap.
		 * @param	columns		Horizontal shift.
		 * @param	rows		Vertical shift.
		 * @param	wrap		If tiles shifted off the canvas should wrap around to the other side.
		 */
		public function shiftTiles(columns:int, rows:int, wrap:Boolean = false):void
		{
			if (usePositions)
			{
				columns /= _tile.width;
				rows /= _tile.height;
			}
			
			if (!wrap) _temp.fillRect(_temp.rect, 0);
			
			if (columns != 0)
			{
				shift(columns * _tile.width, 0);
				if (wrap) _temp.copyPixels(_map, _map.rect, FP.zero);
				_map.scroll(columns, 0);
				_point.y = 0;
				_point.x = columns > 0 ? columns - _columns : columns + _columns;
				_map.copyPixels(_temp, _temp.rect, _point);
				
				_rect.x = columns > 0 ? 0 : _columns + columns;
				_rect.y = 0;
				_rect.width = Math.abs(columns);
				_rect.height = _rows;
				updateRect(_rect, !wrap);
			}
			
			if (rows != 0)
			{
				shift(0, rows * _tile.height);
				if (wrap) _temp.copyPixels(_map, _map.rect, FP.zero);
				_map.scroll(0, rows);
				_point.x = 0;
				_point.y = rows > 0 ? rows - _rows : rows + _rows;
				_map.copyPixels(_temp, _temp.rect, _point);
				
				_rect.x = 0;
				_rect.y = rows > 0 ? 0 : _rows + rows;
				_rect.width = _columns;
				_rect.height = Math.abs(rows);
				updateRect(_rect, !wrap);
			}
		}
		
		/**
		 * Get a subregion of the tilemap and return it as a new Tilemap.
		 */
		public function getSubMap (x:int, y:int, w:int, h:int):Tilemap
		{
			if (usePositions) {
				x /= _tile.width;
				y /= _tile.height;
				w /= _tile.width;
				h /= _tile.height;
			}
			
			var newMap:Tilemap = new Tilemap(_set, w*_tile.width, h*_tile.height, _tile.width, _tile.height);
			
			_rect.x = x;
			_rect.y = y;
			_rect.width = w;
			_rect.height = h;
			
			newMap._map.copyPixels(_map, _rect, FP.zero);
			newMap.drawGraphic(-x * _tile.width, -y * _tile.height, this);
			
			return newMap;
		}
		
		/** Updates the graphical cache of a region of the tilemap. */
		public function updateRect(rect:Rectangle, clear:Boolean):void
		{
			var x:int = rect.x,
				y:int = rect.y,
				w:int = x + rect.width,
				h:int = y + rect.height,
				u:Boolean = usePositions;
			usePositions = false;
			if (clear)
			{
				while (y < h)
				{
					while (x < w) clearTile(x ++, y);
					x = rect.x;
					y ++;
				}
			}
			else
			{
				while (y < h)
				{
					while (x < w) updateTile(x ++, y);
					x = rect.x;
					y ++;
				}
			}
			usePositions = u;
		}
		
		/** @private Used by shiftTiles to update a tile from the tilemap. */
		private function updateTile(column:uint, row:uint):void
		{
			setTile(column, row, _map.getPixel(column % _columns, row % _rows));
		}
		
		/**
		* Create a Grid object from this tilemap.
		* @param	solidTiles		Array of tile indexes that should be solid.
		* @return Grid
		*/
		public function createGrid(solidTiles:Array, cls:Class=null):Grid
		{
			if (cls === null) cls = Grid;
			var grid:Grid = new cls(width, height, _tile.width, _tile.height, 0) as Grid;
			for (var row:uint = 0; row < _rows; ++row)
			{
				for (var col:uint = 0; col < _columns; ++col)
				{
					if (solidTiles.indexOf(_map.getPixel(col, row)) !== -1)
					{
						grid.setTile(col, row, true);
					}
				}
			}
			return grid;
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
		 * How many columns the tilemap has.
		 */
		public function get columns():uint { return _columns; }
		
		/**
		 * How many rows the tilemap has.
		 */
		public function get rows():uint { return _rows; }
		
		// Tilemap information.
		/** @private */ private var _map:BitmapData;
		/** @private */ private var _temp:BitmapData;
		/** @private */ private var _columns:uint;
		/** @private */ private var _rows:uint;
		
		// Tileset information.
		/** @private */ private var _set:BitmapData;
		/** @private */ private var _setColumns:uint;
		/** @private */ private var _setRows:uint;
		/** @private */ private var _setCount:uint;
		/** @private */ private var _tile:Rectangle;
		
		// Global objects.
		/** @private */ private var _rect:Rectangle = FP.rect;
	}
}
