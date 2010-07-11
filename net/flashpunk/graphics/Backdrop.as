package net.flashpunk.graphics 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import net.flashpunk.FP;
	import net.flashpunk.Graphic;
	
	/**
	 * A background texture that can be repeated horizontally and vertically
	 * when drawn. Really useful for parallax backgrounds, textures, etc.
	 */
	public class Backdrop extends Canvas
	{
		/**
		 * Constructor.
		 * @param	texture		Source texture.
		 * @param	repeatX		Repeat horizontally.
		 * @param	repeatY		Repeat vertically.
		 */
		public function Backdrop(texture:*, repeatX:Boolean = true, repeatY:Boolean = true) 
		{
			if (texture is Class) _texture = FP.getBitmap(texture);
			else if (texture is BitmapData) _texture = texture;
			if (!_texture) _texture = new BitmapData(FP.width, FP.height, true, 0);
			_repeatX = repeatX;
			_repeatY = repeatY;
			_textWidth = _texture.width;
			_textHeight = _texture.height;
			super(FP.width * uint(repeatX) + _textWidth, FP.height * uint(repeatY) + _textHeight);
			FP.rect.x = FP.rect.y = 0;
			FP.rect.width = _width;
			FP.rect.height = _height;
			fillTexture(FP.rect, _texture);
		}
		
		/** @private Renders the Backdrop. */
		override public function render(point:Point, camera:Point):void 
		{
			point.x += x - camera.x * scrollX;
			point.y += y - camera.y * scrollY;
			
			if (_repeatX)
			{
				point.x %= _textWidth;
				if (point.x > 0) point.x -= _textWidth;
			}
			
			if (_repeatY)
			{
				point.y %= _textHeight;
				if (point.y > 0) point.y -= _textHeight;
			}
			
			_x = x; _y = y;
			camera.x = camera.y = x = y = 0;
			super.render(point, camera);
			x = _x; y = _y;
		}
		
		// Backdrop information.
		/** @private */ private var _texture:BitmapData;
		/** @private */ private var _textWidth:uint;
		/** @private */ private var _textHeight:uint;
		/** @private */ private var _repeatX:Boolean;
		/** @private */ private var _repeatY:Boolean;
		/** @private */ private var _x:Number;
		/** @private */ private var _y:Number;
	}
}