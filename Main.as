package {
	import net.flashpunk.Engine;
	import net.flashpunk.FP;


	/**
	 * ...
	 * @author azrafe7
	 */
	[SWF(width="640", height="400", backgroundColor="#000000")]
	public class Main extends Engine
	{
		
		public function Main() {
			super(320, 200, 60, false);
		}
		
		override public function init():void {
			super.init();
			FP.screen.scale = 2;
			FP.console.enable();
			
			FP.world = new TestWorld;
		}		
		
		public static function main():void { 
			new Main(); 
		}
		
	}
}