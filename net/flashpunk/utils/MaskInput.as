package net.flashpunk.utils
{
	import net.flashpunk.Entity;
	import net.flashpunk.World;
	import net.flashpunk.utils.Input;
	
	public class MaskInput
	{
		public static function mouseX(entity:Entity):int
		{
			if(!entity.world) return 0;
			return entity.world.mouseX - entity.x;
		}
		
		public static function mouseY(entity:Entity):int
		{
			if(!entity.world) return 0;
			return entity.world.mouseY - entity.y;
		}
		
		public static function mouseDown(entity:Entity, onlyOnTop:Boolean = true, screenMouse:Boolean = false):Boolean
		{
			if(!Input.mouseDown) return false;
			return mouseIsOver(entity, onlyOnTop, screenMouse);
		}
		
		public static function mouseUp(entity:Entity, onlyOnTop:Boolean = true, screenMouse:Boolean = false):Boolean
		{
			if(!Input.mouseUp) return false;
			return mouseIsOver(entity, onlyOnTop, screenMouse);
		}
		
		public static function mousePressed(entity:Entity, onlyOnTop:Boolean = true, screenMouse:Boolean = false):Boolean
		{
			if(!Input.mousePressed) return false;
			return mouseIsOver(entity, onlyOnTop, screenMouse);
		}
		
		public static function mouseReleased(entity:Entity, onlyOnTop:Boolean = true, screenMouse:Boolean = false):Boolean
		{
			if(!Input.mouseReleased) return false;
			return mouseIsOver(entity, onlyOnTop, screenMouse);
		}
		
		public static function mouseIsOver(entity:Entity, onlyOnTop:Boolean = true, screenMouse:Boolean = false):Boolean
		{
			if(!entity.world) return false;
			var w:World = entity.world;
			var mx:Number = w.mouseX;
			var my:Number = w.mouseY;
			if(screenMouse)
			{
				mx = Input.mouseX;
				my = Input.mouseY;
			}
			var x:Number = entity.x;
			var y:Number = entity.y;
			
			if(entity.collidePoint(x, y, mx, my))
			{
				if(!onlyOnTop) return true;
				return w.frontCollidePoint(mx, my) == entity;
			}
			return false;
		}
	}
}