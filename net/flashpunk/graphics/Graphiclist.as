package net.flashpunk.graphics 
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import net.flashpunk.*;
	
	/**
	 * A Graphic that can contain multiple Graphics of one or various types.
	 * Useful for drawing sprites with multiple different parts, etc.
	 */
	public class Graphiclist extends Graphic
	{
		/**
		 * Constructor.
		 * @param	...graphic		Graphic objects to add to the list.
		 */
		public function Graphiclist(...graphic) 
		{
			for each (var g:Graphic in graphic) add(g);
		}
		
		/** @private Renders the Graphics in the list. */
		override public function render(point:Point, camera:Point):void 
		{
			point.x += x;
			point.y += y;
			camera.x *= scrollX;
			camera.y *= scrollY;
			for each (var g:Graphic in _graphics)
			{
				if (g.visible)
				{
					_point.x = point.x;
					_point.y = point.y;
					_camera.x = camera.x;
					_camera.y = camera.y;
					g.render(_point, _camera);
				}
			}
		}
		
		/**
		 * Adds the Graphic to the list.
		 * @param	graphic		The Graphic to add.
		 * @return	The added Graphic.
		 */
		public function add(graphic:Graphic):Graphic
		{
			_graphics[_count ++] = graphic;
			return graphic;
		}
		
		/**
		 * Removes the Graphic from the list.
		 * @param	graphic		The Graphic to remove.
		 * @return	The removed Graphic.
		 */
		public function remove(graphic:Graphic):Graphic
		{
			if (_graphics.indexOf(graphic) < 0) return graphic;
			_temp.length = 0;
			for each (var g:Graphic in _graphics)
			{
				if (g == graphic) _count --;
				else _temp[_temp.length] = g;
			}
			var temp:Vector.<Graphic> = _graphics;
			_graphics = _temp;
			_temp = temp;
			return graphic;
		}
		
		/**
		 * Removes the Graphic from the position in the list.
		 * @param	index		Index to remove.
		 */
		public function removeAt(index:uint = 0):void
		{
			if (!_graphics.length) return;
			index %= _graphics.length;
			remove(_graphics[index % _graphics.length]);
		}
		
		/**
		 * Removes all Graphics from the list.
		 */
		public function removeAll():void
		{
			_graphics.length = _temp.length = _count = 0;
		}
		
		/**
		 * All Graphics in this list.
		 */
		public function get children():Vector.<Graphic> { return _graphics; }
		
		/**
		 * Amount of Graphics in this list.
		 */
		public function get count():uint { return _count; }
		
		// List information.
		/** @private */ private var _graphics:Vector.<Graphic> = new Vector.<Graphic>;
		/** @private */ private var _temp:Vector.<Graphic> = new Vector.<Graphic>;
		/** @private */ private var _count:uint;
		/** @private */ private var _point:Point = new Point;
		/** @private */ private var _camera:Point = new Point;
	}
}