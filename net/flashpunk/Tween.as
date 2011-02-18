package net.flashpunk 
{
	import net.flashpunk.tweens.TweenInfo;
	
	/**
	 * Base class for all Tween objects, can be added to any Core-extended classes.
	 */
	public class Tween 
	{
		/**
		 * Persistent Tween type, will stop when it finishes.
		 */
		public static const PERSIST:uint = 0;
		
		/**
		 * Looping Tween type, will restart immediately when it finishes.
		 */
		public static const LOOPING:uint = 1;
		
		/**
		 * Oneshot Tween type, will stop and remove itself from its core container when it finishes.
		 */
		public static const ONESHOT:uint = 2;
		
		/**
		 * If the tween should update.
		 */
		public var active:Boolean;
		
		/**
		 * Tween completion callback.
		 */
		public var complete:Function;
		
		/**
		 * Constructor. Specify basic information about the Tween.
		 * @param	duration		Duration of the tween (in seconds or frames).
		 * @param	type			Tween type, one of Tween.PERSIST (default), Tween.LOOPING, or Tween.ONESHOT.
		 * @param	complete		Optional callback for when the Tween completes.
		 * @param	ease			Optional easer function to apply to the Tweened value.
		 */
		public function Tween(duration:Number, type:uint = 0, complete:Function = null, ease:Function = null) 
		{
			_target = duration;
			_type = type;
			this.complete = complete;
			_ease = ease;
		}
		
		/**
		 * Updates the Tween, called by World.
		 */
		public function update():void
		{
			_time += FP.fixed ? 1 : FP.elapsed;
			_t = _time / _target;
			if (_ease != null && _t > 0 && _t < 1) _t = _ease(_t);
			if (_time >= _target)
			{
				_t = 1;
				_finish = true;
			}
		}
		
		/**
		 * Starts the Tween, or restarts it if it's currently running.
		 */
		public function start():void
		{
			_time = 0;
			if (_target == 0)
			{
				active = false;
				return;
			}
			active = true;
		}
		
		/**
		 * Immediately stops the Tween and removes it from its Tweener without calling the complete callback.
		 */
		public function cancel():void
		{
			active = false;
			if (_parent) _parent.removeTween(this);
		}
		
		/** @private Called when the Tween completes. */
		internal function finish():void
		{
			switch (_type)
			{
				case 0:
					_time = _target;
					active = false;
					break;
				case 1:
					_time %= _target;
					_t = _time / _target;
					if (_ease != null && _t > 0 && _t < 1) _t = _ease(_t);
					start();
					break;
				case 2:
					_time = _target;
					active = false;
					_parent.removeTween(this);
					break;
			}
			_finish = false;
			if (complete != null) complete();
		}
		
		/**
		 * The completion percentage of the Tween.
		 */
		public function get percent():Number { return _time / _target; }
		public function set percent(value:Number):void { _time = _target * value; }
		
		/**
		 * The current time scale of the Tween (after easer has been applied).
		 */
		public function get scale():Number { return _t; }
		
		/**
		 * Tweens the properties of an object.
		 * @param	object		Object to tween.
		 * @param	duration	Duration of the tween.
		 * @param	values		Properties to tween and their target values (eg. {x:100, y:200} ).
		 * @param	complete	Optional completion callback function.
		 * @param	ease		Optional easer function.
		 */
		public static function to(object:Object, duration:Number, values:Object, complete:Function = null, ease:Function = null):void
		{
			var t:TweenInfo = TweenInfo.create(object, duration, values, complete, ease),
				i:int = _tweens.length;
			while (i --)
			{
				if (!_tweens[i])
				{
					_tweens[i] = t;
					return;
				}
			}
			_tweens.push(t);
		}
		
		/**
		 * Clears any active static tweens called by Tween.to().
		 */
		public static function clear():void
		{
			for each (var tween:TweenInfo in _tweens) tween.destroy();
			_tweens.length = 0;
		}
		
		/** @private Updates the static tweens. */ 
		internal static function update():void
		{
			var e:Number, t:Number, i:String, tween:TweenInfo, j:int = _tweens.length, f:Function;
			while (j --)
			{
				tween = _tweens[j];
				if (tween)
				{
					tween.elapsed += FP.elapsed;
					e = tween.elapsed / tween.duration;
					if (e >= 1) e = 1;
					t = tween.ease == null ? e : tween.ease(e);
					for (i in tween.start) tween.object[i] = tween.start[i] + tween.range[i] * t;
					if (e == 1)
					{
						f = tween.complete;
						tween.destroy();
						_tweens[j] = null;
						if (f != null) f();
					}
				}
			}
		}
		
		// Tween information.
		/** @private */ private var _type:uint;
		/** @private */ protected var _ease:Function;
		/** @private */ protected var _t:Number = 0;
		
		// Timing information.
		/** @private */ protected var _time:Number;
		/** @private */ protected var _target:Number;
		
		// List information.
		/** @private */ internal var _finish:Boolean;
		/** @private */ internal var _parent:Tweener;
		/** @private */ internal var _prev:Tween;
		/** @private */ internal var _next:Tween;
		
		// Static tweening information.
		/** @private */ private static var _tweens:Vector.<TweenInfo> = new Vector.<TweenInfo>;
	}
}
