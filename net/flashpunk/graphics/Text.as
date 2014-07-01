package net.flashpunk.graphics 
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	/**
	 * Used for trawing an String ith embed fonts and custom formats.
	 * Users of Flex SDK 3 have to goto the bottom of the TextFormatting.as file and cange the embed class.
	 * 
	 * NOTE: This clas is heavily based on the old Text class.
	 * @author Copying
	 */
	public class Text extends Image
	{
		public function Text(text:String = "", format:* = null, updateBuffer:Boolean = true) 
		{
			if (format == null) format = new TextFormatting;
			
			_text = text;
			
			if (format is TextFormatting)
			{
				_format = format;
			}
			else
			{
				_format = new TextFormatting;
				_format.setOptions(format);
			}
			
			super(new BitmapData(_format.width, _format.height, true, 0));
			
			
			
			_field = new TextField;
			_field.embedFonts = true;
			_field.multiline = true;
			_field.defaultTextFormat = _format.defaultTextFormat;
			
			_format.parent = this;
			
			x = _format.x;
			y = _format.y;
			
			if (updateBuffer) updateTextBuffer();
		}
		
		//updates the buffer that contains the textfield rendered (renders it).
		public function updateTextBuffer():void
		{
			_matrix = new Matrix(1, 0, 0, 1, 0, 0);
			
			//sets the texfield text and its format(s)
			_field.text = _text;
			matchStyles();
			
			//if multiline is not allowed, the text becomes only the first line
			if (!_format.multiline)
			{
				_text = _text.split("\n")[0];
			}
			
			//if it's resizable it resizes
			if (_format.resizable)
			{
				if (_format.wordWrap)
				{
					_field.wordWrap = false;
					_format.wordWrap = false;
				}
				
				if (_format.width < _field.textWidth)
				{
					_format.width = _field.textWidth;
					_format.rectChanged = true;
				}
				if (_format.height < _field.textHeight)
				{
					_format.height = _field.textHeight;
					_format.rectChanged = true;
				}
				
			}
			else //if resizes it will never word wrap (the jump of line is at the infinite)
			{
				if (_format.wordWrap)
				{
					_field.wordWrap = true;
				}
				_field.width = _format.width;
				_field.height = _format.width;
			}
			
			//change the buffer size if necesary (can be called becouse it was automatically resized).
			if (_format.rectChanged)
			{
				_source = new BitmapData(_format.width, _format.height, true, 0);
				_sourceRect = _source.rect;
				_format.rectChanged = false;
				createBuffer();
				updateBuffer();
			}
			else
			{
				_source.fillRect(_sourceRect, 0);
			}
			
			var ty:Number = 0;
			_field.y = 0;
			_field.scrollH = 0;
			_field.scrollV = 0;
			
			//V align
			if (_format.vAlign == "center")
			{
				ty = (_field.textHeight - _format.height) / 2;
				if (ty <= 0)
				{
					_matrix.translate(0, -ty);
				}
				else
				{
					_field.scrollV = ty;
				}
			}
			else if (_format.vAlign == "bottom")
			{
				ty = _field.textHeight - _format.height;
				if (ty <= 0)
				{
					_matrix.translate(0, -ty);
				}
				else
				{
					_field.scrollV = ty;
				}
			}
			
			_field.scrollH += _format.textScrollX;
			_field.scrollV += _format.textScrollY;
			
			_source.draw(_field, _matrix);
			
			//update the color tansform (it basically modifies the alpha)
			updateColorTransform();
			
			//finally, update the buffer
			updateBuffer();
		}
		
		override protected function updateColorTransform():void
		{
			if (_alpha == 1) {
				_tint = null;
			} else {
				_tint = _colorTransform;
				_tint.redMultiplier   = 1;
				_tint.greenMultiplier = 1;
				_tint.blueMultiplier  = 1;
				_tint.redOffset       = 0;
				_tint.greenOffset     = 0;
				_tint.blueOffset      = 0;
				_tint.alphaMultiplier = _alpha;
			}
		}
		
		//sets the diferents styles ina rich text.
		private static var _styleIndices:Vector.<int> = new Vector.<int>;
		private static var _styleMatched:Array = new Array;
		private static var _styleFormats:Vector.<TextFormat> = new Vector.<TextFormat>;
		private static var _styleFrom:Vector.<int> = new Vector.<int>;
		private static var _styleTo:Vector.<int> = new Vector.<int>;
		private static var _fragments:Array = new Array;
		
		private function matchStyles():void
		{
			if (!_format.isRichText)
			{
				_field.defaultTextFormat = _format.defaultTextFormat;
				return;
			}
			var i:int, j:int;
			
			_fragments = _text.split("<");
			
			_styleIndices.length = 0;
			_styleMatched.length = 0;
			_styleFormats.length = 0;
			_styleFrom.length = 0;
			_styleTo.length = 0;
			
			for (i = 1; i < _fragments.length; i++) {
				if (_styleMatched[i]) continue;
				
				var substring:String = _fragments[i];
			
				var tagLength:int = substring.indexOf(">");
				
				if (tagLength > 0) {
					var tagName:String = substring.substr(0, tagLength);
					if (_styles[tagName]) {
						_fragments[i] = substring.slice(tagLength + 1);
				
						var endTagString:String = "/" + tagName + ">";
				
						for (j = i + 1; j < _fragments.length; j++) {
							if (_fragments[j].substr(0, tagLength + 2) == endTagString) {
								_fragments[j] = _fragments[j].slice(tagLength + 2);
								_styleMatched[j] = true;
							
								break;
							}
						}
						
						_styleFormats.push(_styles[tagName]);
						_styleFrom.push(i);
						_styleTo.push(j);
						
						continue;
					}
				}
				
				_fragments[i-1] = _fragments[i-1].concat("<");
			}
			
			_styleIndices[0] = 0;
			j = 0;
			
			for (i = 0; i < _fragments.length; i++) {
				j += _fragments[i].length;
				_styleIndices[i+1] = j;
			}
			
			_field.text = _text = _fragments.join("");
			
			_field.setTextFormat(_format.defaultTextFormat);
			
			for (i = 0; i < _styleFormats.length; i++) {
				var start:int = _styleIndices[_styleFrom[i]];
				var end:int = _styleIndices[_styleTo[i]];
				
				if (start != end) _field.setTextFormat(_styleFormats[i], start, end);
			}
		}
		
		public function setTextProperty(property:String, value:*):Boolean
		{
			return _format.setProperty(property, value, true);
		}
		
		public function get text():String { return _text; }
		public function set text(t:String):void
		{
			if (t && (t != text))
			{
				_text = t;
			}
			_format.isRichText = false;
			
			updateTextBuffer();
		}
		
		public function get richText():String { return _text; }
		public function set richText(t:String):void
		{
			if (t && (t != text))
			{
				_text = t;
			}
			_format.isRichText = true;
			
			updateTextBuffer();
		}
		
		//to set all the format variables.
		public function get textFont():String { return _format.font; }
		public function set textFont(f:String):void { _format.font = f; }
		
		public function get textSize():uint { return _format.size; }
		public function set textSize(s:uint):void { _format.size = s; }
		
		public function get textAlign():String { return _format.align; }
		public function set textAlign(a:String):void { _format.align = a; }
		
		public function get textVAlign():String { return _format.vAlign; }
		public function set textVAlign(a:String):void { _format.vAlign = a; }
		
		public function get textColorRGB():uint { return _format.colorRGB; }
		public function set textColorRGB(c:uint):void { _format.colorRGB = c; }
		
		public function get textColorARGB():uint { return _format.colorARGB; }
		public function set textColorARGB(c:uint):void { _format.colorARGB = c; }
		
		public function get textAlpha():Number { return _format.alpha; }
		public function set textAlpha(a:Number):void { _format.alpha = a; }
		
		public function get textAlpaARGB():uint { return _format.alphaARGB; }
		public function set textAlphaARGB(a:uint):void { _format.alphaARGB = a; }
		
		public function get textWidth():Number { return _format.width; }
		public function set textWidth(w:Number):void { _format.width = w; }
		
		public function get textHeight():Number { return _format.height; }
		public function set textHeight(h:Number):void { _format.height = h; }
		
		public function get resizable():Boolean { return _format.resizable; }
		public function set resizable(r:Boolean):void { _format.resizable = r; }
		
		public function get textScrollX():Number { return _format.textScrollX; }
		public function set textScrollX(s:Number):void { _format.textScrollX = s; }
		
		public function get multiline():Boolean { return _format.multiline; }
		public function set multiline(m:Boolean):void { _format.multiline = m; }
		
		public function get wordWrap():Boolean { return _format.wordWrap; }
		public function set wordWrap(w:Boolean):void { _format.wordWrap = w; }
		
		private function get _styles():Object
		{
			return TextFormatting.styles;
		}
		
		private var _text:String;
		private var _format:TextFormatting;
		private var _field:TextField;
		
		private var _tlm:TextLineMetrics;
		private var _tlm_y:Number;
		
		
//-- --- Static part with all the rich text function and variables. Are directly called to the text format
		public static function setStyle(name:String, options:Object):void
		{
			TextFormatting.setStyle(name, options);
		}
		public static function getStyle(name:String):TextFormat
		{
			return TextFormatting.getStyle(name);
		}
	}

}