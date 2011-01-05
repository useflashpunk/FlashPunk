package net.flashpunk
{
	/**
	 * Updateable Tween container.
	 */
	public class Tweener
	{
		/**
		 * Persistent Tween type, will stop when it finishes.
		 */
		public const PERSIST:uint = 0;
		
		/**
		 * Looping Tween type, will restart immediately when it finishes.
		 */
		public const LOOPING:uint = 1;
		
		/**
		 * Oneshot Tween type, will stop and remove itself from its core container when it finishes.
		 */
		public const ONESHOT:uint = 2;
		
		/**
		 * If the Tweener should update.
		 */
		public var active:Boolean = true;
		
		/**
		 * If the Tweener should clear on removal. For Entities, this is when they are
		 * removed from a World, and for World this is when the active World is switched.
		 */
		public var autoClear:Boolean = false;
		
		/**
		 * Constructor.
		 */
		public function Tweener() 
		{
			
		}
		
		/**
		 * Updates the Tween container.
		 */
		public function update():void
		{
			
		}
		
		/**
		 * Adds a new Tween.
		 * @param	t			The Tween to add.
		 * @param	start		If the Tween should call start() immediately.
		 * @return	The added Tween.
		 */
		public function addTween(t:Tween, start:Boolean = false):Tween
		{
			if (t._parent) throw new Error("Cannot add a Tween object more than once.");
			t._parent = this;
			t._next = _tween;
			if (_tween) _tween._prev = t;
			_tween = t;
			if (start) _tween.start();
			return t;
		}
		
		/**
		 * Removes a Tween.
		 * @param	t		The Tween to remove.
		 * @return	The removed Tween.
		 */
		public function removeTween(t:Tween):Tween
		{
			if (t._parent != this) throw new Error("Core object does not contain Tween.");
			if (t._next) t._next._prev = t._prev;
			if (t._prev) t._prev._next = t._next;
			else _tween = t._next;
			t._next = t._prev = null;
			t._parent = null;
			t.active = false;
			return t;
		}
		
		/**
		 * Removes all Tweens.
		 */
		public function clearTweens():void
		{
			var t:Tween = _tween,
				n:Tween;
			while (t)
			{
				n = t._next;
				removeTween(t);
				t = n;
			}
		}
		
		/** 
		 * Updates all contained tweens.
		 */
		public function updateTweens():void
		{
			var t:Tween = _tween,
				n:Tween;
			while (t)
			{
				n = t._next;
				if (t.active)
				{
					t.update();
					if (t._finish) t.finish();
				}
				t = n;
			}
		}
		
		// List information.
		/** @private */ internal var _tween:Tween;
	}
}
