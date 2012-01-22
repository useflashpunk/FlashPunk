package net.flashpunk.graphics 
{
	/**
	 * Used by the Emitter class to track an existing Particle.
	 */
	public class Particle 
	{
		/**
		 * Constructor.
		 */
		public function Particle() 
		{
			
		}
		
		// Particle information.
		internal var _type:ParticleType;
		internal var _time:Number;
		internal var _duration:Number;
		
		// Motion information.
		internal var _x:Number;
		internal var _y:Number;
		internal var _moveX:Number;
		internal var _moveY:Number;
		
		// Gravity information.
		internal var _gravity:Number;
		
		// List information.
		internal var _prev:Particle;
		internal var _next:Particle;
	}
}