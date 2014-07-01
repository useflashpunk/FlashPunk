package net.flashpunk.graphics 
{
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * Contains all the formatting needed for the GText.
	 * @author Copying
	 */
	public class TextFormatting 
	{
		//default values
		public static var default_x:Number = 0;
		public static var default_y:Number = 0;
		public static var default_font:String = "04b03";
		public static var default_size:uint = 16;
		public static var default_color:uint = 0xFFFFFF;
		public static var default_multiline:Boolean = true;
		public static var default_wordWrap:Boolean = false;
		public static var default_width:Number = 100;
		public static var default_height:Number = 20;
		public static var default_resizable:Boolean = false;
		public static var default_textScrollX:Number = 0;
		public static var default_textScrollY:Number = 0;
		public static var default_align:String = "left";
		public static var default_vAlign:String = "top";
		public static var default_isRichText:Boolean = false;
		
		//public real variables (the ones that are not using instances)
		public var resizable:Boolean;
		public var vAlign:String;
		public var wordWrap:Boolean;
		public var isRichText:Boolean;
		public var defaultTextFormat:TextFormat;
		
		public var parent:Text = null;
		//only used in the code
		public var rectChanged:Boolean;
		
		/**
		 * Constructor.
		 * To set the options you have to use:
		 * (format = new GTextFormat).setOptions(options);
		 */
		public function TextFormatting() 
		{
			//sets all the default values
			defaultTextFormat = new TextFormat(default_font, default_size, default_color & 0xFFFFFF);
			
			_x = default_x;
			_y = default_y;
			
			_alpha = (default_color & 0xFF000000) >> 6;
			_multiline = default_multiline;
			_width = default_width;
			_height = default_height;
			resizable = default_resizable;
			wordWrap = default_wordWrap;
			_textScroll = new Point(default_textScrollX, default_textScrollY);
			align = default_align;
			vAlign = default_vAlign;
			isRichText = default_isRichText;
			
			rectChanged = false;
		}
		
		public function setOptions(options:Object):void
		{
			for (var o:String in options)
			{
				if (!setProperty(o, options[o], false))
				{
					throw new ArgumentError("'" + o + "' is not a TextFormatting or a TextFormat option. For Image properties modify them directly.");
				}
			}
			if (parent) parent.updateTextBuffer();
		}
		
		public function setProperty(property:String, value:*, update:Boolean = false):Boolean
		{
			if (property == "x")
			{
				_x = value;
				if (parent) parent.x = _x;
			}
			else if (property == "y")
			{
				_y = value;
				if (parent) parent.y = _y;
			}
			else if (property == "color") //colorARGB
			{
				defaultTextFormat.color = (value & 0xFFFFFF);
				_alpha = (_alphaARGB = ((value & 0xFF000000) >> 6)) / 0xFF;
			}
			else if (property == "multiline")
			{
				_multiline = value;
			}
			else if (property == "wordWrap")
			{
				wordWrap = value;
			}
			else if (property == "width")
			{
				_width = value;
				rectChanged = true;
			}
			else if (property == "height")
			{
				_height = value;
				rectChanged = true;
			}
			else if (property == "resizable")
			{
				resizable = value;
			}
			else if (property == "textScrollX")
			{
				_textScroll.x = value;
			}
			else if (property == "textScrollY")
			{
				_textScroll.y = value;
			}
			else if (property == "align")
			{
				align = value;
			}
			else if (property == "vAlign")
			{
				vAlign = value;
			}
			else if (property == "isRichText")
			{
				isRichText = value;
			}
			else if (defaultTextFormat.hasOwnProperty(property))
			{
				defaultTextFormat[property] = value;
			}
			else
			{
				return false;
			}
			
			if (update && parent) parent.updateTextBuffer();
			return true;
		}
		
		public function get x():Number { return _x; }
		public function set x(x:Number):void
		{
			_x = x;
			if (parent) parent.x = _x;
		}
		
		public function get y():Number { return _y; }
		public function set y(y:Number):void
		{
			_y = y;
			if (parent) parent.y = _y;
		}
		
		public function get font():String { return defaultTextFormat.font; }
		public function set font(f:String):void
		{
			defaultTextFormat.font = f;
			
			if (parent) parent.updateTextBuffer();
		}
		
		public function get size():uint
		{
			if (defaultTextFormat.size is uint)
			{
				return (defaultTextFormat.size as uint);
			}
			else
			{
				return 0;
			}
		}
		public function set size(s:uint):void
		{
			defaultTextFormat.size = s;
			
			if (parent) parent.updateTextBuffer();
		}
		
		public function get align():String { return defaultTextFormat.align; }
		public function set align(a:String):void
		{
			if (a == TextFormatAlign.CENTER || a == TextFormatAlign.RIGHT || a == TextFormatAlign.JUSTIFY)
			{
				defaultTextFormat.align = a;
			}
			else
			{
				defaultTextFormat.align = TextFormatAlign.LEFT;
			}
		}
		
		public function get colorRGB():uint//{ return defaultTextFormat.color & 0xFFFFFF; }
		{
			if (defaultTextFormat.color is uint)
			{
				return (defaultTextFormat.color as uint) & 0xFFFFFF;
			}
			else
			{
				return 0;
			}
		}
		public function set colorRGB(c:uint):void
		{
			defaultTextFormat.color = c & 0xFFFFFF;
			
			if (parent) parent.updateTextBuffer();
		}
		
		public function get colorARGB():uint//{ return ((_alpha << 6) * 0xFF + (defaultTextFormat.color & 0xFFFFFF)); }
		{
			if (defaultTextFormat.color is uint)
			{
				return (_alphaARGB << 6) + ((defaultTextFormat.size as uint) & 0xFFFFFF);
			}
			else
			{
				return (_alphaARGB << 6);
			}
		}
		public function set colorARGB(c:uint):void
		{
			defaultTextFormat.color = c & 0xFFFFFF;
			_alpha = (_alphaARGB = ((c & 0xFF000000) >> 6)) / 0xFF;
			
			if (parent) parent.updateTextBuffer();
		}
		
		public function get alpha():Number { return _alpha; }
		public function set alpha(a:Number):void
		{
			if (a < 0)
			{
				_alpha = 0;
				_alphaARGB = 0;
			}
			else if (a > 1)
			{
				_alpha = 1;
				_alphaARGB = 0xFF;
			}
			else
			{
				_alpha = a;
				_alphaARGB = a * 0xFF;
			}
			
			if (parent) parent.updateTextBuffer();
		}
		
		public function get alphaARGB():uint { return _alphaARGB; }
		public function set alphaARGB(a:uint):void
		{
			if (a < 0)
			{
				_alphaARGB = 0;
				_alpha = 0;
			}
			else if (a > 0xFF)
			{
				_alphaARGB = 0xFF;
				_alpha = 1;
			}
			else
			{
				_alphaARGB = a;
				_alpha = a / 0xFF;
			}
			
			if (parent) parent.updateTextBuffer();
		}
		
		public function get width():Number { return _width; }
		public function set width(w:Number):void
		{
			if (_width == w) return;
			if (w >= 0)
			{
				_width = w;
				rectChanged = true;
			}
			
			if (parent) parent.updateTextBuffer();
		}
		
		public function get height():Number { return _height; }
		public function set height(h:Number):void
		{
			if (_height == h) return;
			if (h >= 0)
			{
				_height = h;
				rectChanged = true;
			}
			
			if (parent) parent.updateTextBuffer();
		}
		
		public function get textScrollX():Number { return _textScroll.x; }
		public function set textScrollX(x:Number):void
		{
			_textScroll.x = x;
			
			if (parent) parent.updateTextBuffer();
		}
		
		public function get textScrollY():Number { return _textScroll.y; }
		public function set textScrollY(y:Number):void
		{
			_textScroll.y = y;
			
			if (parent) parent.updateTextBuffer();
		}
		
		public function get multiline():Boolean { return _multiline; }
		public function set multiline(m:Boolean):void
		{
			if (_multiline == m) return;
			_multiline = m;
			
			if (parent) parent.updateTextBuffer();
		}
		
		private var _x:Number;
		private var _y:Number;
		private var _alpha:Number;
		private var _alphaARGB:uint;
		private var _width:Number;
		private var _height:Number;
		private var _textScroll:Point;
		private var _multiline:Boolean;
		
		
		public static function getFormat(options:Object):TextFormatting
		{
			var format:TextFormatting = new TextFormatting;
			format.setOptions(options);
			return format;
		}
		
//-- --- --- --- --- ---  Handle de different types (rich text part)  --- --- --- --- --- --- --- ---
		public static function setStyle(name:String, options:*):void
		{
			if (options is TextFormat)
			{
				styles[key] = options;
				return;
			}
			
			var format:TextFormat = new TextFormat;
			for (var key:String in options)
			{
				if (!format.hasOwnProperty(key))
				{
					throw new ArgumentError ('"' + key + '" is not a TextFormat property (not the same as a general GTextFormat).');
					continue;
				}
				format[key] = options[key];
			}
			styles[name] = format;
		}
		public static function getStyle(name:String):TextFormat
		{
			return styles.hasOwnProperty(name) ? styles[name] : null;
		}
		public static function get styles():Object { return _styles; }
		private static var _styles:Object = new Object;
		
		
//-- --- --- --- --- --- --- --- --- --- --- 
		// Default font family.
		// Use this option when compiling with Flex SDK 3 or lower
		// [Embed(source = '04B_03__.TTF', fontFamily = 'default')]
		// Use this option when compiling with Flex SDK 4
		[Embed(source = '04B_03__.TTF', embedAsCFF="false", fontFamily = 'default')]
		/** @private */ private static var _FONT_DEFAULT:Class;	
	}

}