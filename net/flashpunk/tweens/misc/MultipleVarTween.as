package net.flashpunk.tweens.misc
{
	import net.flashpunk.Tween;
	
	/**
	 * Tweens multiple numeric public properties of an Object simultaneously.
	 */
	public class MultipleVarTween extends Tween
	{
		/**
		 * Constructor.
		 * @param	complete	Optional completion callback.
		 * @param	type		Tween type.
		 */
		public function MultipleVarTween(complete:Function = null, type:uint = 0) 
		{
			super(0, type, complete);
		}
		
		/**
		 * Tweens multiple numeric public properties.
		 * @param	object		The object containing the properties.
		 * @param	values		An object containing key/value pairs of properties and target values.
		 * @param	duration	Duration of the tween.
		 * @param	ease		Optional easer function.
		 */
		public function tween(object:Object, values:Object, duration:Number, ease:Function = null):void
		{
			_object = object;
			_properties.length = 0;
			_start.length = 0;
			_range.length = 0;
			_target = duration;
			var property:String;
			for (property in values)
			{
				if (!object.hasOwnProperty(property)) throw new Error("The Object does not have the property\"" + property + "\", or it is not accessible.");
				var a:* = _object[property] as Number;
				if (a == null) throw new Error("The property \"" + property + "\" is not numeric.");
				_properties.push(property);
				_start.push(a);
				_range.push(values[property] - a);
			}
			start();
		}
		
		/** @private Updates the Tween. */
		override public function update():void 
		{
			super.update();
			var i:int;
			var l:int = _properties.length;
			for (i = 0; i < l; i++)
			{
				_object[_properties[i]] = _start[i] + _range[i] * _t;
			}
		}
		
		// Tween information.
		/** @private */ private var _object:Object;
		/** @private */ private var _properties:Vector.<String> = new Vector.<String>;
		/** @private */ private var _start:Vector.<Number> = new Vector.<Number>;
		/** @private */ private var _range:Vector.<Number> = new Vector.<Number>;
	}
}
