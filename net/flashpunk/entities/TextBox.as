package net.flashpunk.entities {
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Text;
	
	public class TextBox extends Entity
	{
		/**
		 * An entity with a Text-type graphic
		 **/
		public function TextBox(text:String, x:Number = 0, y:Number = 0)
		{
			super(x, y, new Text(text));
		}
		
		/**
		 * The current text to be displayed
		 **/
		public function get text():String
		{
			return Text(this.graphic).text;
		}
		
		/**
		 * Set the text to be displayed
		 */
		public function set text(value:String):void
		{
			Text(this.graphic).text = value;
		}
	}
}
