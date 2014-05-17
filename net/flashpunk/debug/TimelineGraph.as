package net.flashpunk.debug
{
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	
	import flash.text.TextField;
	import flash.text.TextFormat;

	import flash.geom.Rectangle;

	import net.flashpunk.FP;
	import net.flashpunk.graphics.Text;

	/** Displays data over time using a sliding graph. */
	public class TimelineGraph extends Sprite
	{
		protected var _graphColor:uint;
		protected var _graphName:String;
		protected var _graphUnit:String;
		protected var _format:TextFormat = new TextFormat();
		protected var _graphCursor:Rectangle;
		protected var _rangeSize:uint;
		
		// Reference the Text class so we can access its embedded font
		private static var textRef:Text;

		// UI Elements
		public var textField:TextField;
		public var bitmap:Bitmap;
		public function TimelineGraph(domainSize:uint, rangeSize:uint, graphName:String, graphUnit:String = "ms", color:uint = 0xffffffff)
		{
			var graph:BitmapData = new BitmapData(domainSize, rangeSize, true, 0x00000000);

			_graphName = graphName;
			_graphUnit = graphUnit;
			_graphColor = color;
			_rangeSize = rangeSize;
			_graphCursor = new Rectangle(0, 0, domainSize, rangeSize);
			_graphCursor.left = domainSize - 1;

			// Setup UI
			bitmap = new Bitmap(graph);
			bitmap.x = 2;
			bitmap.y = 2;

			_format.color = 0xffffff;
			_format.size = 12;
			_format.font = "Source Sans Pro";

			textField = new TextField();
			textField.defaultTextFormat = _format;
			textField.embedFonts = true;
			textField.y = bitmap.y + rangeSize + 3;
			textField.width = domainSize;
			textField.text = graphName;

			graphics.clear();
			graphics.beginFill(0, 0.5);
			graphics.drawRect(0, 0, domainSize + 4, rangeSize + 26);

			addChild(bitmap);
			addChild(textField);
		}

		public function addData(value:uint):void
		{
			// Update the text field with the actual value.
			textField.text = _graphName + ": " + value + " " + _graphUnit;
			bitmap.bitmapData.scroll(-1, 0);

			_graphCursor.top = 0;
			bitmap.bitmapData.fillRect(_graphCursor, 0x00000000);

			// Update the visual display with approximate data.
			if (value > _rangeSize)
			{
				_graphCursor.top = 0;
			}
			else
			{
				_graphCursor.top = _rangeSize - value;
			}
			
			bitmap.bitmapData.fillRect(_graphCursor, _graphColor);
		}
	}
}