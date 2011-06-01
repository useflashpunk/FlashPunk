package net.flashpunk.graphics 
{
	import flash.display.Bitmap;
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
	 * 
	 * Note that users of Flex 3 must edit this class to get FlashPunk games to compile.
	 * The details of this can be found at the bottom of the file net/flashpunk/graphics/Text.as
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
		 * The leading to assign to new Text objects.
		 */
		public static var defaultLeading:Number = 0;
		
		/**
		 * The wordWrap property to assign to new Text objects.
		 */
		public static var wordWrap:Boolean = false;
		
		/**
		 * The resizable property to assign to new Text objects.
		 */
		public static var resizable: Boolean = true;
		
		/**
		 * If the text field can automatically resize if its contents grow.
		 */
		public var resizable: Boolean;
		
		/**
		 * Constructor.
		 * @param	text		Text to display.
		 * @param	x		X offset.
		 * @param	y		Y offset.
		 * @param	options		An object containing key/value pairs of the following optional parameters:
		 * 						font		Font family.
		 * 						size		Font size.
		 * 						align		Alignment ("left", "center" or "right").
		 * 						wordWrap	Automatic word wrapping.
		 * 						resizable	If the text field can automatically resize if its contents grow.
		 * 						width		Initial buffer width.
		 * 						height		Initial buffer height.
		 * 						color		Text color.
		 * 						alpha		Text alpha.
		 * 						angle		Rotation angle (see Image.angle).
		 * 						blend		Blend mode (see Image.blend).
		 * 						visible		Visibility (see Graphic.visible).
		 * 						scrollX		See Graphic.scrollX.
		 * 						scrollY		See Graphic.scrollY.
		 * 						relative	See Graphic.relative.
		 *				For backwards compatibility, if options is a Number, it will determine the initial buffer width.
		 * @param	h		Deprecated. For backwards compatibility: if set and there is no options.height parameter set, will determine the initial buffer height.
		 */
		public function Text(text:String, x:Number = 0, y:Number = 0, options:Object = null, h:Number = 0)
		{
			_font = Text.font;
			_size = Text.size;
			_align = Text.align;
			_leading = Text.defaultLeading;
			_wordWrap = Text.wordWrap;
			resizable = Text.resizable;
			var width:uint = 0;
			var height:uint = h;
			
			if (options)
			{
				if (options is Number) // Backwards compatibility: options parameter has replaced width
				{
					width = Number(options);
					options = null;
				}
				else
				{
					if (options.hasOwnProperty("font")) _font = options.font;
					if (options.hasOwnProperty("size")) _size = options.size;
					if (options.hasOwnProperty("align")) _align = options.align;
					if (options.hasOwnProperty("wordWrap")) _wordWrap = options.wordWrap;
					if (options.hasOwnProperty("resizable")) resizable = options.resizable;
					if (options.hasOwnProperty("width")) width = options.width;
					if (options.hasOwnProperty("height")) height = options.height;
				}
			}
			
			_field.embedFonts = true;
			_field.wordWrap = _wordWrap;
			_form = new TextFormat(_font, _size, 0xFFFFFF);
			_form.align = _align;
			_form.leading = _leading;
			_field.defaultTextFormat = _form;
			_field.text = _text = text;
			_width = width || _field.textWidth + 4;
			_height = height || _field.textHeight + 4;
			_source = new BitmapData(_width, _height, true, 0);
			super(_source);
			updateTextBuffer();
			this.x = x;
			this.y = y;
			
			if (options)
			{
				for (var property:String in options) {
					if (hasOwnProperty(property)) {
						this[property] = options[property];
					} else {
						throw new Error('"' + property + '" is not a property of Text');
					}
				}
			}
		}
		
		/** Updates the text buffer, which is the source for the image buffer. */
		public function updateTextBuffer():void
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
				createBuffer();
			}
			else
			{
				_source.fillRect(_sourceRect, 0);
			}
			
			_field.width = _width;
			_field.height = _height;
			
			var offsetRequired: Boolean = false;
			
			for (var i: int = 0; i < _field.numLines; i++) {
				var tlm: TextLineMetrics = _field.getLineMetrics(i);
				var remainder: Number = tlm.x % 1;
				if (remainder > 0.1 && remainder < 0.9) {
					offsetRequired = true;
					break;
				}
			}
			
			if (offsetRequired) {
				for (i = 0; i < _field.numLines; i++) {
					tlm = _field.getLineMetrics(i);
					remainder = tlm.x % 1;
					_field.x = -remainder;
					
					FP.rect.x = 0;
					FP.rect.y = 2 + tlm.height * i;
					FP.rect.width = _width;
					FP.rect.height = tlm.height;
					
					_source.draw(_field, _field.transform.matrix, null, null, FP.rect);
				}
			} else {
				_source.draw(_field);
			}
			
			super.updateBuffer();
		}
		
		/** @private Centers the Text's originX/Y to its center. */
		override public function centerOrigin():void 
		{
			originX = _width / 2;
			originY = _height / 2;
		}
		
		/**
		 * Text string.
		 */
		public function get text():String { return _text; }
		public function set text(value:String):void
		{
			if (_text == value) return;
			_field.text = _text = value;
			updateTextBuffer();
		}
		
		/**
		 * Font family.
		 */
		public function get font():String { return _font; }
		public function set font(value:String):void
		{
			if (_font == value) return;
			_form.font = _font = value;
			updateTextBuffer();
		}
		
		/**
		 * Font size.
		 */
		public function get size():uint { return _size; }
		public function set size(value:uint):void
		{
			if (_size == value) return;
			_form.size = _size = value;
			updateTextBuffer();
		}
		
		/**
		 * Alignment ("left", "center" or "right").
		 */
		public function get align():String { return _align; }
		public function set align(value:String):void
		{
			if (_align == value) return;
			_form.align = _align = value;
			updateTextBuffer();
		}
		
		/**
		 * Leading (amount of vertical space between lines).
		 */
		public function get leading():Number { return _leading; }
		public function set leading(value:Number):void
		{
			if (_leading == value) return;
			_form.leading = _leading = value;
			updateTextBuffer();
		}
		
		/**
		 * Automatic word wrapping.
		 */
		public function get wordWrap():Boolean { return _wordWrap; }
		public function set wordWrap(value:Boolean):void
		{
			if (_wordWrap == value) return;
			_field.wordWrap = _wordWrap = value;
			updateTextBuffer();
		}
		
		/**
		 * Width of the text image.
		 */
		override public function get width():uint { return _width; }
		public function set width(value:uint):void
		{
			if (_width == value) return;
			_width = value;
			updateTextBuffer();
		}
		
		/**
		 * Height of the text image.
		 */
		override public function get height():uint { return _height; }
		public function set height(value:uint):void
		{
			if (_height == value) return;
			_height = value;
			updateTextBuffer();
		}
		
		/**
		 * The scaled width of the text image.
		 */
		override public function get scaledWidth():uint { return _width * scaleX * scale; }
		
		/**
		 * The scaled height of the text image.
		 */
		override public function get scaledHeight():uint { return _height * scaleY * scale; }
		
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
		/** @private */ private var _leading:Number;
		/** @private */ private var _wordWrap:Boolean;
		
		// Default font family.
		// Use this option when compiling with Flex SDK 3 or lower
		// [Embed(source = '04B_03__.TTF', fontFamily = 'default')]
		// Use this option when compiling with Flex SDK 4
		[Embed(source = '04B_03__.TTF', embedAsCFF="false", fontFamily = 'default')]
		/** @private */ private static var _FONT_DEFAULT:Class;
	}
}
