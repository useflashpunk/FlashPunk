package net.flashpunk.graphics 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	import net.flashpunk.FP;
	import net.flashpunk.Graphic;
	
	/**
	 * Used for drawing text using embedded fonts.
	 */
	public class Text extends Image
	{
		/**
		 * The font to assign to new Text objects.
		 */
		public static var font:String = "default";
		
		/**
		 * The font size to assign to new Text objects.
		 */
		public static var size:uint = 16;
		
		/**
		 * The alignment to assign to new Text objects.
		 */
		public static var align:String = "left";
		
		/**
		 * The wordWrap property to assign to new Text objects.
		 */
		public static var wordWrap:Boolean = false;
		
		/**
		 * If the text field can automatically resize if its contents grow.
		 */
		public var resizable: Boolean = true;
		
		/**
		 * Constructor.
		 * @param	text		Text to display.
		 * @param	x			X offset.
		 * @param	y			Y offset.
		 * @param	width		Image width (leave as 0 to size to the starting text string).
		 * @param	height		Image height (leave as 0 to size to the starting text string).
		 */
		public function Text(text:String, x:Number = 0, y:Number = 0, width:uint = 0, height:uint = 0)
		{
			_font = Text.font;
			_size = Text.size;
			_align = Text.align;
			_wordWrap = Text.wordWrap;
			
			_field.embedFonts = true;
			_field.wordWrap = _wordWrap;
			_form = new TextFormat(_font, _size, 0xFFFFFF);
			_form.align = _align;
			_field.defaultTextFormat = _form;
			_field.text = _text = text;
			_width = width || _field.textWidth + 4;
			_height = height || _field.textHeight + 4;
			_source = new BitmapData(_width, _height, true, 0);
			_sourceRect = _source.rect;
			super(_source);
			updateBuffer();
			this.x = x;
			this.y = y;
		}
		
		/** @private Updates the drawing buffer. */
		override public function updateBuffer():void 
		{
			_field.setTextFormat(_form);
			_field.width = _width;
			_textWidth = _field.textWidth + 4;
			_textHeight = _field.textHeight + 4;
			
			if (resizable && (_textWidth > _width || _textHeight > _height))
			{
				if (_width < _textWidth) _width = _textWidth;
				if (_height < _textHeight) _height = _textHeight;
			}
			
			if (_width > _source.width || _height > _source.height)
			{
				_source = new BitmapData(
					Math.max(_width, _source.width),
					Math.max(_height, _source.height),
					true, 0);
				
				_sourceRect = _source.rect;
				_buffer = new BitmapData(_sourceRect.width, _sourceRect.height, true, 0);
				_bufferRect = _buffer.rect;
			}
			else
			{
				_source.fillRect(_sourceRect, 0);
			}
			
			_field.width = _width;
			_field.height = _height;
			
			_source.draw(_field);
			super.updateBuffer();
		}
		
		/**
		 * Text string.
		 */
		public function get text():String { return _text; }
		public function set text(value:String):void
		{
			if (_text == value) return;
			_field.text = _text = value;
			updateBuffer();
		}
		
		/**
		 * Font family.
		 */
		public function get font():String { return _font; }
		public function set font(value:String):void
		{
			if (_font == value) return;
			_form.font = _font = value;
			updateBuffer();
		}
		
		/**
		 * Font size.
		 */
		public function get size():uint { return _size; }
		public function set size(value:uint):void
		{
			if (_size == value) return;
			_form.size = _size = value;
			updateBuffer();
		}
		
		/**
		 * Alignment ("left", "center" or "right").
		 * Only relevant if text spans multiple lines.
		 */
		public function get align():String { return _align; }
		public function set align(value:String):void
		{
			if (_align == value) return;
			_form.align = _align = value;
			updateBuffer();
		}
		
		/**
		 * Alignment ("left", "center" or "right").
		 * Only relevant if text spans multiple lines.
		 */
		public function get wordWrap():Boolean { return _wordWrap; }
		public function set wordWrap(value:Boolean):void
		{
			if (_wordWrap == value) return;
			_field.wordWrap = _wordWrap = value;
			updateBuffer();
		}
		
		/**
		 * Width of the text image.
		 */
		override public function get width():uint { return _width * scaleX * scale; }
		public function set width(value:uint):void
		{
			value /= scaleX * scale;
			if (_width == value) return;
			_width = value;
			updateBuffer();
		}
		
		/**
		 * Height of the text image.
		 */
		override public function get height():uint { return _height * scaleY * scale; }
		public function set height(value:uint):void
		{
			value /= scaleY * scale;
			if (_height == value) return;
			_height = value;
			updateBuffer();
		}
		
		/**
		 * Width of the text within the image.
		 */
		public function get textWidth():uint { return _textWidth; }
		
		/**
		 * Height of the text within the image.
		 */
		public function get textHeight():uint { return _textHeight; }
		
		// Text information.
		/** @private */ private var _field:TextField = new TextField;
		/** @private */ private var _width:uint;
		/** @private */ private var _height:uint;
		/** @private */ private var _textWidth:uint;
		/** @private */ private var _textHeight:uint;
		/** @private */ private var _form:TextFormat;
		/** @private */ private var _text:String;
		/** @private */ private var _font:String;
		/** @private */ private var _size:uint;
		/** @private */ private var _align:String;
		/** @private */ private var _wordWrap:Boolean;
		
		// Default font family.
		// Use this option when compiling with Flex SDK 4
		// [Embed(source = '04B_03__.TTF', embedAsCFF="false", fontFamily = 'default')]
		// Use this option when compiling with Flex SDK <4
		[Embed(source = '04B_03__.TTF', fontFamily = 'default')]
		/** @private */ private static var _FONT_DEFAULT:Class;
	}
}
