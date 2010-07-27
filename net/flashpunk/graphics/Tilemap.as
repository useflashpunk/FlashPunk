package net.flashpunk.graphics 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.flashpunk.Graphic;
	import net.flashpunk.FP;
	
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
			_width = width - (width % tileWidth);
			_height = height - (height % tileHeight);
			_columns = _width / tileWidth;
			_rows = _height / tileHeight;
			_map = new BitmapData(_columns, _rows, false, 0);
			_tile = new Rectangle(0, 0, tileWidth, tileHeight);
			
			// create the canvas
			_maxWidth -= _maxWidth % tileWidth;
			_maxHeight -= _maxHeight % tileHeight;
			super(_width, _height);
			
			// load the tileset graphic
			if (tileset is Class) _set = FP.getBitmap(tileset);
			else if (tileset is BitmapData) _set = tileset;
			if (!_set) throw new Error("Invalid tileset graphic provided.");
			_setColumns = uint(_set.width / tileWidth);
			_setRows = uint(_set.height / tileHeight);
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
			_map.setPixel(column, row, index);
			draw(column * _tile.width, row * _tile.height, _set, _tile);
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
			fill(_tile, 0);
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
		 * Sets a region of tiles to the index.
		 * @param	column		First tile column.
		 * @param	row			First tile row.
		 * @param	width		Width in tiles.
		 * @param	height		Height in tiles.
		 * @param	index		Tile index.
		 */
		public function setRegion(column:uint, row:uint, width:uint = 1, height:uint = 1, index:uint = 0):void
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
		 * Clears the region of tiles.
		 * @param	column		First tile column.
		 * @param	row			First tile row.
		 * @param	width		Width in tiles.
		 * @param	height		Height in tiles.
		 */
		public function clearRegion(column:uint, row:uint, width:uint = 1, height:uint = 1):void
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
					s += getTile(x, y);
					if (x != _columns - 1) s += columnSep;
				}
				if (y != _rows - 1) s += rowSep;
			}
			return s;
		}
		
		/**
		 * Gets the index of a tile, based on its column and row in the tileset.
		 * @param	tilesColumn		Tileset column.
		 * @param	tilesRow		Tileset row.
		 * @return	Index of the tile.
		 */
		public function getIndex(tilesColumn:uint, tilesRow:uint):uint
		{
			return (tilesRow % _setRows) * _setColumns + (tilesColumn % _setColumns);
		}
		
		/**
		 * The tile width.
		 */
		public function get tileWidth():uint { return _tile.width; }
		
		/**
		 * The tile height.
		 */
		public function get tileHeight():uint { return _tile.height; }
		
		
		// Tilemap information.
		/** @private */ private var _map:BitmapData;
		/** @private */ private var _columns:uint;
		/** @private */ private var _rows:uint;
		
		// Tileset information.
		/** @private */ private var _set:BitmapData;
		/** @private */ private var _setColumns:uint;
		/** @private */ private var _setRows:uint;
		/** @private */ private var _setCount:uint;
		/** @private */ private var _tile:Rectangle;
		
		// Global objects.
		/** @private */ private var _point:Point = FP.point;
		/** @private */ private var _rect:Rectangle = FP.rect;
	}
}