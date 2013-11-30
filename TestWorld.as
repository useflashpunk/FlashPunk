package  
{
	import flash.display.BlendMode;
	import flash.geom.Point;
	import flash.system.System;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.masks.Circle;
	import net.flashpunk.masks.Grid;
	import net.flashpunk.masks.Hitbox;
	import net.flashpunk.masks.Pixelmask;
	import net.flashpunk.Tween;
	import net.flashpunk.tweens.misc.NumTween;
	import net.flashpunk.utils.Draw;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import net.flashpunk.World;
	import net.flashpunk.masks.Polygon;
	
	/**
	 * ...
	 * @author azrafe7
	 */
	public class TestWorld extends World
	{
	
		[Embed(source="../assets/skeleton.png")]
		private var SKELETON:Class;
		
		private var eActive:Entity;
		private var ePoly:Entity;
		private var eCircle:Entity;
		private var circle:Circle;
		private var polygon:Polygon;
		private var text:Text;
		private var messages:Vector.<String>;
		private const MAX_MESSAGES:int = 7;
		
		public function TestWorld() 
		{
			
		}
		
		override public function begin():void {
			
			// interactive CIRCLE
			eCircle = addMask(circle = new Circle(20, 20,20), "circle");
			eCircle.x = FP.halfWidth;
			eCircle.y = FP.halfHeight + 20;
			
			// interactive POLYGON
			var points:Vector.<Point> = new Vector.<Point>();
			points.push(new Point(0, 0));
			points.push(new Point(30, 0));
			points.push(new Point(30, 30));
			//ePoly = addMask(polygon = new Polygon(points), "polygon");
			ePoly = addMask(polygon = Polygon.createPolygon(5, 20, 360/10), "polygon");
			ePoly.x = FP.halfWidth;
			ePoly.y = FP.halfHeight;
			/*ePoly.centerOrigin();
			polygon.x = ePoly.originX;
			polygon.y = ePoly.originY;			
			polygon.origin.x = ePoly.originX;
			polygon.origin.y = ePoly.originY;
			*/
			
			// other MASKS
			
			
			// Mask/Entity
			var e1:Entity = new Entity(200, 30);
			e1.type = "mask";
			e1.width = 40;
			e1.height = 50;
			add(e1);
			
			// Hitbox
			var hitbox:Hitbox = new Hitbox(30, 30, 20);
			var e2:Entity = addMask(hitbox, "hitbox");
			e2.x = 20;
			e2.y = 20;

			// Circle
			var e3:Entity = addMask(new Circle(30, 0, 0), "circle");
			e3.x = 250;
			e3.y = 110;
			
			// Grid
			var gridMask:Grid = new Grid(140, 80, 20, 20);
			var gridStr:String = 
			"1,0,0,1,1,1,0\n" +
			"0,0,0,1,0,1,1\n" +
			"1,0,0,0,0,0,1\n" +
			"0,0,0,0,0,0,1\n";
			gridMask.loadFromString(gridStr);
			var e4:Entity = addMask(gridMask, "grid", 5, 120);

			// Polygon
			var polyMask:Polygon = Polygon.createPolygon(8, 20);
			var e5:Entity = addMask(polyMask, "polygon");
			e5.x = 130;
			e5.y = 40;
			
			// Pixelmask
			var pixelmask:Pixelmask = new Pixelmask(SKELETON);
			var e6:Entity = addMask(pixelmask, "pixelmask");
			e6.x = 260;
			e6.y = 20;
			
			text = new Text("puppa!");
			var textEntity:Entity = new Entity(5, 55, text);
			text.blend = BlendMode.OVERLAY;
			text.scrollX = 0;
			text.scrollY = 0;
			text.scale = .5;
			text.setTextProperty("multiline", true);
			add(textEntity);
			
			messages = new Vector.<String>();
			messages.push("Enable the console...");
			messages.push("hit the play button on top...")
			messages.push("then use keys described below");
			
			text.text = messages.join("\n");
			
			FP.log("~: enable Console | SHIFT+ARROWS: move Circle | ARROWS: move Polygon");
		}
		
		override public function update():void 
		{
			super.update();
			
			// ESC to exit
			if (Input.pressed(Key.ESCAPE)) {
				System.exit(1);
			}
			
			// R to reset the world
			if (Input.pressed(Key.R)) {
				FP.world = new TestWorld();
			}
			
			if (Input.pressed(Key.SPACE)) {
				polygon.angle += 90;
			}
			
			if (!Input.check(Key.SHIFT)) {
				ePoly.x += Input.check(Key.LEFT) ? -1 : Input.check(Key.RIGHT) ? 1 : 0;
				ePoly.y += Input.check(Key.UP) ? -1 : Input.check(Key.DOWN) ? 1 : 0;
				eActive = ePoly;
			} else {
				eCircle.x += Input.check(Key.LEFT) ? -1 : Input.check(Key.RIGHT) ? 1 : 0;
				eCircle.y += Input.check(Key.UP) ? -1 : Input.check(Key.DOWN) ? 1 : 0;
				eActive = eCircle;
			}
			
			var hitEntities:Array = [];
			eActive.collideTypesInto(["hitbox", "mask", "circle", "grid", "polygon", "pixelmask"], eActive.x, eActive.y, hitEntities);
			
			for (var i:int = 0; i < hitEntities.length; i++) {
				var hitEntity:Entity = Entity(hitEntities[i]);
				trace("hit " + hitEntity.type);
				messages.push("hit " + hitEntity.type);
				if (messages.length > MAX_MESSAGES) messages.splice(0, 1);
				text.text = messages.join("\n");
				
				FP.alarm(.2, function ():void 
				{
					messages.splice(0, 1);
					text.text = messages.join("\n");
				});
			}
			
		}
		
		override public function render():void 
		{
			super.render();
			
			Draw.dot(FP.halfWidth, FP.halfHeight, 0x0000FF);
		}
	}

}